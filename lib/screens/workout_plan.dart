
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'generate_form.dart';


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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: const CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading workout plan'),
                    );
                  }

                  if (snapshot.hasData) {
                    var userData = snapshot.data?.data() as Map<String, dynamic>?;
                    if (userData != null && userData.containsKey('workout_plan')) {
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
                    child: Text('No data found'),
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
        tooltip: 'Add New Exercise',
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseController,
                decoration: const InputDecoration(labelText: 'Exercise Name'),
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate inputs
                String exerciseName = exerciseController.text;
                int? time = int.tryParse(timeController.text);
                int? reps = int.tryParse(repsController.text);

                if (exerciseName.isEmpty || time == null || reps == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please provide valid input."),
                    ),
                  );
                  return;
                }

                // Add new exercise to Firestore
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .update({
                      'workout_plan': FieldValue.arrayUnion([
                        {
                          'name': exerciseName,
                          'time': time,
                          'reps': reps,
                        },
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

    return Card( // Use a Card to create a subtle border and shadow
      elevation: 2, // Light shadow for aesthetic appeal
      margin: const EdgeInsets.symmetric(vertical: 5), // Add space between tiles
      child: Padding( // Padding to make the content less cramped
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Corrected property name
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton( // Delete button
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _confirmDelete(context), // Call the delete confirmation dialog
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Corrected property name
              children: [
                Text('Time: $time mins'),
                Row( // Container for plus/minus buttons
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20), // Smaller icon
                      onPressed: () => _updateField(context, 'time', time - 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20), // Smaller icon
                      onPressed: () => _updateField(context, 'time', time + 1),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Corrected property name
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: const Text('Are you sure you want to delete this exercise?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Cancel the deletion
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _deleteExercise(context), // Delete if confirmed
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise(BuildContext context) {
    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(email);

    userDoc.update({
      'workout_plan': FieldValue.arrayRemove([exercise]), // Remove the exercise
    }).then((_) {
      Navigator.of(context).pop(); // Close the dialog after successful deletion
    });
  }

  void _updateField(BuildContext context, String field, int newValue) {
    if (newValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$field cannot be negative'),
        ),
      );
      return;
    }

    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(email);

    userDoc.update({
      'workout_plan': FieldValue.arrayRemove([exercise]),
    }).then((_) {
      exercise[field] = newValue;

      userDoc.update({
        'workout_plan': FieldValue.arrayUnion([exercise]),
      });
    });
  }
}






















