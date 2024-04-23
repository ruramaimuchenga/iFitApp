






//kinda working but the buttons arent

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  final String email;

  const ProgressPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  userData.containsKey('progress')) {
                var progress = userData['progress'];
                if (progress.isEmpty) {
                  return const Center(
                    child: Text('No progress data available'),
                  );
                }
                var firstProgress = progress[0];
                return ListView.builder(
                  itemCount: firstProgress.length,
                  itemBuilder: (context, index) {
                    var date = firstProgress.keys.toList()[index];
                    var exercises = firstProgress[date];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: $date',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: exercises.length,
                          itemBuilder: (context, subIndex) {
                            var exercise = exercises[subIndex];
                            return ProgressTile(
                              email: email,
                              date: date,
                              index: subIndex,
                              exercise: exercise,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No progress data available'),
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
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
                stream: FirebaseFirestore.instance
                    .collection('equipment')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var exerciseList = snapshot.data!.docs
                      .map((doc) => doc['name'] as String)
                      .toList();

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
                      'progress': FieldValue.arrayUnion([
                        {
                          'date': DateTime.now().toIso8601String(),
                          'exercise': selectedExercise,
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

class ProgressTile extends StatelessWidget {
  final String email;
  final String date;
  final int index;
  final Map<String, dynamic> exercise;

  const ProgressTile({
    required this.email,
    required this.date,
    required this.index,
    required this.exercise,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = exercise['exercise'];
    final int time = exercise['time'];
    final int reps = exercise['reps'] ?? 0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reps: $reps'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: () => _updateReps(context, reps - 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => _updateReps(context, reps + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateReps(BuildContext context, int newReps) {
    if (newReps < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reps cannot be negative')),
      );
      return;
    }

    num deltaReps = newReps - (exercise['reps'] ?? 0);
    int newTime = exercise['time'] + (2 * deltaReps);

    FirebaseFirestore.instance
        .collection('Users')
        .doc(email)
        .update({
          'progress': FieldValue.arrayUnion([
            {
              'date': date,
              'exercise': exercise['exercise'],
              'time': newTime,
              'reps': newReps,
            }
          ]),
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


