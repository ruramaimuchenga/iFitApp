


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_signin/screens/generate_form.dart';

class WorkoutPlanPage extends StatelessWidget {
  final String email;

  const WorkoutPlanPage({required this.email, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
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
                          return WorkoutPlanTile(
                            email: email,
                            exercise: exercise,
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('No workout plan data available'),
                      );
                    }
                  }
                  return const Center(
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
        label: const Text('Add New Exercise'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    String? selectedExercise;
    TextEditingController timeController = TextEditingController();
    TextEditingController repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('equipment').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var exerciseList = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
                    return DropdownButton<String>(
                      hint: const Text('Choose Exercise'),
                      value: selectedExercise,
                      onChanged: (value) {
                        selectedExercise = value;
                      },
                      items: exerciseList.map((exercise) => DropdownMenuItem<String>(
                          value: exercise,
                          child: Text(exercise),
                      )).toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Time (minutes)'),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedExercise == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select an exercise")),
                  );
                  return;
                }

                String timeText = timeController.text;
                String repsText = repsController.text;

                int time = int.tryParse(timeText) ?? 0;
                int reps = int.tryParse(repsText) ?? 0;

                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .update({
                      'workout_plan': FieldValue.arrayUnion([
                        {
                          'name': selectedExercise,
                          'time': time,
                          'reps': reps,
                        }
                      ]),
                    });

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class WorkoutPlanTile extends StatelessWidget {
  final String email;
  final Map<String, dynamic> exercise;

  const WorkoutPlanTile({
    required this.email,
    required this.exercise,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = exercise['name'] ?? 'Unnamed Exercise';
    final int time = exercise['time'] ?? 0;
    final int reps = exercise['reps'] ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteExercise(context),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $time mins'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => _updateField(context, 'time', time - 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _updateField(context, 'time', time + 1),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reps: ${reps == 0 ? "" : reps}'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => _updateField(context, 'reps', reps - 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _updateField(context, 'reps', reps + 1),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteExercise(BuildContext context) {
    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(email);

    userDoc.update({
      'workout_plan': FieldValue.arrayRemove([exercise]),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise deleted')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    });
  }

  void _updateField(BuildContext context, String field, int newValue) {
    if (newValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Values cannot be negative'),
        ),
      );
      return;
    }

    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(email);

    userDoc.get().then((doc) {
      if (doc.exists) {
        var workoutPlan = doc['workout_plan'] as List;

        int index = workoutPlan.indexOf(exercise);

        if (index >= 0) {
          workoutPlan[index][field] = newValue;

          userDoc.update({
            'workout_plan': workoutPlan,
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Updated successfully')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Update failed: $error')),
            );
          });
        }
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching document: $error')),
      );
    });
  }
}
