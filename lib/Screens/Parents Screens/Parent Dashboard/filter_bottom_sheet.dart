import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/subjects_model.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/subject_screen.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(List<String>) onApply;

  const FilterBottomSheet(
      {super.key, required this.selectedFilters, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => FilterBottomSheetState();
}

class FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> tempSelected;
  List<SubjectsModel> subjects = [];
  SubjectsModel? selectedSubject;
  List<String> selectedGrades = [];
  List<SubjectsModel> filteredSubjects = [];
  List<SubjectsModel> selectedSubjects = [];

  List<String> selectedCurriculums = [];
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
  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedFilters);
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

  void _toggleFilter(String filter) {
    setState(() {
      tempSelected.contains(filter)
          ? tempSelected.remove(filter)
          : tempSelected.add(filter);
    });
  }

  void _toggleSelection<T>(T item, List<T> selectedList) {
    setState(() {
      if (selectedList.contains(item)) {
        selectedList.remove(item);
      } else {
        selectedList.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenSize(context).height - 100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDivider(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MultiSelectDropdown<SubjectsModel>(
                title: 'Select Subjects',
                items: filteredSubjects,
                selectedItems: selectedSubjects,
                itemLabel: (s) => s.name,
                onSelect: (s) => _toggleSelection(s, selectedSubjects),
              ),
            ),
            // _buildSubjectDropdown(),
            const SizedBox(height: 16),
            _buildFilterSection("Rating", ["High", "Medium", "Low"]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MultiSelectDropdown<String>(
                title: 'Select Grades',
                items: allGrades,
                fontWeight: FontWeight.w500,
                selectedItems: selectedGrades,
                itemLabel: (s) => s,
                onSelect: (s) => _toggleSelection(s, selectedGrades),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MultiSelectDropdown<String>(
                title: 'Select Curriculums',
                items: allCurriculums,
                fontWeight: FontWeight.w500,
                selectedItems: selectedCurriculums,
                itemLabel: (s) => s,
                onSelect: (s) => _toggleSelection(s, selectedCurriculums),
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterSection("Gender", ["Male", "Female"]),
            _buildFilterSection("Experience", ["> 5 years", "> 10 years"]),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.appText("Filters", fontSize: 18, fontWeight: FontWeight.w600),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppTheme.borderCOlor);
  }
Widget _buildFilterSection(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.appText(title,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textColor: AppTheme.lableText),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = tempSelected.contains(option);
              return ChoiceChip(
                disabledColor: AppTheme.white,
                selectedColor: AppTheme.appColor,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? Colors.white : AppTheme.lighttxtColor,
                ),
                backgroundColor: AppTheme.white,
                label: Text(option),
                selected: isSelected,
                // selectedColor: AppTheme.appColor.withAlpha(50),
                onSelected: (_) => _toggleFilter(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: AppButton.appButton(
        "Search",
        context: context,
        onTap: () {
          if (selectedSubject != null) {
            tempSelected.add(selectedSubject!.name);
          }

          _syncMultiSelectFilters(); // 👈 subjects bhi ab yahin se add honge

          widget.onApply(tempSelected);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _syncMultiSelectFilters() {
    tempSelected.removeWhere(
      (e) => subjects.any(
        (s) => s.name.toLowerCase() == e.toLowerCase(),
      ),
    );

    tempSelected.removeWhere(
      (e) => allGrades.any(
        (g) => g.toLowerCase() == e.toLowerCase(),
      ),
    );

    tempSelected.removeWhere(
      (e) => allCurriculums.any(
        (c) => c.toLowerCase() == e.toLowerCase(),
      ),
    );

    tempSelected.addAll(
      selectedSubjects.map((s) => s.name),
    );

    tempSelected.addAll(selectedGrades);

    tempSelected.addAll(selectedCurriculums);
  }
}
