

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'GroupChatRoom.dart';
import 'equipment_availability_page.dart';
import 'membership.dart';
import 'progress.dart';
import 'workout_plan.dart';

class DashboardScreen extends StatelessWidget {
  final String email;

  const DashboardScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: getUserField(email, 'first_name'),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String username = snapshot.data.toString();
                    return Text(
                      "Welcome, $username!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
              buildCard(
                icon: Icons.fitness_center,
                title: "Custom Workout Plan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutPlanPage(email: email),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.timeline,
                title: "Progress Summary",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgressPage(email: email),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.list_alt_outlined,
                title: "Gym Equipment Availability",
                onTap: () {
                  var gymName = getGym(email);
                  checkString(context, gymName);
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.chat,
                title: "Chat Room",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatRoom(
                        chatRoomId: 'JjU7eCLofKEZVoODoBUT',
                        chatRoomTitle: 'iFit Studio Chat Room',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.add_circle_outline,
                title: "Add Workout Details",
                onTap: () {},
              ),
              const SizedBox(height: 20),
              buildCard(
                icon: Icons.bluetooth,
                title: "Go into Watch Mode",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getUserField(String userId, String fieldName) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('Users');
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

  Future<String> getGym(String email) async {
    var gymName = '';
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    var doc = await users.doc(email).get();
    if (doc.exists) {
      Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
      if (map.containsKey('membership')) {
        gymName = map['membership']['gym'];
      }
    }
    return gymName;
  }

  void checkString(BuildContext context, Future<String> futureValue) async {
    String value = await futureValue;
    if (value.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Membership(email: email),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EquipmentAvailabilityPage(gym: value),
        ),
      );
    }
  }
}

