import 'package:flutter/material.dart';
import 'package:ustaad/Custom widgets/app_button.dart';
import 'package:ustaad/Custom widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';

void showSignupPopup(
  BuildContext context, {
  required Function() onEmailTap,
  required Future<void> Function() onGoogleTap,
  bool isGoogleLoading = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white, // ✅ White background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 20),
            title: Center(
              child: AppText.appText(
                "Sign Up",
                textColor: AppTheme.appColor,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            content: SizedBox(
              width: 320, // ✅ Slightly wider popup
              height: 180, // ✅ Increased height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton.appButton(
                    "Sign Up with Email",
                    context: context,
                    textColor: AppTheme.lableText,
                    borderColor: AppTheme.borderCOlor,
                    backgroundColor: AppTheme.white,
                    image: "assets/images/email.png",
                    onTap: onEmailTap,
                  ),
                  const SizedBox(height: 16),
                  loginDivider("OR"),
                  const SizedBox(height: 16),

                  AppButton.appButton(
                    isGoogleLoading ? "Signing up..." : "Sign Up with Google",
                    context: context,
                    onTap: () async {
                      setState(() => isGoogleLoading = true);
                      await onGoogleTap();
                      if (context.mounted) {
                        setState(() => isGoogleLoading = false);
                      }
                    },
                    textColor: AppTheme.lableText,
                    borderColor: AppTheme.borderCOlor,
                    backgroundColor: AppTheme.white,
                    image: "assets/images/google.png",
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}





