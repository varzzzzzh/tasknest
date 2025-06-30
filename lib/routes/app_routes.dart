import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasknest/screens/auth/forget_password.dart';
import 'package:tasknest/screens/auth/gate.dart';
import 'package:tasknest/screens/auth/login.dart';
import 'package:tasknest/screens/auth/singup.dart';
import 'package:tasknest/screens/home.dart';
import 'package:tasknest/screens/roles/role_selection.dart';
import 'package:tasknest/screens/student/dashboard/student_dashboard.dart';
import 'package:tasknest/screens/student/profile/profile_setup_page.dart';

import 'package:tasknest/screens/teacher/dashboard/teacher_dashboard.dart';
import 'package:tasknest/screens/teacher/profile/profile_setup_page.dart';


class AppRoutes {
  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => Scaffold(
      body: Center(child: Text('Page not found')),
    ),
  );

  static final routes = [
  
    GetPage(
      name: '/gate',
      page: () => Gate(), 
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/register',
      page: () => SignUpScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/forget-password',
      page: () => ForgotPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    

    GetPage(
      name: '/role-selection',
      page: () => RoleSelectionScreen(),
      transition: Transition.fadeIn,
    ),
    

    GetPage(
      name: '/teacher-profile-setup',
      page: () => TeacherProfileSetupPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/student-profile-setup',
      page: () => StudentProfileSetupPage(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: '/home',
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
 
    GetPage(
      name: '/teacher-dashboard',
      page: () => TeacherDashboard(),
      transition: Transition.fadeIn,
    ),
     GetPage(
      name: '/student-dashboard',
      page: () => StudentDashboard(),
      transition: Transition.fadeIn,
    ),
  ];
}