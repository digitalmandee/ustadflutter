import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/about/about_bottomsheet.dart';

class TutorAboutSection extends StatefulWidget {
  final bool isParentSide;
  final Map<String, dynamic>? data;
  const TutorAboutSection({super.key, required this.isParentSide, this.data});

  @override
  State<TutorAboutSection> createState() => _TutorAboutSectionState();
}

class _TutorAboutSectionState extends State<TutorAboutSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AboutProvider>(context);
    final data = provider.aboutData;
    final bool hasAbout = data != null && data.about.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isParentSide == true)
          Align(alignment: Alignment.centerRight, child: SizedBox()),

        if (widget.isParentSide == false)
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.appButton(
              hasAbout ? "Edit About" : "Add About",
              image: hasAbout
                  ? "assets/images/edit.png"
                  : "assets/images/plus.png",
              context: context,
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: AppTheme.white,
                  context: context,
                  isScrollControlled: true,
                  enableDrag: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => AddAboutBottomSheet(
                    isEdit: hasAbout,
                    existingAbout: data?.about ?? '',
                  ),
                );
              },
              height: 36,
              width: 125,
              textColor: AppTheme.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 20),
        widget.isParentSide == true
            ? widget.data == null
                  ? Text("Loading....")
                  : widget.data!["Tutor"]["about"] == null
                  ? Text("Tutor has not added about yet.")
                  : AppText.appText(
                      widget.data!["Tutor"]["about"],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      textColor: const Color.fromARGB(255, 102, 103, 105),
                    )
            : data == null || data.about.isEmpty
            ? const Text("No about info added yet.")
            : AppText.appText(
                data.about,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textColor: const Color(0xff9095A6),
              ),
        SizedBox(height: 20),
        AppText.appText("Subjects I Can Teach", fontWeight: FontWeight.bold),
        const SizedBox(height: 10),
        widget.isParentSide == true
            ? widget.data == null
                  ? Text("Loading....")
                  : widget.data!["Tutor"]["subjects"] == null
                  ? Text("No subjects added.")
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (widget.data!["Tutor"]["subjects"] as List<dynamic>)
                              .cast<String>()
                              .map(
                                (subj) => Chip(
                                  label: Text(capitalizeEachWord(subj)),
                                  backgroundColor: AppTheme.white,
                                ),
                              )
                              .toList(),
                    )
            : data == null || data.subjects.isEmpty
            ? const Text("No subjects added.")
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.subjects
                    .map(
                      (subj) => Chip(
                        label: Text(capitalizeEachWord(subj)),
                        backgroundColor: AppTheme.white,
                      ),
                    )
                    .toList(),
              ),

        /////////// 2///
        const SizedBox(height: 10),
        AppText.appText("Curriculums I Can Teach", fontWeight: FontWeight.bold),
        const SizedBox(height: 10),
        widget.isParentSide == true
            ? widget.data == null
                  ? Text("Loading....")
                  : widget.data!["Tutor"]["curriculum"] == null
                  ? Text("No curriculum added.")
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (widget.data!["Tutor"]["curriculum"] as List<dynamic>)
                              .cast<String>()
                              .map(
                                (curr) => Chip(
                                  label: Text(capitalizeEachWord(curr)),
                                  backgroundColor: AppTheme.white,
                                ),
                              )
                              .toList(),
                    )
            : data == null || data.curriculum.isEmpty
            ? const Text("No curriculum added.")
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.curriculum
                    .map(
                      (curr) => Chip(
                        label: Text(capitalizeEachWord(curr)),
                        backgroundColor: AppTheme.white,
                      ),
                    )
                    .toList(),
              ),

        ////////////////////////////3
        const SizedBox(height: 10),
        AppText.appText("Grades I Can Teach", fontWeight: FontWeight.bold),
        const SizedBox(height: 10),
        widget.isParentSide == true
            ? widget.data == null
                  ? Text("Loading....")
                  : widget.data!["Tutor"]["grade"] == null
                  ? Text("No Grade added.")
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (widget.data!["Tutor"]["grade"] as List<dynamic>)
                              .cast<String>()
                              .map(
                                (grad) => Chip(
                                  label: Text(capitalizeEachWord(grad)),
                                  backgroundColor: AppTheme.white,
                                ),
                              )
                              .toList(),
                    )
            : data == null || data.grades.isEmpty
            ? const Text("No subjects added.")
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.grades
                    .map(
                      (grad) => Chip(
                        label: Text(capitalizeEachWord(grad)),
                        backgroundColor: AppTheme.white,
                      ),
                    )
                    .toList(),
              ),

        const SizedBox(height: 20),
      ],
    );
  }
}
