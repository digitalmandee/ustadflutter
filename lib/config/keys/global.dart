import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustaad/Providers/Chat/all_chat_provider.dart';
import 'package:ustaad/Providers/Contracts/contract_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/dashboard_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/get_tutors_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:ustaad/Providers/Tutor%20Side/location_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/subject_cost_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_veirfy_provider.dart';
import 'package:ustaad/Providers/notification/notification_provider.dart';
import 'package:ustaad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:ustaad/Screens/Chats/socket.dart';
import 'package:ustaad/config/keys/pref_keys.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String? globalUserId;
String? globalUserFirstName;
String? globalUserLastName;
String? globalUserRole;
String? globalToken;
String? globalUserPic;
double? globalParentLatitutde;
String? globalNotiCount;
double? globalParentLongitude;
String? globalUserOnBoardStatus;
String? globalGoogleId;

Future<void> getPrefData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  globalUserId = prefs.getString(PrefKey.id) ?? '';
  globalUserFirstName = prefs.getString(PrefKey.userFirstName) ?? '';
  globalUserLastName = prefs.getString(PrefKey.userLastName) ?? '';
  globalUserRole = prefs.getString(PrefKey.userRole) ?? '';
  globalUserPic = prefs.getString(PrefKey.userPic) ?? '';
  globalToken = prefs.getString(PrefKey.authorization) ?? '';
  globalGoogleId = prefs.getString(PrefKey.isGoogleId) ?? '';
  globalUserOnBoardStatus = prefs.getString(PrefKey.onBoard) ?? '';
  globalNotiCount = prefs.getString(PrefKey.notiCount) ?? '0';
}

void handleTokenExpiration() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  globalUserId = null;
  globalUserFirstName = null;
  globalUserLastName = null;
  globalUserRole = null;
  globalNotiCount = null;
  globalToken = null;
  globalUserPic = null;
  globalGoogleId = null;

  globalParentLatitutde = null;
  globalParentLongitude = null;
  globalUserOnBoardStatus = null;

  prefs.clear();
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LogInScreen()),
    (route) => false,
  );
}

void handleLogOut(context, {bool isLogout = false}) async {
  /// 1️⃣ Providers clear
  Provider.of<FileProvider>(context, listen: false).clearAll();
  Provider.of<ExperienceProvider>(context, listen: false).clear();
  Provider.of<AboutProvider>(context, listen: false).clear();
  Provider.of<EducationProvider>(context, listen: false).clear();
  Provider.of<AllChatProvider>(context, listen: false).clear();
  Provider.of<CostSettingProvider>(context, listen: false).clear();
  Provider.of<LocationProvider>(context, listen: false).clear();
  Provider.of<GetTutorsProvider>(context, listen: false).clear();
  Provider.of<ParentProfileProvider>(context, listen: false).clear();
  Provider.of<TutorDashBoardProvider>(context, listen: false).clear();
  Provider.of<ParentDashboardProvider>(context, listen: false).clear();
  Provider.of<ContractProvider>(context, listen: false).clear();
  Provider.of<TutorEditProfileProvider>(context, listen: false).clear();
  Provider.of<NotificationProvider>(context, listen: false).clear();

  print("🗑 Global session cleared");
  await FirebaseMessaging.instance.deleteToken();
  SocketService().dispose();
  print("🧹 Socket disposed on logout");

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => LogInScreen(showLogoutMessage: true),
    ),
    (route) => false,
  );
}

Future<void> clearAppSession() async {
  globalUserId = null;
  globalUserFirstName = null;
  globalUserLastName = null;
  globalUserRole = null;
  globalToken = null;
  globalGoogleId = null;
  globalUserPic = null;
  globalNotiCount = null;
  globalParentLatitutde = null;
  globalParentLongitude = null;
  globalUserOnBoardStatus = null;

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
