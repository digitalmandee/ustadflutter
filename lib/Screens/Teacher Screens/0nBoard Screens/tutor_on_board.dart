import 'package:flutter/material.dart';
import 'package:flutterustad/Screens/Authentication/widgets/widgets.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/bank_selection.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/data_model.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/doc_verification.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/location_add.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/subject_screen.dart';

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
                    "Subjects",
                    0,
                    context,
                    controller: _tabController,
                  ),
                  SizedBox(width: 5),
                  stepIndicator(
                    "Banks",
                    1,
                    context,
                    controller: _tabController,
                  ),
                  SizedBox(width: 5),
                  stepIndicator(
                    "Verifications",
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
                    onTap: () {
                      if (_tabController.index < 3) {
                        setState(() {
                          _tabController.animateTo(_tabController.index + 1);
                        });
                      }
                    },
                  ),
                  OnboardLocation(
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
            ),
          ],
        ),
      ),
    );
  }
}
