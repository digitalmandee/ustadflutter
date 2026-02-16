import 'package:flutter/material.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';

Widget passwordRequirements() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.appText("Must contain at least:",
          fontSize: 12, fontWeight: FontWeight.w400),
      requirement("8 Characters"),
      requirement("One Capital letter"),
      requirement("One Number or Symbol"),
    ],
  );
}

Widget requirement(String text) {
  return Row(
    children: [
      Icon(Icons.circle, size: 8, color: AppTheme.grey),
      SizedBox(width: 8),
      AppText.appText(text,
          fontSize: 12, fontWeight: FontWeight.w400, textColor: AppTheme.grey),
    ],
  );
}

Widget stepIndicator(String label, int step, context, {required controller}) {
  int currentIndex = controller.index;

  bool isCompleted = step < currentIndex;
  bool isActive = step == currentIndex;

  Color getColor() {
    if (isActive) {
      return Colors.yellow; // Active step
    } else if (isCompleted) {
      return AppTheme.appColor; // Completed step
    } else {
      return AppTheme.grey; // Pending step
    }
  }

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 3,
          // width: width,
          color: getColor(),
        ),
        const SizedBox(height: 10),
        AppText.appText(label,
            fontSize: 14,
            textColor: AppTheme.lableText,
            fontWeight: FontWeight.w500),
      ],
    ),
  );
}
