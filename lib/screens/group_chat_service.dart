// // ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GroupChatService {
  final String gymName;
  final String chatRoomId;

  GroupChatService({required this.gymName, required this.chatRoomId});

  Future<void> sendMessage(String messageText, String sender) async {
    try {
      await FirebaseFirestore.instance
          .collection('Gyms')
          .doc(gymName)
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': messageText,
        'sender': sender,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }
}
