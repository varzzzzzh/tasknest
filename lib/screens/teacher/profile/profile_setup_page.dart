import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:tasknest/screens/teacher/dashboard/teacher_dashboard.dart';
import 'package:tasknest/utils/app_text_theme.dart';
import 'package:tasknest/utils/colors.dart';

class TeacherProfileSetupPage extends StatefulWidget {
  const TeacherProfileSetupPage({super.key});

  @override
  State<TeacherProfileSetupPage> createState() =>
      _TeacherProfileSetupPageState();
}

class _TeacherProfileSetupPageState extends State<TeacherProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Search controllers for dropdowns
  final _institutionTextController = TextEditingController();
  final _departmentTextController = TextEditingController();
  final _classTextController = TextEditingController();
  final TextEditingController _subjectSearchController =
      TextEditingController();
  final TextEditingController _customSubjectController =
      TextEditingController();
  // Add these to your state variables
  final TextEditingController _classSearchController = TextEditingController();

  final List<String> selectedClasses = [];

  // Custom input controllers
  final _customInstitutionController = TextEditingController();
  final _customDepartmentController = TextEditingController();
  final _customClassController = TextEditingController();
  final _subjectController = TextEditingController();

  String? selectedInstitution;
  String? selectedDepartment;
  String? selectedClass;
  List<String> selectedSubjects = [];

  // Flags to show custom input fields
  bool showCustomInstitution = false;
  bool showCustomDepartment = false;
  bool showCustomClass = false;
  bool showAddSubjectField = false;
  bool _isLoading = false;
  bool showCustomSubject = false;
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

  final List<String> _subjects = [
    "Communicative English - I",
    "Engineering Mathematics - I",
    "Engineering Physics",
    "Engineering Chemistry",
    "Python Programming",
    "Engineering Graphics",
    "Physics and Chemistry Laboratory – I",
    "Python Programming Laboratory",
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
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get both user and teacher data

      final teacherDoc =
          await FirebaseFirestore.instance
              .collection('teachers')
              .doc(userId)
              .get();

      if (teacherDoc.exists) {
        final data = teacherDoc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';

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

          // Subjects and Classes
          selectedSubjects = List<String>.from(data['subjects'] ?? []);
          selectedClasses.clear();
          selectedClasses.addAll(List<String>.from(data['classes'] ?? []));
        });
      }
    } catch (e) {
      debugPrint('Failed to load teacher profile: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _institutionTextController.dispose();
    _departmentTextController.dispose();
    _classTextController.dispose();
    _customInstitutionController.dispose();
    _customDepartmentController.dispose();
    _customClassController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      if (selectedSubjects.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select at least one subject',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception('User not authenticated');

        final finalInstitution =
            showCustomInstitution
                ? _customInstitutionController.text
                : selectedInstitution;
        final finalDepartment =
            showCustomDepartment
                ? _customDepartmentController.text
                : selectedDepartment;

        // Create a batch write to update both collections atomically
        final batch = FirebaseFirestore.instance.batch();

        // Update teacher profile
        final teacherRef = FirebaseFirestore.instance
            .collection('teachers')
            .doc(userId);
        batch.set(teacherRef, {
          'name': _nameController.text,
          'institution': finalInstitution,
          'department': finalDepartment,
          'subjects': selectedSubjects,
          'classes': selectedClasses,
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

        Get.offAll(() => const TeacherDashboard());

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
          style: CustomTextStyle.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
      ),
      body:
          _isLoading
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
                          hintStyle: CustomTextStyle.labelMedium(
                            context,
                          ).copyWith(color: AppColors.gray),
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
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.gray),
                          ),
                          items:
                              _universities.map((university) {
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
                          validator:
                              (value) => _validateDropdownWithOthers(
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
                                  hintStyle: CustomTextStyle.labelMedium(
                                    context,
                                  ).copyWith(color: AppColors.gray),
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
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.gray),
                          ),
                          items:
                              _departments.map((department) {
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
                          validator:
                              (value) => _validateDropdownWithOthers(
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
                                  hintStyle: CustomTextStyle.labelMedium(
                                    context,
                                  ).copyWith(color: AppColors.gray),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              return item.value
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
                      Text('Class', style: CustomTextStyle.labelLarge(context)),
                      const SizedBox(height: 8),

                      // Class Dropdown with Search and Others option
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
                            'Select classes',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.gray),
                          ),
                          items: [
                            ..._classes.map((cls) {
                              return DropdownMenuItem<String>(
                                value: cls,
                                child: Text(
                                  cls,
                                  style: CustomTextStyle.bodyMedium(context),
                                ),
                              );
                            }).toList(),
                            DropdownMenuItem<String>(
                              value: 'Others',
                              child: Text(
                                'Others',
                                style: CustomTextStyle.bodyMedium(context),
                              ),
                            ),
                          ],
                          value:
                              null, // Always null since selections show as chips
                          onChanged: (value) {
                            if (value == 'Others') {
                              setState(() {
                                showCustomClass = true;
                              });
                            } else if (value != null &&
                                !selectedClasses.contains(value)) {
                              setState(() {
                                selectedClasses.add(value);
                              });
                            }
                          },
                          validator: (value) {
                            if (selectedClasses.isEmpty && !showCustomClass) {
                              return 'Please select at least one class';
                            }
                            return null;
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: _classSearchController,
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
                                controller: _classSearchController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Search for a class...',
                                  hintStyle: CustomTextStyle.labelMedium(
                                    context,
                                  ).copyWith(color: AppColors.gray),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              if (item.value == 'Others')
                                return true; // Always show Others option
                              return item.value!.toLowerCase().contains(
                                searchValue.toLowerCase(),
                              );
                            },
                          ),
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              _classSearchController.clear();
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

                      // Custom Class Input Field (shown when "Others" is selected)
                      if (showCustomClass) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customClassController,
                          decoration: InputDecoration(
                            hintText: 'Enter your class name',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                FluentIcons.checkmark_20_regular,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                if (_customClassController.text
                                    .trim()
                                    .isNotEmpty) {
                                  setState(() {
                                    selectedClasses.add(
                                      _customClassController.text.trim(),
                                    );
                                    _customClassController.clear();
                                    showCustomClass = false;
                                  });
                                }
                              },
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                selectedClasses.add(value.trim());
                                _customClassController.clear();
                                showCustomClass = false;
                              });
                            }
                          },
                        ),
                      ],

                      // Selected Classes Chips
                      if (selectedClasses.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              selectedClasses.map((cls) {
                                return Chip(
                                  label: Text(
                                    cls,
                                    style: CustomTextStyle.labelSmall(
                                      context,
                                    ).copyWith(color: AppColors.primary),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.grayLight,
                                    width: 1.0,
                                  ),
                                  deleteIcon: const Icon(
                                    FluentIcons.dismiss_12_regular,
                                    size: 10,
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      selectedClasses.remove(cls);
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Subjects Section
                      Text(
                        'Subjects You Teach',
                        style: CustomTextStyle.labelLarge(context),
                      ),
                      const SizedBox(height: 8),

                      // Subjects Dropdown with Search and Others option
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
                            'Select subjects',
                            style: CustomTextStyle.labelMedium(
                              context,
                            ).copyWith(color: AppColors.gray),
                          ),
                          items: [
                            ..._subjects.map((subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(
                                  subject,
                                  style: CustomTextStyle.bodyMedium(context),
                                ),
                              );
                            }).toList(),
                            DropdownMenuItem<String>(
                              value: 'Others',
                              child: Text(
                                'Others',
                                style: CustomTextStyle.bodyMedium(context),
                              ),
                            ),
                          ],
                          value:
                              null, // Always null since selections show as chips
                          onChanged: (value) {
                            if (value == 'Others') {
                              setState(() {
                                showCustomSubject = true;
                              });
                            } else if (value != null &&
                                !selectedSubjects.contains(value)) {
                              setState(() {
                                selectedSubjects.add(value);
                              });
                            }
                          },
                          dropdownSearchData: DropdownSearchData(
                            searchController: _subjectSearchController,
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
                                controller: _subjectSearchController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Search for a subject...',
                                  hintStyle: CustomTextStyle.labelMedium(
                                    context,
                                  ).copyWith(color: AppColors.gray),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              if (item.value == 'Others')
                                return true; // Always show Others option
                              return item.value!.toLowerCase().contains(
                                searchValue.toLowerCase(),
                              );
                            },
                          ),
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              _subjectSearchController.clear();
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

                      // Custom Subject Input Field (shown when "Others" is selected)
                      if (showCustomSubject) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customSubjectController,
                          decoration: InputDecoration(
                            hintText: 'Enter your subject name',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                FluentIcons.checkmark_20_regular,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                if (_customSubjectController.text
                                    .trim()
                                    .isNotEmpty) {
                                  setState(() {
                                    selectedSubjects.add(
                                      _customSubjectController.text.trim(),
                                    );
                                    _customSubjectController.clear();
                                    showCustomSubject = false;
                                  });
                                }
                              },
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                selectedSubjects.add(value.trim());
                                _customSubjectController.clear();
                                showCustomSubject = false;
                              });
                            }
                          },
                        ),
                      ],

                      // Selected Subjects Chips
                      if (selectedSubjects.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              selectedSubjects.map((subject) {
                                return Chip(
                                  label: Text(
                                    subject,
                                    style: CustomTextStyle.labelSmall(
                                      context,
                                    ).copyWith(color: AppColors.primary),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.grayLight,
                                    width: 1.0,
                                  ),
                                  deleteIcon: const Icon(
                                    FluentIcons.dismiss_12_regular,
                                    size: 10,
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      selectedSubjects.remove(subject);
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ],

                      const SizedBox(height: 20),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitProfile,
                          child: Text(
                            'Complete Setup',
                       
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

