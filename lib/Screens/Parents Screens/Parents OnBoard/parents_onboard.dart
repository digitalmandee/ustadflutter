import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/Screens/Authentication/widgets/widgets.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parents%20OnBoard/child_profile.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parents%20OnBoard/onBoard_data_model.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parents%20OnBoard/parent_bank_selection.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parents%20OnBoard/parents_verify.dart';

class ParentsOnboardScreen extends StatefulWidget {
  const ParentsOnboardScreen({super.key});

  @override
  State<ParentsOnboardScreen> createState() => _ParentsOnboardScreenState();
}

class _ParentsOnboardScreenState extends State<ParentsOnboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int currentStep = 0;
  late ParentOnboardData parentOnboardData;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    parentOnboardData = ParentOnboardData();
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
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppTheme.white,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    stepIndicator(
                      "Profile",
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
                      "Verifications",
                      2,
                      context,
                      controller: _tabController,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ParentChildProfile(onTap: _goToNextStep),
                    ParentBankSelectionScreen(
                      onTap: _goToNextStep,
                      onBackTap: _goToPreviousStep,
                      parentOnboardData: parentOnboardData,
                    ),
                    ParentsVerificationScreen(
                      parentOnboardData: parentOnboardData,
                      onBackTap: _goToPreviousStep,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
