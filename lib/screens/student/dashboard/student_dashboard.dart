import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:tasknest/screens/student/profile/profile_setup_page.dart';
import 'package:tasknest/utils/colors.dart';
import 'package:tasknest/utils/app_text_theme.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  User? _user;
  Map<String, dynamic>? _studentData;
  List<String> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission for notifications');

        try {
          String? token = await _messaging.getToken();
          if (token != null && _user != null) {
            await _firestore.collection('students').doc(_user!.uid).update({
              'fcmToken': token,
            });
          }
        } catch (e) {
          print('Error getting FCM token: $e');
        }

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _loadUserData();
          Get.snackbar(
            message.notification?.title ?? 'New Notification',
            message.notification?.body ?? '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.primary,
            colorText: AppColors.white,
          );
        });
      }
    } catch (e) {
      print('Error setting up notifications: $e');
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _user = _auth.currentUser;

    if (_user != null) {
      try {
        // Load student data
        final doc =
            await _firestore.collection('students').doc(_user!.uid).get();
        if (doc.exists) {
          setState(() {
            _studentData = doc.data()!;
            // Handle both string and list cases for classes
            dynamic classesData = _studentData?['classes'];
            if (classesData is String) {
              _classes = [classesData]; // Convert string to single-item list
            } else if (classesData is List) {
              _classes = List<String>.from(classesData);
            } else {
              _classes = [];
            }
          });
        }

        // Count unread notifications

        setState(() {
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  void _showProfileDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.tertiary,
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _studentData?['name'] ?? 'No Name',
                              style: CustomTextStyle.titleLarge(
                                context,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Student',
                              style: CustomTextStyle.labelMedium(
                                context,
                              ).copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        FluentIcons.edit_12_filled,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        Get.to(
                          () => StudentProfileSetupPage(),
                        )?.then((_) => _loadUserData());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProfileItem(
                  'Register Number',
                  _studentData?['registerNumber']?.toString() ?? 'Not set',
                ),
                _buildProfileItem(
                  'Institution',
                  _studentData?['institution'] ?? 'Not set',
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Classes',
                  style: CustomTextStyle.labelMedium(
                    context,
                  ).copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: 8),
                if (_classes.isEmpty)
                  Text(
                    'No classes assigned',
                    style: CustomTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: AppColors.gray),
                  ),
                ..._classes
                    .map(
                      (cls) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          cls,
                          style: CustomTextStyle.bodyMedium(context),
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 24),
                // Add Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Get.back(); // Close the dialog
                      // Navigate to login screen or whatever is appropriate
                      // For example:
                      // Get.offAll(() => LoginScreen());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.sign_out_20_regular,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: CustomTextStyle.labelMedium(
                            context,
                          ).copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: CustomTextStyle.labelLarge(
                        context,
                      ).copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // void _showProfileDialog() {
  //   Get.dialog(
  //     Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       child: SingleChildScrollView(
  //         child: Container(
  //           padding: const EdgeInsets.all(24),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       CircleAvatar(
  //                         radius: 20,
  //                         backgroundColor: AppColors.tertiary,
  //                         child: Icon(
  //                           Icons.person,
  //                           size: 20,
  //                           color: AppColors.primary,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 16),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             _studentData?['name'] ?? 'No Name',
  //                             style: CustomTextStyle.titleLarge(
  //                               context,
  //                             ).copyWith(fontWeight: FontWeight.bold),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             'Student',
  //                             style: CustomTextStyle.labelMedium(
  //                               context,
  //                             ).copyWith(color: AppColors.gray),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   IconButton(
  //                     icon: Icon(Icons.edit, color: AppColors.primary),
  //                     onPressed: () {
  //                       Get.to(
  //                         () => StudentProfileSetupPage(),
  //                       )?.then((_) => _loadUserData());
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 24),
  //               _buildProfileItem(
  //                 'Register Number',
  //                 _studentData?['registerNumber']?.toString() ?? 'Not set',
  //               ),
  //               _buildProfileItem(
  //                 'Institution',
  //                 _studentData?['institution'] ?? 'Not set',
  //               ),
  //               const SizedBox(height: 16),
  //               Text(
  //                 'Your Classes',
  //                 style: CustomTextStyle.labelLarge(
  //                   context,
  //                 ).copyWith(fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 8),
  //               if (_classes.isEmpty)
  //                 Text(
  //                   'No classes assigned',
  //                   style: CustomTextStyle.bodyMedium(
  //                     context,
  //                   ).copyWith(color: AppColors.gray),
  //                 ),
  //               ..._classes
  //                   .map(
  //                     (cls) => Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 4),
  //                       child: Text(
  //                         cls,
  //                         style: CustomTextStyle.bodyMedium(context),
  //                       ),
  //                     ),
  //                   )
  //                   .toList(),
  //               const SizedBox(height: 24),
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   onPressed: () => Get.back(),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.primary,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Close',
  //                     style: CustomTextStyle.labelLarge(
  //                       context,
  //                     ).copyWith(color: AppColors.white),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CustomTextStyle.labelMedium(
              context,
            ).copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 4),
          Text(value, style: CustomTextStyle.bodyMedium(context)),
        ],
      ),
    );
  }

  void _showTaskSubmissionDialog(Map<String, dynamic> task) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final List<String> options =
        task['completionOption'] == 'Custom'
            ? List<String>.from(task['customOptions'] ?? [])
            : task['completionOption'] == 'Yes/No'
            ? ['Yes', 'No']
            : ['Completed', 'Not Completed'];

    String? selectedOption = options.isNotEmpty ? options[0] : null;
    bool isSubmitting = false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Task: ${task['title']}',
                    style: CustomTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (task['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        task['description'],
                        style: CustomTextStyle.bodyMedium(context),
                      ),
                    ),
                  Text(
                    'Completion Options',
                    style: CustomTextStyle.labelMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    value: selectedOption,
                    items:
                        options
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option,
                                  style: CustomTextStyle.bodyMedium(context),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      selectedOption = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an option';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.only(right: 8),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(FluentIcons.chevron_down_20_regular),
                      iconSize: 20,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return ElevatedButton(
                              onPressed:
                                  isSubmitting
                                      ? null
                                      : () async {
                                        if (formKey.currentState!.validate()) {
                                          setState(() => isSubmitting = true);
                                          try {
                                            final existingSubmission =
                                                await _firestore
                                                    .collection(
                                                      'taskSubmissions',
                                                    )
                                                    .where(
                                                      'taskId',
                                                      isEqualTo: task['id'],
                                                    )
                                                    .where(
                                                      'studentId',
                                                      isEqualTo: _user!.uid,
                                                    )
                                                    .get();

                                            if (existingSubmission
                                                .docs
                                                .isNotEmpty) {
                                              await _firestore
                                                  .collection('taskSubmissions')
                                                  .doc(
                                                    existingSubmission
                                                        .docs
                                                        .first
                                                        .id,
                                                  )
                                                  .update({
                                                    'status': selectedOption,
                                                    'submittedAt':
                                                        FieldValue.serverTimestamp(),
                                                  });
                                            } else {
                                              await _firestore
                                                  .collection('taskSubmissions')
                                                  .add({
                                                    'taskId': task['id'],
                                                    'studentId': _user!.uid,
                                                    'status': selectedOption,
                                                    'submittedAt':
                                                        FieldValue.serverTimestamp(),
                                                    'className':
                                                        task['className'],
                                                  });
                                            }

                                            setState(
                                              () => isSubmitting = false,
                                            );
                                            Get.back();
                                            _loadUserData();

                                            Get.snackbar(
                                              'Success',
                                              'Task submitted successfully',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor:
                                                  AppColors.success,
                                              colorText: AppColors.white,
                                            );
                                          } catch (e) {
                                            setState(
                                              () => isSubmitting = false,
                                            );
                                            Get.snackbar(
                                              'Error',
                                              'Failed to submit task: $e',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: AppColors.error,
                                              colorText: AppColors.white,
                                            );
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  isSubmitting
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        'Submit',
                                        style: CustomTextStyle.labelMedium(
                                          context,
                                        ).copyWith(color: AppColors.white),
                                      ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task, String taskId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task['title'] ?? 'Task Details',
                    style: CustomTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.close, color: AppColors.gray),
                  //   onPressed: () => Get.back(),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              if (task['description'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    task['description'],
                    style: CustomTextStyle.bodyMedium(context),
                  ),
                ),
              _buildDetailItem('Class', task['className'] ?? 'N/A'),
              _buildDetailItem('Assigned by', task['teacherName'] ?? 'Teacher'),
              _buildDetailItem(
                'Assigned on',
                _formatDate(task['createdAt']?.toDate()),
              ),
              _buildDetailItem(
                'Completion Options',
                task['completionOption'] == 'Custom'
                    ? (task['customOptions'] as List).join(', ')
                    : task['completionOption'],
              ),
              const SizedBox(height: 24),
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('taskSubmissions')
                        .where('taskId', isEqualTo: taskId)
                        .where('studentId', isEqualTo: _user!.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  String status = 'Not Submitted';
                  DateTime? submittedAt;

                  if (snapshot.data!.docs.isNotEmpty) {
                    var submission =
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                    status = submission['status'] ?? 'Submitted';
                    submittedAt = submission['submittedAt']?.toDate();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem('Your Status', status),
                      if (submittedAt != null)
                        _buildDetailItem(
                          'Submitted on',
                          _formatDate(submittedAt),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            _showTaskSubmissionDialog({...task, 'id': taskId});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            status == 'Not Submitted'
                                ? 'Submit Task'
                                : 'Update Submission',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: CustomTextStyle.labelMedium(
                      context,
                    ).copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: CustomTextStyle.labelMedium(
                context,
              ).copyWith(color: AppColors.gray),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: CustomTextStyle.bodyMedium(context)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'yes':
        return AppColors.success;
      case 'not completed':
      case 'no':
        return AppColors.error;
      case 'submitted':
        return AppColors.primary;
      default:
        return AppColors.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: AppColors.primary,
        title: Text(
          'Student Dashboard',
          style: CustomTextStyle.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FluentIcons.person_12_filled,
              color: AppColors.primaryLight,
            ),
            onPressed: _showProfileDialog,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildActiveTasksSection(),
                    const SizedBox(height: 24),
                    _buildRecentTasksSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildWelcomeSection() {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text(
    //       'Hello, ${_studentData?['name'] ?? 'Student'}',
    //       style: CustomTextStyle.titleLarge(
    //         context,
    //       ).copyWith(fontWeight: FontWeight.bold),
    //     ),
    //     const SizedBox(height: 4),
    //     Text(
    //       'Welcome to your dashboard',
    //       style: CustomTextStyle.labelMedium(
    //         context,
    //       ).copyWith(color: AppColors.gray),
    //     ),
    //   ],
    // );
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.tertiary,
              child: Icon(Icons.person, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_studentData?['name'] ?? 'Student'}',
                    style: CustomTextStyle.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back to your dashboard',
                    style: CustomTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: AppColors.gray),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Tasks',
              style: CustomTextStyle.titleMedium(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _showAllTasksDialog,
              child: Text(
                'View all',
                style: CustomTextStyle.labelMedium(
                  context,
                ).copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('tasks')
                  .where('className', whereIn: _classes)
                  .where('status', isEqualTo: 'active')
                  .orderBy('createdAt', descending: true)
                  .limit(2)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return _buildEmptyState('No active tasks');
            }

            return Column(
              children:
                  snapshot.data!.docs.map((doc) {
                    var task = doc.data() as Map<String, dynamic>;
                    return _buildTaskItem(task, doc.id);
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
Widget _buildRecentTasksSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Tasks',
            style: CustomTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: _showAllTasksDialog,
            child: Text(
              'View all',
              style: CustomTextStyle.labelMedium(context).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('className', whereIn: _classes) // Filter by student's classes
            .where('status', isEqualTo: 'active')  // Only show active tasks
            .orderBy('createdAt', descending: true)
            .limit(3)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState('No active tasks');
          }
          return Column(
            children: snapshot.data!.docs.map((doc) {
              var task = doc.data() as Map<String, dynamic>;
              return _buildTaskItem(task, doc.id);
            }).toList(),
          );
        },
      ),
    ],
  );
} void _showAllTasksDialog() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Tasks',
                  style: CustomTextStyle.titleMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    FluentIcons.dismiss_12_regular,
                    color: AppColors.gray,
                    size: 15,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DefaultTabController(
              length: 2,
              child: Expanded(
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Active'),
                        Tab(text: 'Completed'),
                      ],
                      labelColor: AppColors.primary,
                      indicatorColor: AppColors.primary,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Active tasks tab
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('tasks')
                                .where('teacherId', isEqualTo: _user?.uid)
                                .where('status', isEqualTo: 'active')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                );
                              }
                              if (snapshot.data!.docs.isEmpty) {
                                return _buildEmptyState('No active tasks');
                              }
                              return ListView.separated(
                                itemCount: snapshot.data!.docs.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  var doc = snapshot.data!.docs[index];
                                  var task = doc.data() as Map<String, dynamic>;
                                  return _buildTaskItem(task, doc.id);
                                },
                              );
                            },
                          ),
                          // Completed tasks tab
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('tasks')
                                .where('teacherId', isEqualTo: _user?.uid)
                                .where('status', isEqualTo: 'completed')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                );
                              }
                              if (snapshot.data!.docs.isEmpty) {
                                return _buildEmptyState('No completed tasks');
                              }
                              return ListView.separated(
                                itemCount: snapshot.data!.docs.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  var doc = snapshot.data!.docs[index];
                                  var task = doc.data() as Map<String, dynamic>;
                                  return _buildTaskItem(task, doc.id);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Widget _buildEmptyState(String message) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grayLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: CustomTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColors.gray),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, String taskId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primaryLight, width: 1 / 2),
      ),
      child: InkWell(
        onTap: () => _showTaskDetails(task, taskId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task['title'] ?? 'No Title',
                      style: CustomTextStyle.titleSmall(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future:
                        _firestore
                            .collection('taskSubmissions')
                            .where('taskId', isEqualTo: taskId)
                            .where('studentId', isEqualTo: _user!.uid)
                            .get(),
                    builder: (context, snapshot) {
                      String status = 'Not Submitted';
                      Color statusColor = AppColors.gray;

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        var data =
                            snapshot.data!.docs.first.data()
                                as Map<String, dynamic>;
                        status = data['status'] ?? 'Submitted';
                        statusColor = _getStatusColor(status);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          status,
                          style: CustomTextStyle.labelSmall(
                            context,
                          ).copyWith(color: statusColor),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (task['description'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    task['description'],
                    style: CustomTextStyle.bodyMedium(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Divider(height: 16, thickness: 1),
              Row(
                children: [
                  _buildDetailRow(
                    FluentIcons.hat_graduation_12_regular,
                    task['className'] ?? '',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailRow(
                    FluentIcons.person_12_filled,
                    task['teacherName'] ?? 'Teacher',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                FluentIcons.calendar_ltr_12_filled,
                _formatDate(task['createdAt']?.toDate()),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () => _showTaskSubmissionDialog({...task, 'id': taskId}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit Task',
                    style: CustomTextStyle.labelMedium(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryLight),
        const SizedBox(width: 8),
        Text(text, style: CustomTextStyle.bodyMedium(context)),
      ],
    );
  }
} 


    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text(
    //       'Active Tasks',
    //       style: CustomTextStyle.titleSmall(
    //         context,
    //       ).copyWith(fontWeight: FontWeight.bold),
    //     ),
    //     const SizedBox(height: 8),
    //     StreamBuilder<QuerySnapshot>(
    //       stream: _firestore
    //           .collection('tasks')
    //           .where('className', whereIn: _classes)
    //           .where('status', isEqualTo: 'active')
    //           .orderBy('createdAt', descending: true)
    //           .snapshots(),
    //       builder: (context, snapshot) {
    //         if (snapshot.hasError) {
    //           return Text('Error: ${snapshot.error}');
    //         }

    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return const Center(
    //             child: CircularProgressIndicator(color: AppColors.primary),
    //           );
    //         }

    //         if (snapshot.data!.docs.isEmpty) {
    //           return Container(
    //             padding: const EdgeInsets.all(16),
    //             decoration: BoxDecoration(
    //               color: AppColors.grayLight,
    //               borderRadius: BorderRadius.circular(8),
    //             ),
    //             child: Text(
    //               'No active tasks',
    //               style: CustomTextStyle.bodyMedium(
    //                 context,
    //               ).copyWith(color: AppColors.gray),
    //             ),
    //           );
    //         }

    //         return Column(
    //           children: snapshot.data!.docs.map((doc) {
    //             var task = doc.data() as Map<String, dynamic>;
    //             return _buildTaskCard(task, doc.id);
    //           }).toList(),
    //         );
    //       },
    //     ),
    //   ],
    // );

  // void _showAllTasksDialog() {
  //   Get.dialog(
  //     Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       child: Container(
  //         constraints: BoxConstraints(
  //           maxHeight: MediaQuery.of(context).size.height * 0.8,
  //         ),
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'All Tasks',
  //                   style: CustomTextStyle.titleMedium(
  //                     context,
  //                   ).copyWith(fontWeight: FontWeight.bold),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close, color: AppColors.gray),
  //                   onPressed: () => Get.back(),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Expanded(
  //               child: StreamBuilder<QuerySnapshot>(
  //                 stream: _firestore
  //                     .collection('tasks')
  //                     .where('className', whereIn: _classes)
  //                     .orderBy('createdAt', descending: true)
  //                     .snapshots(),
  //                 builder: (context, snapshot) {
  //                   if (snapshot.hasError) {
  //                     return Text('Error: ${snapshot.error}');
  //                   }
      
  //                   if (snapshot.connectionState == ConnectionState.waiting) {
  //                     return const Center(child: CircularProgressIndicator());
  //                   }
      
  //                   if (snapshot.data!.docs.isEmpty) {
  //                     return Center(
  //                       child: Text(
  //                         'No tasks yet',
  //                         style: CustomTextStyle.bodyMedium(context),
  //                       ),
  //                     );
  //                   }
      
  //                   return ListView.builder(
  //                     itemCount: snapshot.data!.docs.length,
  //                     itemBuilder: (context, index) {
  //                       var doc = snapshot.data!.docs[index];
  //                       var task = doc.data() as Map<String, dynamic>;
  //                       return _buildTaskCard(task, doc.id);
  //                     },
  //                   );
  //                 },
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 onPressed: () => Get.back(),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.primary,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Close',
  //                   style: CustomTextStyle.labelLarge(
  //                     context,
  //                   ).copyWith(color: AppColors.white),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }