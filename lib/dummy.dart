import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tasknest/screens/teacher/profile/profile_setup_page.dart';
import 'package:tasknest/utils/colors.dart';
import 'package:tasknest/utils/app_text_theme.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _teacherData;
  List<String> _classes = [];
  List<String> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _user = _auth.currentUser;

    if (_user != null) {
      final doc = await _firestore.collection('teachers').doc(_user!.uid).get();
      if (doc.exists) {
        setState(() {
          _teacherData = doc.data()!;
          _classes = List<String>.from(_teacherData?['classes'] ?? []);
          _subjects = List<String>.from(_teacherData?['subjects'] ?? []);
        });
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
                            _teacherData?['name'] ?? 'No Name',
                            style: CustomTextStyle.titleLarge(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Teacher',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () {
                      Get.to(
                        () => TeacherProfileSetupPage(),
                      )?.then((_) => _loadUserData());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileItem(
                'Institution',
                _teacherData?['institution'] ?? 'Not set',
              ),
              _buildProfileItem(
                'Department',
                _teacherData?['department'] ?? 'Not set',
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
                  style: CustomTextStyle.labelMedium(
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
              const SizedBox(height: 16),
              Text(
                'Subjects You Teach',
               style: CustomTextStyle.labelMedium(
              context,
            ).copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 8),
              if (_subjects.isEmpty)
                Text(
                  'No subjects assigned',
                  style: CustomTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.gray),
                ),
              ..._subjects
                  .map(
                    (subject) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        subject,
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
                      Icon(Icons.logout, color: AppColors.error, size: 20),
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

  void _showCreateTaskDialog(String className) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? completionOption = 'Yes/No';
    final List<String> options0 = [
      'Yes/No',
      'Completed/Not Completed',
      'Custom',
    ];
    List<TextEditingController> customOptions = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    bool showCustomOptions = false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create Task for $className',
                            style: CustomTextStyle.titleMedium(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: AppColors.gray),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: completionOption,
                        items:
                            options0.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            completionOption = value;
                            showCustomOptions = value == 'Custom';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Completion Options',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (showCustomOptions) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Enter Custom Options (up to 3)',
                          style: CustomTextStyle.labelMedium(context),
                        ),
                        ...List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: customOptions[index],
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _showClassStudents(className);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'View Students',
                                style: CustomTextStyle.labelMedium(
                                  context,
                                ).copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    Map<String, dynamic> taskData = {
                                      'title': titleController.text,
                                      'description':
                                          descriptionController.text,
                                      'className': className,
                                      'teacherId': _user!.uid,
                                      'teacherName': _teacherData?['name'],
                                      'completionOption': completionOption,
                                      'createdAt': FieldValue.serverTimestamp(),
                                      'status': 'active',
                                    };

                                    if (completionOption == 'Custom') {
                                      List<String> options =
                                          customOptions
                                              .where(
                                                (controller) =>
                                                    controller.text.isNotEmpty,
                                              )
                                              .map(
                                                (controller) => controller.text,
                                              )
                                              .toList();

                                      if (options.isEmpty) {
                                        Get.snackbar(
                                          'Error',
                                          'Please enter at least one custom option',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: AppColors.error,
                                          colorText: AppColors.white,
                                        );
                                        return;
                                      }

                                      taskData['customOptions'] = options;
                                    }

                                    await _firestore
                                        .collection('tasks')
                                        .add(taskData);
                                    Get.back();
                                    Get.snackbar(
                                      'Success',
                                      'Task created successfully',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppColors.success,
                                      colorText: AppColors.white,
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to create task: $e',
                                      snackPosition: SnackPosition.BOTTOM,
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
                              child: Text(
                                'Create Task',
                                style: CustomTextStyle.labelMedium(
                                  context,
                                ).copyWith(color: AppColors.white),
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
          },
        ),
      ),
    );
  }

  void _showClassStudents(String className) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Students in $className',
                    style: CustomTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.gray),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('students')
                        .where('classes', isEqualTo: className)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No students in this class',
                        style: CustomTextStyle.bodyMedium(context),
                      ),
                    );
                  }

                  return Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'No.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Register Number',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows:
                            snapshot.data!.docs.asMap().entries.map((entry) {
                              int index = entry.key;
                              var student =
                                  entry.value.data() as Map<String, dynamic>;
                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(Text(student['name'] ?? 'No Name')),
                                  DataCell(
                                    Text(
                                      student['registerNumber']?.toString() ??
                                          'N/A',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  );
                },
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
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: task['title']);
    final descriptionController = TextEditingController(
      text: task['description'],
    );
    String? status = task['status'] ?? 'active';
    final List<String> statusOptions = ['active', 'completed', 'archived'];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task['title'] ?? 'No Title',
                            style: CustomTextStyle.titleMedium(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                formKey.currentState?.reset();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (task['description'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            task['description'],
                            style: CustomTextStyle.bodyMedium(context),
                          ),
                        ),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: status,
                        items:
                            statusOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option[0].toUpperCase() + option.substring(1),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            status = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Class: ${task['className'] ?? ''}',
                        style: CustomTextStyle.bodyMedium(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completion Option: ${task['completionOption'] ?? ''}',
                        style: CustomTextStyle.bodyMedium(context),
                      ),
                      if (task['customOptions'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Custom Options: ${(task['customOptions'] as List).join(', ')}',
                          style: CustomTextStyle.bodyMedium(context),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await _firestore
                                    .collection('tasks')
                                    .doc(task['id'])
                                    .update({
                                      'title': titleController.text,
                                      'description':
                                          descriptionController.text,
                                      'status': status,
                                      'updatedAt': FieldValue.serverTimestamp(),
                                    });
                                Get.back();
                                Get.snackbar(
                                  'Success',
                                  'Task updated successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.success,
                                  colorText: AppColors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to update task: $e',
                                  snackPosition: SnackPosition.BOTTOM,
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
                          child: Text(
                            'Save Changes',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showTaskStudents(task['className'], task['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'View Students Status',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.white),
                          ),
                        ),
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
          },
        ),
      ),
    );
  }

  void _showTaskStudents(String className, String taskId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students Status',
                style: CustomTextStyle.titleMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('students')
                        .where('classes', isEqualTo: className)
                        .snapshots(),
                builder: (context, studentsSnapshot) {
                  if (studentsSnapshot.hasError) {
                    return Text('Error: ${studentsSnapshot.error}');
                  }

                  if (studentsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (studentsSnapshot.data!.docs.isEmpty) {
                    return Text(
                      'No students in this class',
                      style: CustomTextStyle.bodyMedium(context),
                    );
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        _firestore
                            .collection('taskSubmissions')
                            .where('taskId', isEqualTo: taskId)
                            .snapshots(),
                    builder: (context, submissionsSnapshot) {
                      if (submissionsSnapshot.hasError) {
                        return Text('Error: ${submissionsSnapshot.error}');
                      }

                      if (submissionsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Count statuses
                      Map<String, int> statusCounts = {};
                      final submissions = submissionsSnapshot.data?.docs ?? [];

                      for (var doc in submissions) {
                        var data = doc.data() as Map<String, dynamic>;
                        String status = data['status'] ?? 'Not Submitted';
                        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
                      }

                      return Column(
                        children: [
                          // Status counts row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  statusCounts.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: _buildStatusCount(
                                        entry.key,
                                        entry.value,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Table view of students
                          SizedBox(
                            height: 300,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('No.')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Reg No.')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows:
                                    studentsSnapshot.data!.docs
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          int index = entry.key;
                                          var student =
                                              entry.value.data()
                                                  as Map<String, dynamic>;
                                          var studentId = entry.value.id;

                                          // Find submission for this student
                                          var submission = submissions.where(
                                            (doc) =>
                                                (doc.data()
                                                    as Map<
                                                      String,
                                                      dynamic
                                                    >)['studentId'] ==
                                                studentId,
                                          );

                                          String status = 'Not Submitted';
                                          if (submission.isNotEmpty) {
                                            status =
                                                (submission.first.data()
                                                    as Map<
                                                      String,
                                                      dynamic
                                                    >)['status'] ??
                                                'Not Submitted';
                                          }

                                          return DataRow(
                                            cells: [
                                              DataCell(Text('${index + 1}')),
                                              DataCell(
                                                Text(
                                                  student['name'] ?? 'No Name',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  student['registerNumber'] ??
                                                      '',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                      status,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        })
                                        .toList(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'yes':
        return AppColors.success;
      case 'not completed':
      case 'no':
        return AppColors.error;
      case 'active':
        return AppColors.primary;
      case 'archived':
        return AppColors.gray;
      default:
        return AppColors.gray;
    }
  }

  Widget _buildStatusCount(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: CustomTextStyle.labelMedium(
            context,
          ).copyWith(color: AppColors.gray),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: CustomTextStyle.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: _getStatusColor(label),
          ),
        ),
      ],
    );
  }

  void _showClassDetails(String className) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      className,
                      style: CustomTextStyle.titleMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.gray),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Class statistics section
                StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('tasks')
                          .where('className', isEqualTo: className)
                          .where('teacherId', isEqualTo: _user?.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    int totalTasks = snapshot.data?.docs.length ?? 0;
                    int activeTasks =
                        snapshot.data?.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return data['status'] == 'active';
                        }).length ??
                        0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Total Tasks',
                              totalTasks.toString(),
                            ),
                            _buildStatItem(
                              'Active Tasks',
                              activeTasks.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),

                // Tasks Section with Tab View
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Active Tasks'),
                          Tab(text: 'All Tasks'),
                        ],
                        labelColor: AppColors.primary,
                        indicatorColor: AppColors.primary,
                      ),
                      SizedBox(
                        height: 300, // Fixed height for the tab content
                        child: TabBarView(
                          children: [
                            // Active Tasks Tab
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  _firestore
                                      .collection('tasks')
                                      .where('className', isEqualTo: className)
                                      .where('teacherId', isEqualTo: _user?.uid)
                                      .where('status', isEqualTo: 'active')
                                      .orderBy('createdAt', descending: true)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No active tasks for this class',
                                      style: CustomTextStyle.bodyMedium(
                                        context,
                                      ),
                                    ),
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text('No.')),
                                      DataColumn(label: Text('Title')),
                                      DataColumn(label: Text('Description')),
                                      DataColumn(label: Text('Created At')),
                                      DataColumn(label: Text('Options')),
                                    ],
                                    rows:
                                        snapshot.data!.docs.asMap().entries.map(
                                          (entry) {
                                            int index = entry.key;
                                            var task =
                                                entry.value.data()
                                                    as Map<String, dynamic>;
                                            return DataRow(
                                              cells: [
                                                DataCell(Text('${index + 1}')),
                                                DataCell(
                                                  Text(
                                                    task['title'] ?? 'No Title',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    task['description'] ??
                                                        'No Description',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    _formatDate(
                                                      task['createdAt']
                                                          ?.toDate(),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    task['completionOption'] ??
                                                        'N/A',
                                                  ),
                                                ),
                                              ],
                                              onSelectChanged: (_) {
                                                _showTaskDetails({
                                                  ...task,
                                                  'id': entry.value.id,
                                                });
                                              },
                                            );
                                          },
                                        ).toList(),
                                  ),
                                );
                              },
                            ),

                            // All Tasks Tab
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  _firestore
                                      .collection('tasks')
                                      .where('className', isEqualTo: className)
                                      .where('teacherId', isEqualTo: _user?.uid)
                                      .orderBy('createdAt', descending: true)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No tasks for this class',
                                      style: CustomTextStyle.bodyMedium(
                                        context,
                                      ),
                                    ),
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text('No.')),
                                      DataColumn(label: Text('Title')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Created At')),
                                      DataColumn(label: Text('Options')),
                                    ],
                                    rows:
                                        snapshot.data!.docs.asMap().entries.map((
                                          entry,
                                        ) {
                                          int index = entry.key;
                                          var task =
                                              entry.value.data()
                                                  as Map<String, dynamic>;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text('${index + 1}')),
                                              DataCell(
                                                Text(
                                                  task['title'] ?? 'No Title',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                      task['status'] ??
                                                          'active',
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    // Modified to show simple status text without checkbox
                                                    task['status'] ==
                                                            'completed'
                                                        ? 'Completed'
                                                        : task['status'] ==
                                                            'active'
                                                        ? 'Active'
                                                        : task['status'] ??
                                                            'Active',
                                                    style:
                                                        CustomTextStyle.labelSmall(
                                                          context,
                                                        ).copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _formatDate(
                                                    task['createdAt']?.toDate(),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  task['completionOption'] ??
                                                      'N/A',
                                                ),
                                              ),
                                            ],
                                            onSelectChanged: (_) {
                                              _showTaskDetails({
                                                ...task,
                                                'id': entry.value.id,
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showClassStudents(className);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Students',
                      style: CustomTextStyle.labelMedium(
                        context,
                      ).copyWith(color: AppColors.white),
                    ),
                  ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Dashboard',
          style: CustomTextStyle.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primary),
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
                    _buildRecentTasksSection(),
                    const SizedBox(height: 24),
                    _buildClassesSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${_teacherData?['name'] ?? 'Teacher'}',
          style: CustomTextStyle.titleLarge(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome to your dashboard',
          style: CustomTextStyle.labelMedium(
            context,
          ).copyWith(color: AppColors.gray),
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
              style: CustomTextStyle.titleSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _showAllTasksDialog();
              },
              child: Text(
                'View all',
                style: CustomTextStyle.labelMedium(
                  context,
                ).copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('tasks')
                  .where('teacherId', isEqualTo: _user?.uid)
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
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No tasks created yet',
                  style: CustomTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.gray),
                ),
              );
            }

            return Column(
              children:
                  snapshot.data!.docs.map((doc) {
                    var task = doc.data() as Map<String, dynamic>;
                    return InkWell(
                      onTap: () {
                        _showTaskDetails({...task, 'id': doc.id});
                      },
                      child: _buildTaskCard(task),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Classes',
              style: CustomTextStyle.titleSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                _showAllClassesDialog();
              },
              child: Text(
                'View all',
                style: CustomTextStyle.labelMedium(
                  context,
                ).copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_classes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No classes assigned yet',
              style: CustomTextStyle.bodyMedium(
                context,
              ).copyWith(color: AppColors.gray),
            ),
          ),
        ..._classes
            .map(
              (cls) => InkWell(
                onTap: () {
                  _showClassDetails(cls);
                },
                child: _buildClassCard(cls),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildClassCard(String className) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  className,
                  style: CustomTextStyle.titleSmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('tasks')
                          .where('className', isEqualTo: className)
                          .where('teacherId', isEqualTo: _user?.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container();
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem('Students', '24'),
                _buildStatItem('Tasks', '5'),
                _buildStatItem('Subjects', _subjects.length.toString()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCreateTaskDialog(className),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Create Task',
                  style: CustomTextStyle.labelMedium(
                    context,
                  ).copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task['status'] ?? 'active'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (task['status'] ?? 'active').toUpperCase(),
                    style: CustomTextStyle.labelSmall(
                      context,
                    ).copyWith(color: AppColors.white),
                  ),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Row(
              children: [
                _buildStatItem('Class', task['className'] ?? ''),
                _buildStatItem('Options', task['completionOption'] ?? ''),
                _buildStatItem(
                  'Created',
                  _formatDate(task['createdAt']?.toDate()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CustomTextStyle.labelSmall(
              context,
            ).copyWith(color: AppColors.gray),
          ),
          Text(
            value,
            style: CustomTextStyle.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAllTasksDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
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
                    icon: Icon(Icons.close, color: AppColors.gray),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('tasks')
                          .where('teacherId', isEqualTo: _user?.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No tasks created yet',
                          style: CustomTextStyle.bodyMedium(context),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var task = doc.data() as Map<String, dynamic>;
                        return InkWell(
                          onTap: () {
                            _showTaskDetails({...task, 'id': doc.id});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildTaskCard(task),
                          ),
                        );
                      },
                    );
                  },
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
    );
  }

  void _showAllClassesDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Classes',
                    style: CustomTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.gray),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _classes.isEmpty
                        ? Center(
                          child: Text(
                            'No classes assigned yet',
                            style: CustomTextStyle.bodyMedium(context),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _classes.length,
                          itemBuilder: (context, index) {
                            String className = _classes[index];
                            return InkWell(
                              onTap: () {
                                _showClassDetails(className);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildClassCard(className),
                              ),
                            );
                          },
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
    );
  }
}
