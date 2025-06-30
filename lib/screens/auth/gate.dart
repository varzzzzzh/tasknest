// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'package:tasknest/screens/auth/login.dart';
// import 'package:tasknest/screens/home.dart';
// import 'package:tasknest/screens/roles/role_selection.dart';

// class Gate extends StatelessWidget {
//   const Gate({super.key});

//   Future<DocumentSnapshot> _getUserProfile(String uid) async {
//     try {
//       return await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();
//     } catch (e) {
//       debugPrint('Error fetching user profile: $e');
//       rethrow;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, authSnapshot) {

//           if (authSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!authSnapshot.hasData || authSnapshot.data == null) {
//             return const LoginScreen(key: Key('login_screen'));
//           }

    
//           return FutureBuilder<DocumentSnapshot>(
//             future: _getUserProfile(authSnapshot.data!.uid),
//             builder: (context, profileSnapshot) {
//               if (profileSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (profileSnapshot.hasError) {
//                 return Center(
//                   child: Text('Error: ${profileSnapshot.error}'),
//                 );
//               }

//               final userData = profileSnapshot.data?.data() as Map<String, dynamic>?;

//               if (userData?['profileComplete'] != true) {
//                 return const RoleSelectionScreen(key: Key('role_selection_screen'));
//               }

           
//               return HomeScreen(key: Key('home_screen'));
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasknest/screens/auth/login.dart';
import 'package:tasknest/screens/roles/role_selection.dart';
import 'package:tasknest/screens/teacher/dashboard/teacher_dashboard.dart';
import 'package:tasknest/screens/student/dashboard/student_dashboard.dart';

class Gate extends StatelessWidget {
  const Gate({super.key});

  Future<DocumentSnapshot> _getUserProfile(String uid) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $message',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          // Handle auth state loading
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }

          // No user logged in
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const LoginScreen(key: Key('login_screen'));
          }

          // User is logged in, fetch their profile
          return FutureBuilder<DocumentSnapshot>(
            future: _getUserProfile(authSnapshot.data!.uid),
            builder: (context, profileSnapshot) {
              // Handle profile loading
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoading();
              }

              // Handle profile errors
              if (profileSnapshot.hasError) {
                return _buildError(profileSnapshot.error.toString());
              }

              final userData = profileSnapshot.data?.data() as Map<String, dynamic>?;

              // If no profile data exists or profile isn't complete
              if (userData == null || userData['profileComplete'] != true) {
                return const RoleSelectionScreen(key: Key('role_selection_screen'));
              }

              // Route based on user role
              switch (userData['role']) {
                case 'teacher':
                  return const TeacherDashboard(key: Key('teacher_dashboard'));
                case 'student':
                  return const StudentDashboard(key: Key('student_dashboard'));
                default:
                  return _buildError('Invalid user role');
              }
            },
          );
        },
      ),
    );
  }
}