import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (cxt, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData ||
            chatSnapshot.data!.docs.isEmpty ||
            chatSnapshot.hasError) {
          return const Center(
            child: Text('No data found.'),
          );
        }
        final messages = chatSnapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(
            bottom: 16,
            left: 10,
            right: 10,
          ),
          itemCount: messages.length,
          itemBuilder: (cxt, index) {
            final message = messages[index].data();
            final nextMessage =
                index + 1 < messages.length ? messages[index + 1].data() : null;
            final currentMessageUserId = message['username'];
            final nextMessageUserId =
                nextMessage != null ? nextMessage['username'] : null;
            final isSameUser = currentMessageUserId == nextMessageUserId;
            if (isSameUser) {
              return MessageBubble.next(
                message: message['text'],
                isMe: user.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: null,
                username: message['username'],
                message: message['text'],
                isMe: user.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
