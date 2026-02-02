import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Profile/experience/add_exp_sheet.dart';

class TutorExperience extends StatefulWidget {
  final bool isParentSide;
  final Map<String, dynamic>? data;
  const TutorExperience({super.key, required this.isParentSide, this.data});

  @override
  State<TutorExperience> createState() => _TutorExperienceState();
}

class _TutorExperienceState extends State<TutorExperience> {
  @override
  void initState() {
    super.initState();
    if (!widget.isParentSide) {
      Provider.of<ExperienceProvider>(context, listen: false)
          .fetchExperiences(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expProvider = Provider.of<ExperienceProvider>(context);
    final experiences = expProvider.experiences;
    return Column(
      children: [
        if (!widget.isParentSide)
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.appButton(
              "Add Experience",
              image: "assets/images/plus.png",
              context: context,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.white,
                  enableDrag: false,
                  builder: (_) => const AddExperienceBottomSheet(),
                );
              },
              height: 36,
              width: 135,
              textColor: AppTheme.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        parentCheckLogic(experience: experiences),
      ],
    );
  }

  Widget parentCheckLogic({experience}) {
    if (widget.isParentSide) {
      final parentExperience = widget.data?["TutorExperiences"];
      if (parentExperience == null || parentExperience.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No Experience added yet."),
        );
      }
      return customExpListView();
    } else {
      if (experience == null || experience.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No Experience added yet."),
        );
      } else {
        return customExpListView(experience: experience);
      }
    }
  }

  Widget customExpListView({experience}) {
    final parentExperience = widget.data?["TutorExperiences"];
    final isParent = widget.isParentSide;
    final itemCount =
        isParent ? (parentExperience?.length ?? 0) : (experience?.length ?? 0);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final exp = isParent ? null : experience[index];
        final expData = isParent ? parentExperience[index] : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.appColor,
                      image: const DecorationImage(
                        image: AssetImage("assets/images/joblogo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.appText(
                            isParent
                                ? capitalizeEachWord(expData["company"])
                                : capitalizeEachWord(exp.company),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        AppText.appText(
                            isParent
                                ? expData["dasignation"]
                                    .toString()
                                    .toUpperCase()
                                : exp.designation.toString().toUpperCase(),
                            fontSize: 12,
                            textColor: const Color(0xff2A2A2A),
                            fontWeight: FontWeight.w400),
                        AppText.appText(
                          isParent
                              ? '${DateTime.parse(expData["startDate"]).year} — ${expData["endDate"].toLowerCase() == "present" ? "Present" : DateTime.parse(expData["endDate"]).year}'
                              : '${DateTime.parse(exp.startDate).year} — ${exp.endDate.toLowerCase() == "present" ? "Present" : DateTime.parse(exp.endDate).year}',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          textColor: const Color(0xff504E4E),
                        ),
                      ],
                    ),
                  ),
                  if (!isParent) ...[
                    _buildEditButton(context, exp),
                  ]
                ],
              ),
              const SizedBox(height: 10),
              _buildBulletPoint(
                  text: isParent ? expData["description"] : exp.description),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint({String? text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0, left: 15),
          child: Icon(Icons.circle, size: 8, color: Color(0xffC4C4C4)),
        ),
        const SizedBox(width: 29),
        Expanded(
          child: AppText.appText(
            text ?? '',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            textColor: const Color(0xff504E4E),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, exp) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: AppTheme.white,
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => AddExperienceBottomSheet(experience: exp),
        );
      },
      child: Image.asset(
        "assets/images/edit.png",
        height: 20,
        color: AppTheme.primaryCOlor,
      ),
    );
  }
}
