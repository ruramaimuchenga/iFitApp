import 'package:flutter/material.dart';

class AddWorkoutPage extends StatefulWidget {
  @override
  _AddWorkoutPageState createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  TextEditingController _exerciseNameController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _repsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _exerciseNameController,
              decoration: InputDecoration(labelText: 'Exercise Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Time (minutes)'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Reps'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validate and save the new workout data
                String exerciseName = _exerciseNameController.text.trim();
                int time = int.tryParse(_timeController.text.trim()) ?? 0;
                int reps = int.tryParse(_repsController.text.trim()) ?? 0;

                if (exerciseName.isNotEmpty && time > 0) {
                  // You can handle saving the workout data here
                  // For now, let's just navigate back to the previous screen
                  Navigator.pop(context);
                } else {
                  // Show an error message if any of the fields are empty or invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter valid workout details.'),
                    ),
                  );
                }
              },
              child: Text('Add Workout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers
    _exerciseNameController.dispose();
    _timeController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}
