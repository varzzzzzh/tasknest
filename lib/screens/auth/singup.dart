
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import 'package:flutter/foundation.dart';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:tasknest/screens/roles/role_selection.dart';
// import 'package:tasknest/screens/student/profile/profile_setup_page.dart';
// import 'package:tasknest/screens/teacher/profile/profile_setup_page.dart';
// import 'package:tasknest/utils/colors.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   String? _errorMessage;
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//   String? _selectedRole; // 'teacher' or 'student'
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }
// Future<void> signInWithGoogle() async {
//   try {
//     setState(() => _isLoading = true);
    
//     // For web - use the new Google Identity Services
//     if (kIsWeb) {
//       final GoogleAuthProvider authProvider = GoogleAuthProvider();
//       final UserCredential userCredential = 
//           await FirebaseAuth.instance.signInWithPopup(authProvider);
      
//       await _handleUserSignIn(userCredential);
//       return;
//     }
    
//     // For mobile - use traditional approach
//     final GoogleSignInAccount? googleUser = await GoogleSignIn(
//       clientId: '663828726292-qc0185o4vcdgcf9h3f3h4o22jl5ha007.apps.googleusercontent.com',
//     ).signIn();
    
//     if (googleUser == null) return;
    
//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
    
//     final UserCredential userCredential = 
//         await FirebaseAuth.instance.signInWithCredential(credential);
    
//     await _handleUserSignIn(userCredential);
//   } catch (e) {
//     setState(() => _errorMessage = 'Google sign-in failed. Please try again.');
//     debugPrint('Google Sign-In Error: $e');
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }

// Future<void> _handleUserSignIn(UserCredential userCredential) async {
//   if (userCredential.user != null) {
//     final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    
//     if (isNewUser) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'name': userCredential.user!.displayName,
//         'email': userCredential.user!.email,
//         'role': null,
//         'profileComplete': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }
    
//     Get.offAll(() => const RoleSelectionScreen());
//   }
// }
 
//   // Future<void> signInWithGoogle() async {
//   //   try {
//   //     setState(() => _isLoading = true);
      
//   //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//   //     if (googleUser == null) return;

//   //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//   //     final credential = GoogleAuthProvider.credential(
//   //       accessToken: googleAuth.accessToken,
//   //       idToken: googleAuth.idToken,
//   //     );

//   //     final UserCredential userCredential = 
//   //         await FirebaseAuth.instance.signInWithCredential(credential);
      
//   //     // After Google sign in, navigate to role selection
//   //     if (userCredential.user != null) {
//   //       Get.offAll(() => const RoleSelectionScreen());
//   //     }
//   //   } catch (e) {
//   //     setState(() => _errorMessage = 'Google sign-in failed. Please try again.');
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }

//   bool _isValidEmail(String email) {
//     const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
//     return RegExp(pattern).hasMatch(email);
//   }

//   String _checkPasswordStrength(String password) {
//     if (password.length < 6) return 'Too short';
//     if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Include uppercase letter';
//     if (!RegExp(r'[a-z]').hasMatch(password)) return 'Include lowercase letter';
//     if (!RegExp(r'[0-9]').hasMatch(password)) return 'Include number';
//     return 'Strong';
//   }

//   Future<void> _signUp() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;
//     final confirmPassword = _confirmPasswordController.text;
//     final name = _nameController.text.trim();

//     if (name.isEmpty) {
//       setState(() => _errorMessage = 'Please enter your name');
//       return;
//     }

//     if (!_isValidEmail(email)) {
//       setState(() => _errorMessage = 'Please enter a valid email address.');
//       return;
//     }

//     if (password != confirmPassword) {
//       setState(() => _errorMessage = 'Passwords do not match.');
//       return;
//     }

//     if (_selectedRole == null) {
//       setState(() => _errorMessage = 'Please select your role');
//       return;
//     }

//     final strength = _checkPasswordStrength(password);
//     if (strength != 'Strong') {
//       setState(() => _errorMessage = 'Password strength: $strength');
//       return;
//     }

