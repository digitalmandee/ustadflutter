import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/education/add_edu_sheet.dart';

class EducationItem extends StatelessWidget {
  final dynamic education;
  final bool isParentSide;

  const EducationItem({
    super.key,
    required this.education,
    required this.isParentSide,
  });

  String _formatYearSafe(dynamic date) {
    if (date == null) return "";

    // 👇 API se "Present" aa raha hai
    if (date is String && date.toLowerCase() == "present") {
      return "Present";
    }

    try {
      return DateTime.parse(date).year.toString();
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final startYear = _formatYearSafe(
      isParentSide ? education["startDate"] : education.startDate,
    );
    final endYear = _formatYearSafe(
      isParentSide ? education["endDate"] : education.endDate,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: AppText.appText(
              "$startYear — $endYear",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textColor: const Color(0xff2A2A2A),
            ),
          ),
          SizedBox(width: 10),
          Expanded(child: _buildEducationDetails(startYear, endYear)),
          if (!isParentSide) _buildEditButton(context),
        ],
      ),
    );
  }

  Widget _buildEducationDetails(String startYear, String endYear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText(
          isParentSide
              ? capitalizeEachWord(education["institute"])
              : capitalizeEachWord(education.institute),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: const Color(0xff2A2A2A),
        ),
        const SizedBox(height: 5),
        AppText.appText(
          isParentSide
              ? (education["degree"]?.toString().toUpperCase() ?? "")
              : (education.degree?.toString().toUpperCase() ?? ""),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          textColor: const Color(0xff2A2A2A),
        ),
        const SizedBox(height: 5),
        AppText.appText(
          isParentSide ? education["description"] : education.description,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          textColor: const Color(0xff878787),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
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
          builder: (context) => AddEducationBottomSheet(education: education),
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
