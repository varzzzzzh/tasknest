import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:tasknest/screens/student/dashboard/student_dashboard.dart';
import 'package:tasknest/utils/app_text_theme.dart';
import 'package:tasknest/utils/colors.dart';

class StudentProfileSetupPage extends StatefulWidget {
  const StudentProfileSetupPage({super.key});

  @override
  State<StudentProfileSetupPage> createState() => _StudentProfileSetupPageState();
}

class _StudentProfileSetupPageState extends State<StudentProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registerNumberController = TextEditingController();

  // Search controllers for dropdowns
  final _institutionTextController = TextEditingController();
  final _departmentTextController = TextEditingController();
  final _classTextController = TextEditingController();

  // Custom input controllers
  final _customInstitutionController = TextEditingController();
  final _customDepartmentController = TextEditingController();

  String? selectedInstitution;
  String? selectedDepartment;
  String? selectedClass;

  // Flags to show custom input fields
  bool showCustomInstitution = false;
  bool showCustomDepartment = false;
  bool _isLoading = false;

  final List<String> _classes = [
    "AIDS-A",
    "AIDS-B",
    "AIDS-C",
    "AIML-A",
    "AIML-B",
    "AIML-C",
    "BME-A",
    "BME-B",
    "BME-C",
    "CIVIL-A",
    "CIVIL-B",
    "CIVIL-C",
    "CSE-A",
    "CSE-B",
    "CSE-C",
    "ECE-A",
    "ECE-B",
    "ECE-C",
    "EEE-A",
    "EEE-B",
    "EEE-C",
    "MECH-A",
    "MECH-B",
    "MECH-C",
    "IT-A",
    "IT-B",
    "IT-C",
    "ME-A",
    "ME-B",
    "ME-C",
    "MBA-A",
    "MBA-B",
    "MBA-C",
  ];

  final List<String> _departments = [
    "SCIENCE AND HUMANITIES",
    "ARTIFICIAL INTELLIGENCE AND DATA SCIENCE",
    "ARTIFICIAL INTELLIGENCE AND MACHINE LEARNING",
    "BIO-MEDICAL ENGINEERING",
    "CIVIL ENGINEERING",
    "COMPUTER SCIENCE AND ENGINEERING",
    "ELECTRONICS AND COMMUNICATION ENGINEERING",
    "ELECTRICAL AND ELECTRONICS ENGINEERING",
    "MECHANICAL ENGINEERING",
    "INFORMATION TECHNOLOGY",
    "MEDICAL ELECTRONICS",
    "MANAGEMENT STUDIES (MBA)",
    "Others",
  ];

  final List<Map<String, dynamic>> _universities = [
    {"name": "Anna University", "location": "Chennai"},
    {"name": "Bharathiar University", "location": "Coimbatore"},
    {"name": "Madras University", "location": "Chennai"},
    {"name": "Bharathidasan University", "location": "Tiruchirappalli"},
    {"name": "Alagappa University", "location": "Karaikudi"},
    {"name": "Periyar University", "location": "Salem"},
    {"name": "Annamalai University", "location": "Chidambaram"},
    {"name": "Thiruvalluvar University", "location": "Vellore"},
    {"name": "Manonmaniam Sundaranar University", "location": "Tirunelveli"},
    {"name": "Mother Teresa Women's University", "location": "Kodaikanal"},
    {"name": "Others", "location": ""},
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _registerNumberController.text = data['registerNumber'] ?? '';

          // Institution
          selectedInstitution = data['institution'];
          if (!_universities.any((u) => u['name'] == selectedInstitution)) {
            showCustomInstitution = true;
            _customInstitutionController.text = selectedInstitution ?? '';
            selectedInstitution = 'Others';
          }

          // Department
          selectedDepartment = data['department'];
          if (!_departments.contains(selectedDepartment)) {
            showCustomDepartment = true;
            _customDepartmentController.text = selectedDepartment ?? '';
            selectedDepartment = 'Others';
          }

          // Class
          selectedClass = data['classes'];
        });
      }
    } catch (e) {
      debugPrint('Failed to load student profile: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerNumberController.dispose();
    _institutionTextController.dispose();
    _departmentTextController.dispose();
    _classTextController.dispose();
    _customInstitutionController.dispose();
    _customDepartmentController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception('User not authenticated');

        final finalInstitution = showCustomInstitution
            ? _customInstitutionController.text
            : selectedInstitution;
        final finalDepartment = showCustomDepartment
            ? _customDepartmentController.text
            : selectedDepartment;

        // Create a batch write to update both collections atomically
        final batch = FirebaseFirestore.instance.batch();

        // Update student profile
        final studentRef = FirebaseFirestore.instance
            .collection('students')
            .doc(userId);
        batch.set(studentRef, {
          'name': _nameController.text,
          'registerNumber': _registerNumberController.text,
          'institution': finalInstitution,
          'department': finalDepartment,
          'classes': selectedClass,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update user profile status
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);
        batch.set(userRef, {
          'profileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await batch.commit();

        Get.offAll(() => const StudentDashboard());

        Get.snackbar(
          'Success',
          'Profile setup completed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save profile: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateDropdownWithOthers(
    String? value,
    bool showCustom,
    TextEditingController customController,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please select your $fieldName';
    }
    if (showCustom && customController.text.isEmpty) {
      return 'Please enter your custom $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: CustomTextStyle.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Text(
                      'Full Name',
                      style: CustomTextStyle.labelLarge(context),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: CustomTextStyle.labelMedium(context)
                            .copyWith(color: AppColors.gray),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Register Number Field
                    Text(
                      'Register Number',
                      style: CustomTextStyle.labelLarge(context),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _registerNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter your register number',
                        hintStyle: CustomTextStyle.labelMedium(context)
                            .copyWith(color: AppColors.gray),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your register number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Institution Dropdown
                    Text(
                      'University/Institution',
                      style: CustomTextStyle.labelLarge(context),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(
                          'Select your institution',
                          style: CustomTextStyle.labelMedium(context)
                              .copyWith(color: AppColors.gray),
                        ),
                        items: _universities.map((university) {
                          return DropdownMenuItem<String>(
                            value: university['name'],
                            child: Text(
                              university['location'].isEmpty
                                  ? university['name']
                                  : '${university['name']} (${university['location']})',
                              style: CustomTextStyle.labelMedium(context),
                            ),
                          );
                        }).toList(),
                        value: selectedInstitution,
                        onChanged: (value) {
                          setState(() {
                            selectedInstitution = value;
                            showCustomInstitution = value == 'Others';
                            if (!showCustomInstitution) {
                              _customInstitutionController.clear();
                            }
                          });
                        },
                        validator: (value) => _validateDropdownWithOthers(
                          value,
                          showCustomInstitution,
                          _customInstitutionController,
                          'institution',
                        ),
                        dropdownSearchData: DropdownSearchData(
                          searchController: _institutionTextController,
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
                              controller: _institutionTextController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: 'Search for an institution...',
                                hintStyle: CustomTextStyle.labelMedium(context)
                                    .copyWith(color: AppColors.gray),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            final university = _universities.firstWhere(
                              (u) => u['name'] == item.value,
                            );
                            return university['name']
                                .toString()
                                .toLowerCase()
                                .contains(searchValue.toLowerCase());
                          },
                        ),
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            _institutionTextController.clear();
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

                    if (showCustomInstitution) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customInstitutionController,
                        decoration: InputDecoration(
                          hintText: 'Enter your institution name',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (showCustomInstitution &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter your institution name';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Department Dropdown
                    Text(
                      'Department',
                      style: CustomTextStyle.labelLarge(context),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(
                          'Select your department',
                          style: CustomTextStyle.labelMedium(context)
                              .copyWith(color: AppColors.gray),
                        ),
                        items: _departments.map((department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(
                              department,
                              style: CustomTextStyle.bodyMedium(context),
                            ),
                          );
                        }).toList(),
                        value: selectedDepartment,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                            showCustomDepartment = value == 'Others';
                            if (!showCustomDepartment) {
                              _customDepartmentController.clear();
                            }
                          });
                        },
                        validator: (value) => _validateDropdownWithOthers(
                          value,
                          showCustomDepartment,
                          _customDepartmentController,
                          'department',
                        ),
                        dropdownSearchData: DropdownSearchData(
                          searchController: _departmentTextController,
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
                              controller: _departmentTextController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: 'Search for a department...',
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
                            _departmentTextController.clear();
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
                    if (showCustomDepartment) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customDepartmentController,
                        decoration: InputDecoration(
                          hintText: 'Enter your department name',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (showCustomDepartment &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter your department name';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Class Dropdown
                    Text(
                      'Class',
                      style: CustomTextStyle.labelLarge(context),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(
                          'Select your class',
                          style: CustomTextStyle.labelMedium(context)
                              .copyWith(color: AppColors.gray),
                        ),
                        items: _classes.map((cls) {
                          return DropdownMenuItem<String>(
                            value: cls,
                            child: Text(
                              cls,
                              style: CustomTextStyle.bodyMedium(context),
                            ),
                          );
                        }).toList(),
                        value: selectedClass,
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your class';
                          }
                          return null;
                        },
                        dropdownSearchData: DropdownSearchData(
                          searchController: _classTextController,
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
                              controller: _classTextController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: 'Search for a class...',
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
                            _classTextController.clear();
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
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Complete Setup',
                          style: CustomTextStyle.labelLarge(context)
                              .copyWith(color: AppColors.white),
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