//     setState(() {
//       _errorMessage = null;
//       _isLoading = true;
//     });

//     try {
//       // Create user in Firebase Auth
//       final UserCredential userCredential = 
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Save additional user data to Firestore
//       if (userCredential.user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .set({
//           'name': name,
//           'email': email,
//           'role': _selectedRole,
//            'profileComplete': null,
//           'createdAt': FieldValue.serverTimestamp(),
//         });

//         // Navigate to appropriate dashboard based on role
//         if (_selectedRole == 'teacher') {
//           Get.offAll(() => const TeacherProfileSetupPage());
//         } else {
//           Get.offAll(() => const StudentProfileSetupPage());
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       setState(() => _errorMessage = e.message ?? 'Sign-up failed. Try again.');
//     } catch (e) {
//       setState(() => _errorMessage = 'An unexpected error occurred. Try again.');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildRoleSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Select Your Role',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: _RoleSelectionCard(
//                 icon: FluentIcons.person_24_regular,
//                 title: 'Teacher',
//                 isSelected: _selectedRole == 'teacher',
//                 onTap: () => setState(() => _selectedRole = 'teacher'),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _RoleSelectionCard(
//                 icon: FluentIcons.person_24_regular,
//                 title: 'Student',
//                 isSelected: _selectedRole == 'student',
//                 onTap: () => setState(() => _selectedRole = 'student'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Image.asset('assets/images/logobg.png', height: 150),
//               ),
//               Transform.translate(
//                 offset: const Offset(0, -25),
//                 child: Center(
//                   child: Text(
//                     'Sign Up',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.black,
//                         ),
//                   ),
//                 ),
//               ),

