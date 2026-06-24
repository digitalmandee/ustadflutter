import 'package:flutter/material.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/education/edu_item.dart';

class EducationList extends StatelessWidget {
  final List educations;
  final bool isParentSide;

  const EducationList({
    super.key,
    required this.educations,
    required this.isParentSide,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: educations.length,
      itemBuilder: (context, index) {
        final edu = educations[index];
        return EducationItem(education: edu, isParentSide: isParentSide);
      },
    );
  }
}
