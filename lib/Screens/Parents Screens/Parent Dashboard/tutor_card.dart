import 'package:flutter/material.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/base_image.dart';
import 'package:ustaad/Helpers/subjets_format.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Profile/tutor_profile.dart';

class TutorCard extends StatelessWidget {
  final dynamic tutor;

  const TutorCard({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: InkWell(
        onTap: () => push(
          context,
          TutorProfileScreen(
            isParentSide: true,
            name: "${tutor.firstName} ${tutor.lastName}",
            tutorId: tutor.tutorId,
            experience: tutor.experience,
          ),
        ),
        child: Card(
          margin: EdgeInsets.all(0),
          color: AppTheme.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            height: 103,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border(
                    left: BorderSide(color: AppTheme.primaryCOlor, width: 4))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImage(),
                const SizedBox(width: 10),
                _buildTutorInfo(context),
                const Spacer(),
                _buildTutorDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: AppTheme.primaryCOlor),
      ),
      child: tutor.image.isEmpty
          ? ClipOval(child: Image.asset("assets/images/tutorProfile.jpeg"))
          : tutor.image.startsWith("http")
              ? ClipOval(
                  child: Image.network(
                    tutor.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/images/tutorProfile.jpeg");
                    },
                  ),
                )
              : ClipOval(child: Base64ImageWidget(base64String: tutor.image)),
    );
  }

  Widget _buildTutorInfo(BuildContext context) {
    return SizedBox(
      width: ScreenSize(context).width * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.appText("${tutor.firstName} ${tutor.lastName}",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              maxlines: 1),
          AppText.appText(
            formatSubjects(tutor.subjects),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            maxlines: 3,
            overflow: TextOverflow.ellipsis,
            textColor: const Color(0xff4D5874),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppText.appText("${tutor.experience} year Exp.",
            fontSize: 16, fontWeight: FontWeight.w500),
        AppText.appText(tutor.address,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            textColor: const Color(0xff4D5874)),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            AppText.appText("${tutor.rating}",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: const Color(0xff4D5874)),
          ],
        ),
      ],
    );
  }
}
