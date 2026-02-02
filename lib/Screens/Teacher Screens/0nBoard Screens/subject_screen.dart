import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Models/Tutor%20Side/subjects_model.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/data_model.dart';

class SubjectSelectionScreen extends StatefulWidget {
  final Function()? onTap;
  final TutorOnboardData onboardData;

  const SubjectSelectionScreen(
      {super.key, this.onTap, required this.onboardData});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  /// SUBJECTS
  List<SubjectsModel> subjects = [];
  List<SubjectsModel> filteredSubjects = [];
  List<SubjectsModel> selectedSubjects = [];
  TextEditingController searchController = TextEditingController();

  /// GRADES
  final List<String> allGrades = [
    "Pre-KG",
    "KG-1",
    "KG-2",
    "Grade 1",
    "Grade 2",
    "Grade 3",
    "Grade 4",
    "Grade 5",
    "Grade 6",
    "Grade 7",
    "Grade 8",
    "Matriculation",
    "Intermediate",
    "O Level",
    "A Level"
  ];
  List<String> selectedGrades = [];

  /// CURRICULUMS
  final List<String> allCurriculums = [
    "Cambridge",
    "FBISE",
    "American",
    "IB",
    "Punjab Board",
    "Sindh Board",
    "Local",
    "Others"
  ];
  List<String> selectedCurriculums = [];
  TextEditingController otherCurriculumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String response = await rootBundle.loadString('assets/subjects.json');
    final List data = json.decode(response);
    setState(() {
      subjects = data.map((e) => SubjectsModel.fromJson(e)).toList();
      filteredSubjects = subjects;
    });
  }

  // void _filterSubjects(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       filteredSubjects = subjects;
  //     } else {
  //       filteredSubjects = subjects
  //           .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
  //           .toList();
  //     }
  //   });
  // }

  void _toggleSelection<T>(T item, List<T> selectedList) {
    setState(() {
      if (selectedList.contains(item)) {
        selectedList.remove(item);
      } else {
        selectedList.add(item);
      }
    });
  }

  bool get isFormValid =>
      selectedSubjects.isNotEmpty &&
      selectedGrades.isNotEmpty &&
      selectedCurriculums.isNotEmpty &&
      !(selectedCurriculums.contains("Others") &&
          otherCurriculumController.text.trim().isEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  /// BACK BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset("assets/images/arrowBack.png",
                          height: 28),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SCROLLABLE CONTENT
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// RICH TEXT HEADER
                          Text.rich(
                            TextSpan(
                              text: 'Let Us ',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: AppTheme.black,
                                  fontWeight: FontWeight.w400),
                              children: [
                                TextSpan(
                                  text: 'Know You Before',
                                  style: TextStyle(
                                      color: AppTheme.appColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 48),
                                ),
                                const TextSpan(text: ' You Start'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// SUBJECT SELECTION
                          MultiSelectDropdown<SubjectsModel>(
                            title: 'Select Subjects',
                            items: filteredSubjects,
                            selectedItems: selectedSubjects,
                            itemLabel: (s) => s.name,
                            onSelect: (s) =>
                                _toggleSelection(s, selectedSubjects),
                          ),

                          const SizedBox(height: 20),

                          /// GRADES
                          MultiSelectDropdown<String>(
                            title: 'Select Grades',
                            items: allGrades,
                            selectedItems: selectedGrades,
                            itemLabel: (s) => s,
                            onSelect: (s) =>
                                _toggleSelection(s, selectedGrades),
                          ),

                          const SizedBox(height: 20),

                          /// CURRICULUM
                          MultiSelectDropdown<String>(
                            title: 'Select Curriculums',
                            items: allCurriculums,
                            selectedItems: selectedCurriculums,
                            itemLabel: (s) => s,
                            onSelect: (s) =>
                                _toggleSelection(s, selectedCurriculums),
                          ),

                          /// OTHER CURRICULUM FIELD
                          if (selectedCurriculums.contains("Others"))
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: CustomAppTextField(
                                width: double.infinity,
                                texthint: "Enter Other Curriculum",
                                controller: otherCurriculumController,
                              ),
                            ),

                          const SizedBox(
                              height: 80), // space for proceed button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// PROCEED BUTTON AT BOTTOM
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: AppButton.appButton(
                "Proceed",
                context: context,
                onTap: isFormValid
                    ? () {
                        widget.onboardData.selectedSubjects =
                            selectedSubjects.map((s) => s.name).toList();
                        widget.onboardData.selectedGrades = selectedGrades;
                        List<String> finalCurriculums = selectedCurriculums
                            .map((e) => e.toString().trim())
                            .toList();

                        if (finalCurriculums.contains("Others") &&
                            otherCurriculumController.text.trim().isNotEmpty) {
                          int index = finalCurriculums.indexOf("Others");
                          finalCurriculums[index] =
                              otherCurriculumController.text.trim();
                        }

                        widget.onboardData.selectedCurriculums =
                            finalCurriculums;

                        widget.onboardData.selectedGrades = selectedGrades
                            .map((e) => e.toString().trim())
                            .toList();

                        widget.onboardData.selectedSubjects =
                            selectedSubjects.map((s) => s.name.trim()).toList();

                        widget.onTap?.call();
                      }
                    : null,
                height: 52,
                backgroundColor: isFormValid
                    ? AppTheme.primaryCOlor
                    : const Color(0xffD9D9D9),
                textColor:
                    isFormValid ? AppTheme.white : AppTheme.lighttxtColor,
                border: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= MULTISELECT DROPDOWN WIDGET =================
class MultiSelectDropdown<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final Function(T) onSelect;
  final FontWeight? fontWeight;

  const MultiSelectDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onSelect,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADING
        AppText.appText(title,
            fontSize: 16,
            fontWeight: fontWeight ?? FontWeight.w400,
            textColor: AppTheme.lableText),
        const SizedBox(height: 6),

        /// DROPDOWN FIELD
        DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: AppText.appText(
              "Select",
              textColor: Color(0xffA6ADBF),
            ),
            items: items.map((item) {
              final isSelected = selectedItems.contains(item);
              return DropdownMenuItem<T>(
                value: item,
                enabled: false,
                child: InkWell(
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context); // close dropdown
                  },
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.appColor.withValues(alpha: .2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(itemLabel(item))),
                        if (isSelected)
                          Icon(Icons.check, color: AppTheme.appColor),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (_) {},
            buttonStyleData: ButtonStyleData(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.white,
                border: Border.all(
                  color: AppTheme.primaryCOlor,
                ),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 40 * 5, // 3 items visible
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.white),
              offset: const Offset(0, 0),
            ),
          ),
        ),

        /// SELECTED CHIPS
        if (selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: selectedItems.map((e) {
                return Chip(
                  label: AppText.appText(itemLabel(e),
                      textColor: AppTheme.lableText),
                  backgroundColor: AppTheme.white,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
