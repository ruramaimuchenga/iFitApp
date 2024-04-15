import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendMessage(String gymName, String chatRoomId, String sender, String message) async {
  try {
    await FirebaseFirestore.instance
        .collection('Gyms')
        .doc(gymName)
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'sender': sender,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(), // You can use server timestamp to order messages
    });
  } catch (e) {
    print('Error sending message: $e');
    // Handle error as needed
  }
}