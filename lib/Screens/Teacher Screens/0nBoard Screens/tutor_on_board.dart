import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Authentication/widgets/widgets.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/bank_selection.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/data_model.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/doc_verification.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/subject_screen.dart';

class TutorOnboardScreen extends StatefulWidget {
  const TutorOnboardScreen({super.key});

  @override
  State<TutorOnboardScreen> createState() => _TutorOnboardScreenState();
}

class _TutorOnboardScreenState extends State<TutorOnboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TutorOnboardData onboardData;
  int currentStep = 0;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    onboardData = TutorOnboardData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  stepIndicator(
                      "Subjects", 0, context, ScreenSize(context).width * 0.27,
                      controller: _tabController),
                  stepIndicator(
                      "Banks", 1, context, ScreenSize(context).width * 0.27,
                      controller: _tabController),
                  stepIndicator("Verifications", 2, context,
                      ScreenSize(context).width * 0.27,
                      controller: _tabController),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  SubjectSelectionScreen(
                    onboardData: onboardData,
                    onTap: () {
                      if (_tabController.index < 2) {
                        setState(() {
                          _tabController.animateTo(_tabController.index + 1);
                        });
                      }
                    },
                  ),
                  BankSelectionScreen(
                    onboardData: onboardData,
                    onTap: () {
                      if (_tabController.index < 2) {
                        setState(() {
                          _tabController.animateTo(_tabController.index + 1);
                        });
                      }
                    },
                    onBackTap: () {
                      if (_tabController.index < 2) {
                        setState(() {
                          _tabController.animateTo(_tabController.index - 1);
                        });
                      }
                    },
                  ),
                  TutorDocVerificationScreen(
                    onboardData: onboardData,
                    onBackTap: () {
                      if (_tabController.index < 3) {
                        setState(() {
                          _tabController.animateTo(_tabController.index - 1);
                        });
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
