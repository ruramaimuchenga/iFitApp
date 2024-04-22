
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
// import 'package:firebase_signin/screens/generate_form.dart';

// class WorkoutPlanPage extends StatelessWidget {
//   final String email;

//   const WorkoutPlanPage({Key? key, required this.email}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Workout Plan'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             buildCard(
//               icon: Icons.auto_awesome,
//               title: "Generate New Plan",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => GenerateForm(email: email),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: StreamBuilder<DocumentSnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('Users')
//                     .doc(email)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     var userData = snapshot.data!.data();
//                     if (userData != null &&
//                         userData is Map<String, dynamic> &&
//                         userData.containsKey('workout_plan')) {
//                       var workoutPlan = userData['workout_plan'];
//                       return ListView.builder(
//                         itemCount: workoutPlan.length,
//                         itemBuilder: (context, index) {
//                           var exercise = workoutPlan[index];
//                           var name = exercise['name'];
//                           var time = exercise['time'].toString();
//                           var reps = exercise['reps'] == 0
//                               ? ''
//                               : exercise['reps'].toString();
//                           return WorkoutPlanTile(
//                             name: name,
//                             time: time,
//                             reps: reps,
//                           );
//                         },
//                       );
//                     } else {
//                       return Center(
//                         child: Text('No workout plan data available'),
//                       );
//                     }
//                   }
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           _showAddExerciseDialog(context);
//         },
//         label: Text('Add New Exercise'),
//         icon: Icon(Icons.add),
//         tooltip: 'Add New Exercise', // Adding tooltip for accessibility
//       ),
//     );
//   }

//   void _showAddExerciseDialog(BuildContext context) {
//     TextEditingController exerciseController = TextEditingController();
//     TextEditingController timeController = TextEditingController();
//     TextEditingController repsController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Add New Exercise"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: exerciseController,
//                 decoration: InputDecoration(labelText: 'Exercise Name'),
//               ),
//               TextField(
//                 controller: timeController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Time (minutes)'),
//               ),
//               TextField(
//                 controller: repsController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Reps'),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // You can add the exercise here
//                 // Retrieve values from controllers and perform necessary actions
//                 String exerciseName = exerciseController.text;
//                 String time = timeController.text;
//                 String reps = repsController.text;
//                 // Add your logic to save the exercise
//                 Navigator.of(context).pop();
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class WorkoutPlanTile extends StatelessWidget {
//   final String name;
//   final String time;
//   final String reps;

//   const WorkoutPlanTile({
//     required this.name,
//     required this.time,
//     required this.reps,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//         name,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Time: $time'),
//           Text('Reps: ${reps == '0' ? '' : reps}'),
//         ],
//       ),
//     );
//   }
// }



































import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signin/screens/generate_form.dart';

import '../reusable_widgets/reusable_widget.dart';

class WorkoutPlanPage extends StatelessWidget {
  final String email;

  const WorkoutPlanPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildCard(
              icon: Icons.auto_awesome,
              title: "Generate New Plan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenerateForm(email: email),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var userData = snapshot.data!.data();
                    if (userData != null &&
                        userData is Map<String, dynamic> &&
                        userData.containsKey('workout_plan')) {
                      var workoutPlan = userData['workout_plan'] as List<dynamic>;
                      return ListView.builder(
                        itemCount: workoutPlan.length,
                        itemBuilder: (context, index) {
                          var exercise = workoutPlan[index];
                          var name = exercise['name'];
                          var time = exercise['time'].toString();
                          var reps = exercise['reps'] == 0
                              ? ''
                              : exercise['reps'].toString();
                          return WorkoutPlanTile(
                            name: name,
                            time: time,
                            reps: reps,
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text('No workout plan data available'),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddExerciseDialog(context);
        },
        label: Text('Add New Exercise'),
        icon: Icon(Icons.add),
        tooltip: 'Add New Exercise',
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    TextEditingController exerciseController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    TextEditingController repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
              ),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Time (minutes)'),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Reps'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the exercise to Firestore
                String exerciseName = exerciseController.text;
                String time = timeController.text;
                String reps = repsController.text;

                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .update({
                      'workout_plan': FieldValue.arrayUnion([
                        {
                          'name': exerciseName,
                          'time': int.tryParse(time) ?? 0,
                          'reps': int.tryParse(reps) ?? 0,
                        }
                      ])
                    });

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class WorkoutPlanTile extends StatelessWidget {
  final String name;
  final String time;
  final String reps;

  const WorkoutPlanTile({
    required this.name,
    required this.time,
    required this.reps,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: $time'),
          Text('Reps: ${reps == '0' ? '' : reps}'),
        ],
      ),
    );
  }
}
