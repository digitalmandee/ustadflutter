import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/subjects_model.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';

class AddAboutBottomSheet extends StatefulWidget {
  final bool isEdit;
  final String existingAbout;

  const AddAboutBottomSheet({
    super.key,
    this.isEdit = false,
    this.existingAbout = '',
  });

  @override
  State<AddAboutBottomSheet> createState() => _AddAboutBottomSheetState();
}

class _AddAboutBottomSheetState extends State<AddAboutBottomSheet> {
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: widget.existingAbout);

    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AboutProvider>().initTempSelections();
      });
    }
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.only(top: 20),
        height: ScreenSize(context).height * 0.80,
        decoration: BoxDecoration(
            color: AppTheme.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 30,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/radial.png"))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(widget.isEdit
                                ? "assets/images/editBottom.png"
                                : "assets/images/addPlus.png"),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // 👈 only this closes the sheet
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    AppText.appText(
                      widget.isEdit ? "Edit About" : "Add About",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 10),
                    AppText.appText(
                        widget.isEdit
                            ? "Edit your about"
                            : "Add relevant about to your profile",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        textColor: Color(0xff4D5874)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                width: ScreenSize(context).width,
                color: AppTheme.hintColor,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    customLableField(
                      lable: "About",
                      controller: _aboutController,
                      hintText: "Enter your about section...",
                      maxLines: 3,
                      height: 100.0,
                    ),
                    const SizedBox(height: 20),
                    Consumer<AboutProvider>(
                      builder: (_, provider, __) {
                        if (!widget.isEdit) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final provider =
                                        context.read<AboutProvider>();
                                    provider
                                        .initTempSelections(); // ensure temp* set ho jaye

                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      enableDrag: false,
                                      isDismissible: false,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      builder: (_) =>
                                          EditTeachingPrefsBottomSheet(
                                        initialSubjects: provider.tempSubjects,
                                        initialGrades: provider.tempGrades,
                                        initialCurriculums:
                                            provider.tempCurriculums,
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    "assets/images/edit.png",
                                    height: 25,
                                    color: AppTheme.primaryCOlor,
                                  ),
                                ),
                              ],
                            ),
                            AppText.appText(
                              "Subjects",
                              fontWeight: FontWeight.w600,
                            ),
                            _chips(provider.tempSubjects),
                            SizedBox(
                              height: 10,
                            ),
                            AppText.appText(
                              "Grades",
                              fontWeight: FontWeight.w600,
                            ),
                            _chips(provider.tempGrades),
                            SizedBox(
                              height: 10,
                            ),
                            AppText.appText(
                              "Curriculums",
                              fontWeight: FontWeight.w600,
                            ),
                            _chips(provider.tempCurriculums),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final aboutText = _aboutController.text.trim();

                          if (aboutText.isEmpty) {
                            AppToast.error(
                              context: context,
                              msg: "Please enter about text",
                            );
                            return;
                          }
                          if (aboutText.length > 250) {
                            AppToast.error(
                              context: context,
                              msg: "About text cannot exceed 250 characters",
                            );
                            return;
                          }

                          final provider = context.read<AboutProvider>();

                          bool success = false;

                          if (widget.isEdit) {
                            success = await provider.updateAboutData(
                                aboutText, context);
                          } else {
                            success =
                                await provider.addAboutData(aboutText, context);
                          }

                          if (success) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryCOlor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          widget.isEdit ? "Update" : "Add",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chips(List<String> items) {
    if (items.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((e) => Chip(
                backgroundColor: AppTheme.white,
                label: Text(capitalizeEachWord(e))))
            .toList(),
      ),
    );
  }
}

class EditTeachingPrefsBottomSheet extends StatefulWidget {
  final List<String> initialSubjects;
  final List<String> initialGrades;
  final List<String> initialCurriculums;

  const EditTeachingPrefsBottomSheet({
    super.key,
    required this.initialSubjects,
    required this.initialGrades,
    required this.initialCurriculums,
  });

  @override
  State<EditTeachingPrefsBottomSheet> createState() =>
      _EditTeachingPrefsBottomSheetState();
}

class _EditTeachingPrefsBottomSheetState
    extends State<EditTeachingPrefsBottomSheet> {
  List<SubjectsModel> subjects = [];
  late AboutProvider provider;

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
    "Local"
  ];

  @override
  void initState() {
    super.initState();
    provider = context.read<AboutProvider>();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String res = await rootBundle.loadString('assets/subjects.json');
    final List data = json.decode(res);
    subjects = data.map((e) => SubjectsModel.fromJson(e)).toList();
    setState(() {});
  }

  bool get isValid =>
      provider.tempSubjects.isNotEmpty &&
      provider.tempGrades.isNotEmpty &&
      provider.tempCurriculums.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: ScreenSize(context).height * 0.77,
        decoration: BoxDecoration(
            color: AppTheme.white, borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.appText(
                    "Edit Teaching Preferences",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: subjects.isEmpty
                    ? const Center(child: GifLoader())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            MultiSelectDropdown<SubjectsModel>(
                              title: "Subjects",
                              items: subjects,
                              selectedItems: provider.tempSubjects
                                  .map((name) => subjects.firstWhere(
                                      (s) =>
                                          s.name.toLowerCase() ==
                                          name.toLowerCase(),
                                      orElse: () =>
                                          SubjectsModel(name: name, logo: '')))
                                  .toList(),
                              itemLabel: (s) => s.name,
                              onSelect: (s) {
                                final name = (s as SubjectsModel).name;
                                provider.toggleSelection(
                                    name, provider.tempSubjects);
                                setState(() {}); // ✅ update dropdown UI
                              },
                            ),
                            const SizedBox(height: 16),
                            MultiSelectDropdown<String>(
                              title: "Grades",
                              items: allGrades,
                              selectedItems: provider.tempGrades,
                              itemLabel: (s) => s,
                              onSelect: (s) {
                                provider.toggleSelection(
                                    s, provider.tempGrades);
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),
                            MultiSelectDropdown<String>(
                              title: "Curriculums",
                              items: allCurriculums,
                              selectedItems: provider.tempCurriculums,
                              itemLabel: (s) => s,
                              onSelect: (s) {
                                provider.toggleSelection(
                                    s, provider.tempCurriculums);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              AppButton.appButton(
                "Done",
                context: context,
                onTap: isValid ? () => Navigator.pop(context) : null,
              ),
            ],
          ),
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

  const MultiSelectDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADING
        AppText.appText(title,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: AppTheme.lableText),
        const SizedBox(height: 12),

        DropdownButtonHideUnderline(
            child: DropdownButton2<T>(
          isExpanded: true,
          hint: AppText.appText("Select", textColor: const Color(0xffA6ADBF)),
          items: items.map((item) {
            final isSelected = selectedItems.any((e) =>
                (e is String
                    ? e.toLowerCase()
                    : (e as SubjectsModel).name.toLowerCase()) ==
                (item is String
                    ? item.toLowerCase()
                    : (item as SubjectsModel).name.toLowerCase()));
            return DropdownMenuItem<T>(
              value: item,
              enabled: false,
              child: InkWell(
                onTap: () {
                  onSelect(item);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.appColor.withOpacity(.2)
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryCOlor),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 150,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(-5, -5),
          ),
        )),

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
                  labelStyle: const TextStyle(color: Colors.black),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
