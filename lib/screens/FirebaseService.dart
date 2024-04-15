import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<dynamic> getUserField(String userId, String fieldName) async {
    try {
      CollectionReference usersCollection =
          _firestore.collection('Users');
      DocumentReference userDocRef = usersCollection.doc(userId);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      Map<String, dynamic>? userData =
          userDocSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey(fieldName)) {
        return userData[fieldName];
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user field: $e');
      return null;
    }
  }

  static Future<String> getGym(String email) async {
    var gymName = '';
    CollectionReference users = _firestore.collection('Users');
    var doc = await users.doc(email).get();
    if (doc.exists) {
      Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
      if (map.containsKey('membership')) {
        gymName = map['membership']['gym'];
      }
    }
    return gymName;
  }

  static Future<void> sendMessage(String gymName, String messageText, String senderId) async {
    try {
      await _firestore
        .collection('gyms')
        .doc(gymName)
        .collection('chatroom')
        .doc('groupchat')
        .collection('messages')
        .add({
          'text': messageText,
          'sender': senderId,
          'timestamp': FieldValue.serverTimestamp(),
        });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Add more methods as needed
}
