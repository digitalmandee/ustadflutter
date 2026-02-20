import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Drawer/Contracts/contracts.dart';
import 'package:ustaad/Screens/Drawer/Cost%20Setting/cost_setting.dart';
import 'package:ustaad/Screens/Drawer/Earnings/parent_refunding.dart';
import 'package:ustaad/Screens/Drawer/Earnings/tutor_earning_dashboard.dart';
import 'package:ustaad/Screens/Drawer/location_screen.dart';
import 'package:ustaad/Screens/Drawer/Setting/setting_screen.dart';
import 'package:ustaad/Screens/Drawer/logout.dart';

class SideMenuDrawer extends StatefulWidget {
  final VoidCallback? crossOnTap;
  final bool isTutor;

  const SideMenuDrawer({super.key, this.crossOnTap, required this.isTutor});

  @override
  State<SideMenuDrawer> createState() => _SideMenuDrawerState();
}

class _SideMenuDrawerState extends State<SideMenuDrawer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, bottom: 95),
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Container(
          color: AppTheme.primaryCOlor, // Your teal/blue shade
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.crossOnTap,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    "assets/images/arrow.png",
                    height: 24,
                  ),
                ),
              ),
              widget.isTutor == true
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ListView(
                          children: [
                            // menuItem(
                            //     onTap: () {},
                            //     "Check Parent Request",
                            //     "assets/images/checkParentRequest.png"),

                            menuItem(onTap: () {
                              push(context, TutorEarningScreen());
                            },
                                'Earnings Dashboard',
                                "assets/images/earningDashBoard.png",
                                "View your total earnings, and payment summaries at one place."),
                            menuItem(onTap: () {
                              push(
                                  context,
                                  ContractScreen(
                                    isParentSide: false,
                                  ));
                            }, 'Contracts', "assets/images/documentVerify.png",
                                "Manage your active and past tutoring contracts with parents, including subjects and schedules."),
                            // menuItem(
                            //     onTap: () {},
                            //     'Documents/Verifications',
                            //     "assets/images/documentVerify.png"),
                            menuItem(onTap: () {
                              push(context, CostSetting());
                            }, 'Cost Settings', "assets/images/costSetting.png",
                                "Set and update your hourly rates, subject-wise charges, and availability preferences."),
                            menuItem(onTap: () {
                              push(context, SettingScreen());
                            }, 'Settings', "assets/images/setting.png",
                                "Edit your profile, change email, password and control account preferences."),
                            menuItem(onTap: () async {
                              final url =
                                  Uri.parse("https://ustaad.online/contact/");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            }, 'Help', "assets/images/help.png",
                                "Get support, view FAQs, and contact the Ustaad support team when needed."),
                            menuItem(onTap: () {
                              push(context, LocationScreen());
                            },
                                'Location Selection',
                                "assets/images/location.png",
                                "Choose your preferred teaching locations or enable online tutoring options."),
                            menuItem(onTap: () async {
                              await AuthService.logout(context);
                            }, 'Log Out', "assets/images/logout.png",
                                "Sign out securely to keep your account safe."),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView(
                        children: [
                          menuItem(onTap: () {
                            push(context, ParentRefundingScreen());
                          },
                              'Refunding Dashboard',
                              "assets/images/earningDashBoard.png",
                              "View your refundings, and payment summaries at one place."),
                          menuItem(onTap: () {
                            push(
                                context,
                                ContractScreen(
                                  isParentSide: true,
                                ));
                          }, 'Contracts', "assets/images/documentVerify.png",
                              "View and manage all your tutoring agreements, including tutor details, subjects, and contract duration."),
                          // menuItem(
                          //     onTap: () {},
                          //     'Payments',
                          //     "assets/images/earningDashBoard.png",
                          //     "Check payment history, upcoming payments, and manage billing securely in one place."),
                          menuItem(onTap: () {
                            push(context, SettingScreen());
                          }, 'Settings', "assets/images/setting.png",
                              "Update your profile, change Gmail , password and control account preferences."),
                          menuItem(onTap: () async {
                            final url =
                                Uri.parse("https://ustaad.online/contact/");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          }, 'Help', "assets/images/help.png",
                              "Access FAQs, contact support, and get assistance for any issues or questions."),
                          menuItem(onTap: () async {
                            await AuthService.logout(context);
                          }, 'Log Out', "assets/images/logout.png",
                              "Sign out of your account safely to keep your information secure."),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuItem(String title, String img, String desc,
      {required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              img,
              height: 24,
              color: AppTheme.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText(
                    title,
                    fontWeight: FontWeight.w600,
                    textColor: Colors.white,
                    fontSize: 16,
                  ),
                  SizedBox(height: 4),
                  AppText.appText(
                    desc,
                    textColor: Colors.white70,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
