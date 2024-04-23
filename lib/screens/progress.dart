// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ProgressPage extends StatelessWidget {
//   final String email;

//   const ProgressPage({Key? key, required this.email}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Progress'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('Users')
//               .doc(email)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               var userData = snapshot.data!.data();
//               if (userData != null &&
//                   userData is Map<String, dynamic> &&
//                   userData.containsKey('progress')) {
//                 var progress = userData['progress'][0];
//                 print(progress);
//                 return ListView.builder(
//                   itemCount: progress.length,
//                   itemBuilder: (context, index) {
//                     var date = progress.keys.toList()[index];
//                     var exercises = progress[date];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date: $date',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const ClampingScrollPhysics(),
//                           itemCount: exercises.length,
//                           itemBuilder: (context, index) {
//                             var exercise = exercises[index];
//                             var name = exercise['exercise'];
//                             var time = exercise['time'].toString();
//                             var reps = exercise['reps'] == 0
//                                 ? ''
//                                 : exercise['reps'].toString();
//                             print(name);
//                             print(time);
//                             print(reps);
//                             return ProgressTile(
//                               name: name,
//                               time: time,
//                               reps: reps,
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                       ],
//                     );
//                   },
//                 );
//               } else {
//                 return const Center(
//                   child: Text('No progress data available'),
//                 );
//               }
//             }
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class ProgressTile extends StatelessWidget {
//   final String name;
//   final String time;
//   final String reps;

//   const ProgressTile({
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


































//anushka code whaapp
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
                          itemBuilder: (context, index) {
                            var exercise = exercises[index];
                            var name = exercise['exercise'];
                            var time = exercise['time'].toString();
                            var reps = exercise['reps'] == 0
                                ? 'Not Applicable'
                                : exercise['reps'].toString();
                            return ProgressTile(
                              name: name,
                              time: time,
                              reps: reps,
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
    );
  }
}

class ProgressTile extends StatelessWidget {
  final String name;
  final String time;
  final String reps;

  const ProgressTile({
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