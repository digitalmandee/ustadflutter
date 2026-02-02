import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Authentication/widgets/widgets.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parents%20OnBoard/child_profile.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parents%20OnBoard/parents_verify.dart';

class ParentsOnboardScreen extends StatefulWidget {
  const ParentsOnboardScreen({super.key});

  @override
  State<ParentsOnboardScreen> createState() => _ParentsOnboardScreenState();
}

class _ParentsOnboardScreenState extends State<ParentsOnboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int currentStep = 0;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  stepIndicator(
                      "Profile", 0, context, ScreenSize(context).width * 0.42,
                      controller: _tabController),
                  stepIndicator("Verifications", 1, context,
                      ScreenSize(context).width * 0.42,
                      controller: _tabController),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ParentChildProfile(
                    onTap: () {
                      if (_tabController.index < 1) {
                        setState(() {
                          _tabController.animateTo(_tabController.index + 1);
                        });
                      }
                    },
                    onBackTap: () {
                      if (_tabController.index < 1) {
                        setState(() {
                          _tabController.animateTo(_tabController.index - 1);
                        });
                      }
                    },
                  ),
                  ParentsVerificationScreen(
                    onBackTap: () {
                      if (_tabController.index < 2) {
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
