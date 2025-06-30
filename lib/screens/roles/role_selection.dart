// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:tasknest/utils/colors.dart';


// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Define reusable text styles
//     final TextStyle headlineStyle = GoogleFonts.outfit(
//       fontSize: 22,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     );

//     final TextStyle cardTitleStyle = GoogleFonts.outfit(
//       fontSize: 18,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     );

//     final TextStyle cardDescriptionStyle = GoogleFonts.outfit(
//       fontSize: 14,
//       color: Colors.grey[600],
//     );

//     return Scaffold(
      
//       // appBar: AppBar(
//       //   title: const Text('Select Your Role'),
//       //   centerTitle: true,
//       //   elevation: 0,
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Are you a Staff Member or Student?',
//               style: headlineStyle,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),
            
//             // Teacher Option
//             _RoleCard(
//               key: const Key('teacher_role_card'),
//               icon: Icons.school_outlined,
//               title: 'Staff / Teacher',
//               description: 'Create assignments, track submissions, and manage classes',
//               titleStyle: cardTitleStyle,
//               descriptionStyle: cardDescriptionStyle,
//               onTap: () => Get.toNamed('/teacher-profile-setup'),
//             ),
            
//             const SizedBox(height: 20),
            
//             // Student Option
//             _RoleCard(
//               key: const Key('student_role_card'),
//               icon: Icons.person_outline,
//               title: 'Student',
//               description: 'View assignments, submit work, and track your progress',
//               titleStyle: cardTitleStyle,
//               descriptionStyle: cardDescriptionStyle,
//               onTap: () => Get.toNamed('/student-profile-setup'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _RoleCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final TextStyle titleStyle;
//   final TextStyle descriptionStyle;
//   final VoidCallback onTap;

//   const _RoleCard({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.titleStyle,
//     required this.descriptionStyle,
//     required this.onTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             children: [
//               // Icon Container
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                     color: AppColors.tertiary.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 28,
//                   color: AppColors.primary,
//                 ),
//               ),
              
//               const SizedBox(width: 16),
              
//               // Text Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: titleStyle),
//                     const SizedBox(height: 4),
//                     Text(description, style: descriptionStyle),
//                   ],
//                 ),
//               ),
              
//               // Chevron Icon
//               Icon(
//                 Icons.chevron_right,
//                 size: 24,
//                 color: Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:tasknest/utils/colors.dart';

// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TextStyle headlineStyle = GoogleFonts.outfit(
//       fontSize: 22,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     );

//     final TextStyle cardTitleStyle = GoogleFonts.outfit(
//       fontSize: 18,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     );

//     final TextStyle cardDescriptionStyle = GoogleFonts.outfit(
//       fontSize: 14,
//       color: Colors.grey[600],
//     );

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Are you a Staff Member or Student?',
//               style: headlineStyle,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),

//             // Teacher Option
//             _RoleCard(
//               key: const Key('teacher_role_card'),
//               icon: Icons.school_outlined,
//               title: 'Staff / Teacher',
//               description: 'Create assignments, track submissions, and manage classes',
//               titleStyle: cardTitleStyle,
//               descriptionStyle: cardDescriptionStyle,
//               onTap: () {
//                 // Navigate to teacher profile setup
//                 Get.toNamed('/teacher-profile-setup', arguments: {'role': 'teacher'});
//               },
//             ),

//             const SizedBox(height: 20),

//             // Student Option
//             _RoleCard(
//               key: const Key('student_role_card'),
//               icon: Icons.person_outline,
//               title: 'Student',
//               description: 'View assignments, submit work, and track your progress',
//               titleStyle: cardTitleStyle,
//               descriptionStyle: cardDescriptionStyle,
//               onTap: () {
//                 // Navigate to student profile setup
//                 Get.toNamed('/student-profile-setup', arguments: {'role': 'student'});
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _RoleCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final TextStyle titleStyle;
//   final TextStyle descriptionStyle;
//   final VoidCallback onTap;

//   const _RoleCard({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.titleStyle,
//     required this.descriptionStyle,
//     required this.onTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.tertiary.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 28,
//                   color: AppColors.primary,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title, style: titleStyle),
//                     const SizedBox(height: 4),
//                     Text(description, style: descriptionStyle),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 size: 24,
//                 color: Colors.grey[600],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasknest/screens/student/dashboard/student_dashboard.dart';
import 'package:tasknest/screens/teacher/dashboard/teacher_dashboard.dart';
import 'package:tasknest/utils/colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final profileComplete = data?['profileComplete'] ?? false;
        final role = data?['role']?.toString().toLowerCase();

        if (profileComplete) {
          if (role == 'teacher') {
            Get.offAll(() => const TeacherDashboard());
          } else if (role == 'student') {
            Get.offAll(() => const StudentDashboard());
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking profile status: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final TextStyle headlineStyle = GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final TextStyle cardTitleStyle = GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final TextStyle cardDescriptionStyle = GoogleFonts.outfit(
      fontSize: 14,
      color: Colors.grey[600],
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you a Staff Member or Student?',
              style: headlineStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Teacher Option
            _RoleCard(
              key: const Key('teacher_role_card'),
              icon: Icons.school_outlined,
              title: 'Staff / Teacher',
              description: 'Create assignments, track submissions, and manage classes',
              titleStyle: cardTitleStyle,
              descriptionStyle: cardDescriptionStyle,
              onTap: () async {
                await _saveRoleAndNavigate('teacher');
              },
            ),

            const SizedBox(height: 20),

            // Student Option
            _RoleCard(
              key: const Key('student_role_card'),
              icon: Icons.person_outline,
              title: 'Student',
              description: 'View assignments, submit work, and track your progress',
              titleStyle: cardTitleStyle,
              descriptionStyle: cardDescriptionStyle,
              onTap: () async {
                await _saveRoleAndNavigate('student');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRoleAndNavigate(String role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'role': role,
            'profileComplete': false, // Will be set to true after profile setup
          }, SetOptions(merge: true));

      if (role == 'teacher') {
        Get.toNamed('/teacher-profile-setup');
      } else {
        Get.toNamed('/student-profile-setup');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save role: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    const SizedBox(height: 4),
                    Text(description, style: descriptionStyle),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}