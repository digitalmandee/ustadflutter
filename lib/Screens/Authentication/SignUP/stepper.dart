import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/Screens/Authentication/widgets/widgets.dart';

class SignupStepper extends StatelessWidget {
  final TabController tabController;

  const SignupStepper({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          stepIndicator("User Details", 0, context, controller: tabController),
          SizedBox(width: 5),
          stepIndicator("Add. Details", 1, context, controller: tabController),
          SizedBox(width: 5),
          stepIndicator(
            Staticdata.isActive ? "Next" : "OTP",
            2,
            context,
            controller: tabController,
          ),
        ],
      ),
    );
  }
}
