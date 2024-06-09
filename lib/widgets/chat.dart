import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitch/provider/user_provider.dart';
import 'package:flutter_twitch/resources/firestore_methods.dart';
import 'package:flutter_twitch/widgets/custom_text_field.dart';
import 'package:flutter_twitch/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String channelId;

  const ChatScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController chatController = TextEditingController();

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection("livestream")
                  .doc(widget.channelId)
                  .collection("comments")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) => ListTile(
                          title: Text(
                            snapshot.data.docs[index]['username'],
                            style: TextStyle(
                              color: snapshot.data.docs[index]['uid'] ==
                                      userProvider.user.uid
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(snapshot.data.docs[index]['message']),
                        ));
              },
            ),
          ),
          CustomTextField(
            controller: chatController,
            onTap: (val) {
              FirestoreMethods()
                  .chat(chatController.text, widget.channelId, context);
              chatController.clear();
            },
          )
        ],
      ),
    );
  }
}
