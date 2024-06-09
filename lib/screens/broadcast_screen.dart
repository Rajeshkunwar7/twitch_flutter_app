import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitch/provider/user_provider.dart';
import 'package:flutter_twitch/resources/firestore_methods.dart';
import 'package:flutter_twitch/screens/home_screen.dart';
import 'package:flutter_twitch/widgets/chat.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../config/app_id.dart';
import '../widgets/custom_button.dart';

class BroadCastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;

  const BroadCastScreen(
      {Key? key, required this.isBroadcaster, required this.channelId})
      : super(key: key);

  @override
  State<BroadCastScreen> createState() => _BroadCastScreenState();
}

class _BroadCastScreenState extends State<BroadCastScreen> {
  late final RtcEngine engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMute = false;
  bool screenShare = false;

  @override
  void initState() {
    super.initState();
    initEngine();
  }

  void initEngine() async {
    engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    addListeners();
    await engine.enableVideo();
    await engine.startPreview();
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      engine.setClientRole(ClientRole.Broadcaster);
    } else {
      engine.setClientRole(ClientRole.Audience);
    }

    joinChannel();
  }

  void joinChannel() async {
    await getToken();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await engine.joinChannelWithUserAccount(token, widget.channelId,
        Provider.of<UserProvider>(context, listen: false).user.uid);
  }

  void addListeners() {
    engine.setEventHandler(
      RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
        print("$channel , $uid , $elapsed");
      }, userJoined: (uid, elapsed) {
        print("$uid , $elapsed");
        setState(() {
          remoteUid.add(uid);
        });
      }, userOffline: (uid, elapsed) {
        print("$uid , $elapsed");
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
        });
      }, leaveChannel: (stats) {
        print("$stats leave channel");
        setState(() {
          remoteUid.clear();
        });
      }, tokenPrivilegeWillExpire: (token) async {
        await getToken();
        await engine.renewToken(token);
      }),
    );
  }

  void leaveChannel() async {
    await engine.leaveChannel();
    if ("${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}" ==
        widget.channelId) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }

    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  void switchCameraFun() {
    engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      print("error $err");
    });
  }

  void toggleMute() async {
    setState(() {
      isMute = !isMute;
    });
    await engine.muteLocalAudioStream(isMute);
  }

  String baseUrl = "https://fluttertwitch.herokuapp.com/";
  String? token;

  Future<void> getToken() async {
    final res = await http.get(Uri.parse(baseUrl +
        'rtc/' +
        widget.channelId +
        '/publisher/userAccount/' +
        Provider.of<UserProvider>(context, listen: false).user.uid +
        '/'));

    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      print("failed to fetch token");
    }
  }

  startScreenShare() async {
    final helper = await engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = random.nextInt(windows.length - 1);
        debugPrint('Screensharing window with index $index');
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      screenShare = true;
    });
    await helper.joinChannelWithUserAccount(
      token,
      widget.channelId,
      Provider.of<UserProvider>(context, listen: false).user.uid,
    );
  }

  stopScreenShare() async {
    print("stop share");
    final helper = await engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        screenShare = false;
      });
    }).catchError((err) {
      print("stop $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return WillPopScope(
      onWillPop: () async {
        leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
          bottomNavigationBar: widget.isBroadcaster
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: CustomButton(
                    title: 'End Stream',
                    onTap: leaveChannel,
                  ),
                )
              : null,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                renderVideo(user, screenShare),
                if ("${user.uid}${user.username}" == widget.channelId)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                          onTap: () {
                            switchCameraFun();
                          },
                          child: const Text("Switch Camera")),
                      InkWell(
                          onTap: () {
                            toggleMute();
                          },
                          child: Text(isMute ? "UnMute" : "Mute")),
                      InkWell(
                          onTap: () {
                            screenShare
                                ? startScreenShare()
                                : stopScreenShare();
                          },
                          child: Text(screenShare ? "Stop" : "Start")),
                    ],
                  ),
                Expanded(child: ChatScreen(channelId: widget.channelId))
              ],
            ),
          )),
    );
  }

  renderVideo(user, screenShare) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: "${user.uid}${user.username}" == widget.channelId
            ? screenShare
                ? kIsWeb
                    ? const RtcLocalView.SurfaceView.screenShare()
                    : const RtcLocalView.TextureView.screenShare()
                : const RtcLocalView.SurfaceView(
                    zOrderMediaOverlay: true,
                    zOrderOnTop: true,
                  )
            : screenShare
                ? kIsWeb
                    ? const RtcLocalView.SurfaceView.screenShare()
                    : const RtcLocalView.TextureView.screenShare()
                : remoteUid.isNotEmpty
                    ? kIsWeb
                        ? RtcRemoteView.SurfaceView(
                            uid: remoteUid[0],
                            channelId: widget.channelId,
                          )
                        : RtcRemoteView.TextureView(
                            uid: remoteUid[0],
                            channelId: widget.channelId,
                          )
                    : const SizedBox());
  }
}
