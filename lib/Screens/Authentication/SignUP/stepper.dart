import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Authentication/widgets/widgets.dart';

class SignupStepper extends StatelessWidget {
  final TabController tabController;

  const SignupStepper({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          stepIndicator(
              "User Details", 0, context, ScreenSize(context).width * 0.27,
              controller: tabController),
          stepIndicator(
              "Add. Details", 1, context, ScreenSize(context).width * 0.27,
              controller: tabController),
          stepIndicator("OTP", 2, context, ScreenSize(context).width * 0.27,
              controller: tabController),
        ],
      ),
    );
  }
}
