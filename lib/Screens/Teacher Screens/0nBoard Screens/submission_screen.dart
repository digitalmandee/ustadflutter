import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/BottomNavBar/bottom_bar.dart';

class SubmissionCompleteScreen extends StatelessWidget {
  final bool tutor;
  const SubmissionCompleteScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Green checkmark icon
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                color: AppTheme.white,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppTheme.appColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main title
              AppText.appText(
                "You're Done From Your Side!",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                textColor: Colors.black,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtext
              AppText.appText(
                "Let us verify your submission. Meanwhile you can have a look at your App. Hope you'll have a wonderful time",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textColor: Color(0xff4D5874),
                textAlign: TextAlign.center,
                maxlines: 3,
              ),

              const SizedBox(height: 32),

              // Custom Button
              AppButton.appButton(
                "Go to Dashboard",
                context: context,
                backgroundColor: Colors.transparent,
                textColor: Color(0xff4D5874),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                border: true,
                borderColor: Colors.grey.shade300,
                onTap: () {
                  push(context, BottomNavView(tutor: tutor));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
