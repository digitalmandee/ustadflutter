import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Profile/education/add_edu_sheet.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Profile/education/education_list.dart';

class TutorEducationScreen extends StatefulWidget {
  final bool isParentSide;
  final Map<String, dynamic>? data;
  const TutorEducationScreen(
      {super.key, required this.isParentSide, this.data});

  @override
  State<TutorEducationScreen> createState() => _TutorEducationScreenState();
}

class _TutorEducationScreenState extends State<TutorEducationScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.isParentSide) {
      Provider.of<EducationProvider>(context, listen: false)
          .fetchEducation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eduProvider = Provider.of<EducationProvider>(context);
    final educations = widget.isParentSide == true
        ? (widget.data != null ? widget.data!["TutorEducations"] ?? [] : [])
        : eduProvider.education;

    return Column(
      children: [
        if (!widget.isParentSide)
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.appButton(
              "Add Education",
              image: "assets/images/plus.png",
              context: context,
              height: 36,
              width: 125,
              textColor: AppTheme.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              onTap: () => _openAddSheet(),
            ),
          ),
        const SizedBox(height: 10),
        educations == null || educations.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text("No Education added yet."),
              )
            : EducationList(
                educations: educations,
                isParentSide: widget.isParentSide,
              ),
      ],
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      backgroundColor: AppTheme.white,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddEducationBottomSheet(),
    );
  }
}
