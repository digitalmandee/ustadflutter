import 'package:flutter/material.dart';
import 'package:flutterustad/Screens/Authentication/widgets/widgets.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/bank_selection.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/data_model.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/doc_verification.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/location_add.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/subject_screen.dart';
import 'package:flutterustad/Helpers/static_data.dart';

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

    _tabController = TabController(length: 4, vsync: this);
    onboardData = TutorOnboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tabController.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  stepIndicator(
                    "Subjects",
                    0,
                    context,
                    controller: _tabController,
                  ),
                  SizedBox(width: 5),
                  stepIndicator(
                    Staticdata.isActive ? "Next" : "Banks",
                    1,
                    context,
                    controller: _tabController,
                  ),
                  SizedBox(width: 5),
                  stepIndicator(
                    "Verify",
                    2,
                    context,
                    controller: _tabController,
                  ),
                  SizedBox(width: 5),
                  stepIndicator(
                    "Location",
                    3,
                    context,
                    controller: _tabController,
                  ),
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
                    onTap: _goToNextStep,
                  ),
                  BankSelectionScreen(
                    onboardData: onboardData,
                    onTap: _goToNextStep,
                    onBackTap: _goToPreviousStep,
                  ),
                  TutorDocVerificationScreen(
                    onboardData: onboardData,
                    onBackTap: _goToPreviousStep,
                    onTap: _goToNextStep,
                  ),
                  OnboardLocation(onBackTap: _goToPreviousStep),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousStep() {
    if (_tabController.index == 0) return;
    setState(() {
      _tabController.animateTo(_tabController.index - 1);
    });
  }

  void _goToNextStep() {
    if (_tabController.index == _tabController.length - 1) return;
    setState(() {
      _tabController.animateTo(_tabController.index + 1);
    });
  }
}