//               // Name Field
//               const Text(
//                 'Full Name',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your full name',
//                   prefixIcon: const Icon(FluentIcons.person_24_regular, color: AppColors.gray),
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               const Text(
//                 'Email',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   hintText: 'Email',
//                   prefixIcon: const Icon(FluentIcons.mail_24_regular, color: AppColors.gray),
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               const Text(
//                 'Password',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: !_isPasswordVisible,
//                 decoration: InputDecoration(
//                   hintText: 'Password',
//                   prefixIcon: const Icon(FluentIcons.lock_closed_24_regular, color: AppColors.gray),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible ? FluentIcons.eye_24_regular : FluentIcons.eye_off_24_regular,
//                       color: AppColors.gray,
//                     ),
//                     onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
//                   ),
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               const Text(
//                 'Confirm Password',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: !_isConfirmPasswordVisible,
//                 decoration: InputDecoration(
//                   hintText: 'Confirm Password',
//                   prefixIcon: const Icon(FluentIcons.lock_closed_24_regular, color: AppColors.gray),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isConfirmPasswordVisible ? FluentIcons.eye_24_regular : FluentIcons.eye_off_24_regular,
//                       color: AppColors.gray,
//                     ),
//                     onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
//                   ),
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               _buildRoleSelector(),

//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _signUp,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text('Sign Up'),
//                 ),
//               ),

//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: AppColors.error),
//                   ),
//                 ),

//               const SizedBox(height: 32),
//               Row(
//                 children: [
//                   Expanded(child: Divider(color: Colors.grey[300])),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text('or Continue with'),
//                   ),
//                   Expanded(child: Divider(color: Colors.grey[300])),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               Center(
//                 child: IconButton(
//                   icon: Image.asset('assets/google.png', height: 30),
//                   onPressed: _isLoading ? null : signInWithGoogle,
//                 ),
//               ),
//               const SizedBox(height: 12),
            
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Already have an account?"),
//                   TextButton(
//                     onPressed: () => Get.back(),
//                     child: const Text(
//                       'Log In',
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RoleSelectionCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _RoleSelectionCard({
//     required this.icon,
//     required this.title,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : Colors.transparent,
//             width: 2,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 32, color: isSelected ? AppColors.primary : Colors.grey),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isSelected ? AppColors.primary : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tasknest/screens/roles/role_selection.dart';
import 'package:tasknest/screens/student/profile/profile_setup_page.dart';
import 'package:tasknest/screens/teacher/profile/profile_setup_page.dart';
import 'package:tasknest/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedRole; // 'teacher' or 'student'
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      
      // For web - use the new Google Identity Services
      if (kIsWeb) {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final UserCredential userCredential = 
            await FirebaseAuth.instance.signInWithPopup(authProvider);
        
        await _handleUserSignIn(userCredential);
        return;
      }
      
      // For mobile - use traditional approach
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '663828726292-qc0185o4vcdgcf9h3f3h4o22jl5ha007.apps.googleusercontent.com',
      ).signIn();
      
      if (googleUser == null) return;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      await _handleUserSignIn(userCredential);
    } catch (e) {
      setState(() => _errorMessage = 'Google sign-in failed. Please try again.');
      debugPrint('Google Sign-In Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUserSignIn(UserCredential userCredential) async {
    if (userCredential.user != null) {
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': null,
          'profileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      Get.offAll(() => const RoleSelectionScreen());
    }
  }

  bool _isValidEmail(String email) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email);
  }

  String _checkPasswordStrength(String password) {
    if (password.length < 6) return 'Too short';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Include uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Include lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Include number';
    return 'Strong';
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Please select your role');
      return;
    }

    final strength = _checkPasswordStrength(password);
    if (strength != 'Strong') {
      setState(() => _errorMessage = 'Password strength: $strength');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = 
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name,
          'email': email,
          'role': _selectedRole,
          'profileComplete': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Navigate to appropriate dashboard based on role
        if (_selectedRole == 'teacher') {
          Get.offAll(() => const TeacherProfileSetupPage());
        } else {
          Get.offAll(() => const StudentProfileSetupPage());
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Sign-up failed. Try again.');
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRoleSelector() {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleSelectionCard(
                icon: FluentIcons.person_24_regular,
                title: 'Teacher',
                isSelected: _selectedRole == 'teacher',
                onTap: () => setState(() => _selectedRole = 'teacher'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleSelectionCard(
                icon: FluentIcons.person_24_regular,
                title: 'Student',
                isSelected: _selectedRole == 'student',
                onTap: () => setState(() => _selectedRole = 'student'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required Widget icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon,
      suffixIcon: suffix,
      filled: true,
      hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
      border: Theme.of(context).inputDecorationTheme.border,
      enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
      focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildSocialButton({
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Image.asset(imagePath, height: 24, width: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logobg.png', 
                  height: 150,
                  fit: BoxFit.contain
                ),
              ),
      
              Transform.translate(
                offset: const Offset(0, -25),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                'Full Name',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hint: 'Enter your full name',
                  icon: const Icon(FluentIcons.person_24_regular, color: AppColors.gray),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Email',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration(
                  hint: 'Enter your email',
                  icon: const Icon(FluentIcons.mail_24_regular, color: AppColors.gray),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
              Text(
                'Password',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _inputDecoration(
                  hint: 'Enter your password',
                  icon: const Icon(FluentIcons.lock_closed_24_regular, color: AppColors.gray),
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible 
                          ? FluentIcons.eye_24_regular 
                          : FluentIcons.eye_off_24_regular,
                      color: AppColors.gray,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Confirm Password',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: _inputDecoration(
                  hint: 'Confirm your password',
                  icon: const Icon(FluentIcons.lock_closed_24_regular, color: AppColors.gray),
                  suffix: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible 
                          ? FluentIcons.eye_24_regular 
                          : FluentIcons.eye_off_24_regular,
                      color: AppColors.gray,
                    ),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildRoleSelector(),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: _buildSocialButton(
                  imagePath: 'assets/google.png',
                  onPressed: signInWithGoogle,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: _isLoading 
                        ? null 
                        : () => Get.back(),
                    child: Text(
                      'Log In',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectionCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}