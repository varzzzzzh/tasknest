
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tasknest/screens/auth/forget_password.dart';
import 'package:tasknest/screens/roles/role_selection.dart';
import 'package:tasknest/screens/student/dashboard/student_dashboard.dart';
import 'package:tasknest/screens/teacher/dashboard/teacher_dashboard.dart';

import 'package:tasknest/utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _navigateBasedOnRole(String uid) async {
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    // Default values if document doesn't exist or fields are missing
    final role = userDoc.get('role') ?? 'student'; // Default role
    final profileComplete = userDoc.get('profileComplete') ?? false; // Default false

    if (!mounted) return;

    if (!profileComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      }
    }
  } catch (e) {
    debugPrint('Error navigating based on role: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }
}

  Future<void> signInWithGoogle() async {
    try {
      if (!mounted) return;
      
      setState(() => _isLoading = true);
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Navigate based on user role
      await _navigateBasedOnRole(userCredential.user!.uid);

    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Google sign-in failed. Please try again.';
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> _login() async {
    if (!mounted) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (!_isValidPassword(password)) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, 
            password: password
          );

      if (userCredential.user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Navigate based on user role
      await _navigateBasedOnRole(userCredential.user!.uid);

    } on FirebaseAuthException catch (e) {
      debugPrint('Login Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred.';
        });
      }
    }
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
              // const SizedBox(height: 20),
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
                    'Sign In',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
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
                  icon: const Icon(FluentIcons.mail_24_regular, 
                      color: AppColors.gray),
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
                obscureText: _obscureText,
                decoration: _inputDecoration(
                  hint: 'Enter your password',
                  icon: const Icon(FluentIcons.lock_closed_24_regular, 
                      color: AppColors.gray),
                  suffix: IconButton(
                    icon: Icon(
                      _obscureText 
                          ? FluentIcons.eye_off_24_regular 
                          : FluentIcons.eye_24_regular,
                      color: AppColors.gray,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        'Remember me',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.gray),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Log In',
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
                    "Don't have an account?",
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: _isLoading 
                        ? null 
                        : () => Get.toNamed("/register"),
                    child: Text(
                      'Sign Up',
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