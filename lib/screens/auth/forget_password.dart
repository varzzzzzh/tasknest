import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:tasknest/utils/app_text_theme.dart';
import 'package:tasknest/utils/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link has been sent to your email. Please check your inbox."),
          backgroundColor: Colors.green,
        ),
      );
       
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
          
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
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
        // fillColor: AppColors.background,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
        border: Theme.of(context).inputDecorationTheme.border,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(25.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Reset Password",
              style: CustomTextStyle.titleLarge(
                context,
              ).copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            const Text(
              'Enter your email to reset your password.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // TextField(
            //   controller: emailController,
            //   decoration: const InputDecoration(
            //     labelText: 'Email',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration(
                hint: 'Email',
                icon: const Icon(
                  FluentIcons.mail_24_regular,
                  color: AppColors.gray,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: passwordReset,
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
