import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tasknest/screens/teacher/profile/profile_setup_page.dart';
import 'package:tasknest/utils/colors.dart';
import 'package:tasknest/utils/app_text_theme.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';

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
                            FluentIcons.person_12_filled,
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
                      icon: Icon(
                        FluentIcons.edit_12_filled,
                        color: AppColors.primary,
                        size: 20,
                      ),
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
                    ,
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Get.back();
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
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          labelStyle: TextStyle(color: AppColors.primary),
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
                           labelStyle: TextStyle(color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                   Text(
  'Completion Options',
  style: CustomTextStyle.labelLarge(context),
),
const SizedBox(height: 8),
SizedBox(
  height: 50,
  child: DropdownButtonFormField2<String>(
    isExpanded: true,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    hint: Text(
      'Select completion option',
      style: CustomTextStyle.labelMedium(context)
          .copyWith(color: AppColors.gray),
    ),
    items: options0.map((option) {
      return DropdownMenuItem<String>(
        value: option,
        child: Text(
          option,
          style: CustomTextStyle.bodyMedium(context),
        ),
      );
    }).toList(),
    value: completionOption,
    onChanged: (value) {
      setState(() {
        completionOption = value;
        showCustomOptions = value == 'Custom';
      });
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a completion option';
      }
      return null;
    },
    dropdownSearchData: DropdownSearchData(
      searchController: TextEditingController(),
      searchInnerWidgetHeight: 60,
      searchInnerWidget: Container(
        height: 60,
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          right: 8,
          left: 8,
        ),
        child: TextFormField(
          controller: TextEditingController(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: 'Search for an option...',
            hintStyle: CustomTextStyle.labelMedium(context)
                .copyWith(color: AppColors.gray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      searchMatchFn: (item, searchValue) {
        return item.value!
            .toString()
            .toLowerCase()
            .contains(searchValue.toLowerCase());
      },
    ),
    onMenuStateChange: (isOpen) {
      if (!isOpen) {
        // Clear search when menu closes
        // No controller to clear in this case since we're not storing it
      }
    },
    buttonStyleData: const ButtonStyleData(
      height: 48,
      padding: EdgeInsets.only(right: 8),
    ),
    menuItemStyleData: const MenuItemStyleData(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16),
    ),
    dropdownStyleData: DropdownStyleData(
      maxHeight: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      offset: const Offset(0, -5),
    ),
    iconStyleData: const IconStyleData(
      icon: Icon(FluentIcons.chevron_down_20_regular),
      iconSize: 20,
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          labelText: 'Option ${index + 1}',
            labelStyle: TextStyle(color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (showCustomOptions && 
              (value == null || value.isEmpty)) {
            return 'Please enter option ${index + 1}';
          }
          return null;
        },
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
                                      'description': descriptionController.text,
                                      'className': className,
                                      'teacherId': _user!.uid,
                                      'teacherName': _teacherData?['name'],
                                      'completionOption': completionOption,
                                      'createdAt': FieldValue.serverTimestamp(),
                                      'status': 'active',
                                    };

                                    if (completionOption == 'Custom') {
                                      List<String> options = customOptions
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
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
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
                        rows: snapshot.data!.docs.asMap().entries.map((entry) {
                          int index = entry.key;
                          var student =
                              entry.value.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text(student['name'] ?? 'No Name')),
                              DataCell(
                                Text(
                                  student['registerNumber']?.toString() ?? 'N/A',
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


void _showTaskDetails(Map<String, dynamic> task, String taskId) {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: task['title']);
  final _descriptionController = TextEditingController(
    text: task['description'],
  );
  String? _status = task['status'] ?? 'active';
  final List<String> _statusOptions = ['active', 'completed', 'archived'];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
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
                              _formKey.currentState?.reset();
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
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        labelStyle: TextStyle(color: AppColors.primary),
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
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status',
                      style: CustomTextStyle.labelLarge(context)
                          .copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(
                          'Select status',
                          style: CustomTextStyle.labelMedium(context)
                              .copyWith(color: AppColors.gray),
                        ),
                        items: _statusOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option[0].toUpperCase() + option.substring(1),
                              style: CustomTextStyle.bodyMedium(context),
                            ),
                          );
                        }).toList(),
                        value: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a status';
                          }
                          return null;
                        },
                        dropdownSearchData: DropdownSearchData(
                          searchController: TextEditingController(),
                          searchInnerWidgetHeight: 60,
                          searchInnerWidget: Container(
                            height: 60,
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              right: 8,
                              left: 8,
                            ),
                            child: TextFormField(
                              controller: TextEditingController(),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: 'Search for a status...',
                                hintStyle: CustomTextStyle.labelMedium(context)
                                    .copyWith(color: AppColors.gray),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            return item.value!
                                .toString()
                                .toLowerCase()
                                .contains(searchValue.toLowerCase());
                          },
                        ),
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            // Clear search when menu closes
                          }
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 48,
                          padding: EdgeInsets.only(right: 8),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 48,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          offset: const Offset(0, -5),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(FluentIcons.chevron_down_20_regular),
                          iconSize: 20,
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
                          if (_formKey.currentState!.validate()) {
                            try {
                              task['id'] = task['id'] ?? taskId;
                              await _firestore
                                  .collection('tasks')
                                  .doc(task['id'])
                                  .update({
                                    'title': _titleController.text,
                                    'description': _descriptionController.text,
                                    'status': _status,
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

 void _showClassDetails(String className) {
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
                  className,
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
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
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
                int activeTasks = snapshot.data?.docs.where((doc) {
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
                        _buildStatItem('Total Tasks', totalTasks.toString()),
                        _buildStatItem('Active Tasks', activeTasks.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Active Tasks'),
                        Tab(text: 'All Tasks'),
                      ],
                      labelColor: AppColors.primary,
                      indicatorColor: AppColors.primary,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Active tasks tab
                          _buildTaskList(
                            _firestore
                                .collection('tasks')
                                .where('className', isEqualTo: className)
                                .where('teacherId', isEqualTo: _user?.uid)
                                .where('status', isEqualTo: 'active')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                          ),
                          // All tasks tab
                          _buildTaskList(
                            _firestore
                                .collection('tasks')
                                .where('className', isEqualTo: className)
                                .where('teacherId', isEqualTo: _user?.uid)
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showClassStudents(className);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
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
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Text(text, style: CustomTextStyle.bodyMedium(context)),
        ],
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

  Widget _buildTaskList(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
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
              'No tasks available',
              style: CustomTextStyle.bodyMedium(context),
            ),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var task = doc.data() as Map<String, dynamic>;
             task['id'] = doc.id; 
            return _buildTaskItem(task, doc.id);
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: CustomTextStyle.labelSmall(
            context,
          ).copyWith(color: AppColors.gray),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: CustomTextStyle.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: AppColors.primary,
        title: Text(
          'Teacher Dashboard',
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
      body: _isLoading
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
                  _buildActiveClassesSection(),
                 
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
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
              child: Icon(
                FluentIcons.person_12_filled,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_teacherData?['name'] ?? 'Teacher'}',
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

  Widget _buildActiveClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Classes',
              style: CustomTextStyle.titleMedium(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _showAllClassesDialog,
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
        if (_classes.isEmpty)
          _buildEmptyState('No classes assigned yet'),
        ..._classes
            .take(2)
            .map(
              (cls) => _buildClassItem(cls),
            )
            .toList(),
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
            .where('teacherId', isEqualTo: _user?.uid) // Filter by teacher's UID
            .orderBy('createdAt', descending: true)
            .limit(3)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState('No tasks created yet');
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
}
  void _showAllTasksDialog() {
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('tasks')
                      .where('teacherId', isEqualTo: _user?.uid)
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
                      return _buildEmptyState('No tasks created yet');
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
  
  Widget _buildClassItem(String className) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.primaryLight, width: 1/2),
    ),
    child: InkWell(
      onTap: () => _showClassDetails(className),
      borderRadius: BorderRadius.circular(12),
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
                  stream: _firestore
                      .collection('tasks')
                      .where('className', isEqualTo: className)
                      .where('teacherId', isEqualTo: _user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container();
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Text(
                        '${snapshot.data?.docs.length ?? 0} tasks',
                        style: CustomTextStyle.labelSmall(
                          context,
                        ).copyWith(color: AppColors.primary),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('students')
                  .where('classes', isEqualTo: className)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return Container();
                }
                return _buildDetailRow(
                  FluentIcons.people_12_filled,
                  '${snapshot.data?.docs.length ?? 0} students',
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              FluentIcons.book_16_filled,
              '${_subjects.length} subjects',
            ),
            const SizedBox(height: 12),
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
 
Widget _buildTaskItem(Map<String, dynamic> task, String taskId) {
return Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: AppColors.primaryLight, width: 1/2),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task['status'] ?? 'active').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(task['status'] ?? 'active'),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    task['status'] ?? 'Active',
                    style: CustomTextStyle.labelSmall(
                      context,
                    ).copyWith(
                      color: _getStatusColor(task['status'] ?? 'active'),
                    ),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Divider(height: 16, thickness: 1),
            _buildDetailRow(
              FluentIcons.hat_graduation_12_regular,
              task['className'] ?? '',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              FluentIcons.calendar_ltr_12_filled,
              _formatDate(task['createdAt']?.toDate()),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              FluentIcons.options_16_filled,
              task['completionOption'] == 'Custom'
                  ? (task['customOptions'] as List).join(', ')
                  : task['completionOption'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showTaskStudents(task['className'], taskId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Submissions',
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
void _showAllClassesDialog() {
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
                  'All Classes',
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
            Expanded(
              child: _classes.isEmpty
                  ? Center(
                      child: _buildEmptyState('No classes assigned yet'),
                    )
                  : ListView.separated(
                      itemCount: _classes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        String className = _classes[index];
                        return _buildClassItem(className);
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
