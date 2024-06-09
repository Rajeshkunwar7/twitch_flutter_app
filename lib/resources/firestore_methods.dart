import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_twitch/models/live_stream.dart';
import 'package:flutter_twitch/provider/user_provider.dart';
import 'package:flutter_twitch/resources/storage_methods.dart';
import 'package:flutter_twitch/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods storageMethods = StorageMethods();

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? image) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    String channelId = "";
    try {
      if (title.isNotEmpty && image != null) {
        if (!((await _firestore
                .collection("livestream")
                .doc("${user.user.uid}${user.user.username}")
                .get())
            .exists)) {
          String thumbnail = await storageMethods.uploadImageToStorage(
              "livestream-thumbnails", image, user.user.uid);

          channelId = "${user.user.uid}${user.user.username}";
          LiveStream liveStream = LiveStream(
            title: title,
            image: thumbnail,
            uid: user.user.uid,
            username: user.user.username,
            startedAt: DateTime.now(),
            viewers: 0,
            channelId: channelId,
          );

          _firestore
              .collection("livestream")
              .doc(channelId)
              .set(liveStream.toMap());
        } else {
          showSnackBar(context, "Two live stream not available");
        }
      } else {
        showSnackBar(context, "Please enter data");
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return channelId;
  }

  Future<void> endLiveStream(String channelId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection("livestream")
          .doc(channelId)
          .collection("comments")
          .get();

      for (int i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection("livestream")
            .doc(channelId)
            .collection("comments")
            .doc(
              ((snap.docs[i].data()! as dynamic)['commentId']),
            )
            .delete();
      }
      await _firestore.collection("livestream").doc(channelId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firestore.collection("livestream").doc(id).update({
        'viewers': FieldValue.increment(isIncrease ? 1 : -1),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> chat(String text, String id, BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false);

    try {
      String commentId = const Uuid().v1();
      await _firestore
          .collection("livestream")
          .doc(id)
          .collection("comments")
          .doc(commentId)
          .set({
        "username": user.user.username,
        "message": text,
        "uid": user.user.uid,
        "createdAt": DateTime.now(),
        "commentId": commentId
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
