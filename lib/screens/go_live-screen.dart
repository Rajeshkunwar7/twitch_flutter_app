import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitch/resources/firestore_methods.dart';
import 'package:flutter_twitch/screens/broadcast_screen.dart';
import 'package:flutter_twitch/utils/colors.dart';
import 'package:flutter_twitch/utils/utils.dart';
import 'package:flutter_twitch/widgets/custom_button.dart';
import 'package:flutter_twitch/widgets/custom_text_field.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final titleController = TextEditingController();
  Uint8List? image;

  goLive() async {
    String channelId = await FirestoreMethods()
        .startLiveStream(context, titleController.text, image);
    if (channelId.isNotEmpty) {
      showSnackBar(context, "Live Stream Started");
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BroadCastScreen(
                channelId: channelId,
                isBroadcaster: true,
              )));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Uint8List? pickedImg = await pickImage();
                      if (pickedImg != null) {
                        print(pickedImg);
                        print("pickedImg");
                        setState(() {
                          image = pickedImg;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 20),
                      child: image != null
                          ? SizedBox(height: 150, child: Image.memory(image!))
                          : DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: buttonColor,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                    color: buttonColor.withOpacity(.05),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder_open,
                                      color: buttonColor,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Select the Thumbnail",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade300,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: CustomTextField(controller: titleController),
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomButton(
                    title: "Go Live",
                    onTap: () {
                      goLive();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
