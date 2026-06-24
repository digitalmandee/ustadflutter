import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:flutterustad/Screens/BottomNavBar/bottom_bar.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/urls.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _loadConfigAndNavigate();
  }

  Future<void> _loadConfigAndNavigate() async {
    if (Platform.isAndroid) {
      await fetchGlobalPaywallStatus();
    } else {
      await fetchGlobalPaywallStatusIOS();
    }

    if (!mounted) return;
    _navigateToHome(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome(context) {
    Future.delayed(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(PrefKey.authorization);
      String? role = prefs.getString(PrefKey.userRole);
      String? isOnBoard = prefs.getString(PrefKey.onBoard);
      bool isGuestUser = prefs.getBool('is_guest') ?? false;
      if (token != null && token.isNotEmpty) {
        if (role == "PARENT" && isOnBoard != "required") {
          pushReplacement(context, const BottomNavView(tutor: false));
        } else if (role == "TUTOR" && isOnBoard != "required") {
          pushReplacement(context, const BottomNavView(tutor: true));
        } else if (role == "GUEST" && Staticdata.guestmood) {
          isGuest = true;
          globalUserId = prefs.getString(PrefKey.id) ?? '';
          globalUserFirstName = prefs.getString(PrefKey.userFirstName) ?? '';
          globalUserLastName = prefs.getString(PrefKey.userLastName) ?? '';
          globalUserRole = role;
          globalToken = token;
          pushReplacement(context, const BottomNavView(tutor: false));
        } else {
          pushReplacement(context, const LogInScreen());
        }
      } else if (isGuestUser && Staticdata.guestmood) {
        await _loginGuestFromSplash(context);
      } else {
        pushReplacement(context, const LogInScreen());
      }
    });
  }

  Future<void> _loginGuestFromSplash(BuildContext context) async {
    try {
      final response = await AppDio(
        context,
      ).postJson(path: AppUrls.guestLogin, data: {});

      if (!context.mounted) return;
      if (response.statusCode != 200) {
        pushReplacement(context, const LogInScreen());
        return;
      }

      final data = response.data["data"];
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(PrefKey.authorization, data["token"] ?? '');
      await prefs.setString(PrefKey.id, "${data["id"] ?? ''}");
      await prefs.setString(PrefKey.userRole, data["role"] ?? 'GUEST');
      await prefs.setString(PrefKey.userFirstName, data["firstName"] ?? '');
      await prefs.setString(PrefKey.userLastName, data["lastName"] ?? '');
      await prefs.setString(PrefKey.userPic, data["image"] ?? '');
      await prefs.setString(PrefKey.onBoard, data["isOnBoard"] ?? '');
      await prefs.setBool('is_guest', true);

      isGuest = true;
      globalUserId = "${data["id"] ?? ''}";
      globalUserFirstName = data["firstName"] ?? "Guest";
      globalUserLastName = data["lastName"] ?? "Parent";
      globalUserRole = data["role"] ?? "GUEST";
      globalToken = data["token"] ?? "";
      globalUserPic = data["image"] ?? '';
      globalUserOnBoardStatus = data["isOnBoard"] ?? '';

      if (!context.mounted) return;
      pushReplacement(context, const BottomNavView(tutor: false));
    } catch (e) {
      if (!context.mounted) return;
      pushReplacement(context, const LogInScreen());
    }
  }

  Future<void> fetchGlobalPaywallStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('is_active')
          .doc('GegLUC5O7c0mgm6bARgc')
          .get();

      final data = snapshot.data();

      if (data != null) {
        final isactiveapp = data['4appactive'] as bool? ?? false;
        final showPayment = data['2showpayment'] as bool? ?? false;

        // NEW
        final guestMode = data['guestmoodandroid'] as bool? ?? false;

        Staticdata.isActive = isactiveapp;
        Staticdata.showPayment = showPayment;

        // NEW
        Staticdata.guestmood = guestMode;

        log(
          "Android → isActive: ${Staticdata.isActive}, "
          "showPayment: ${Staticdata.showPayment}, "
          "guestMode: ${Staticdata.guestmood}",
        );
      }
    } catch (e) {
      log("❌ Failed to fetch firestore flag: $e");
    }
  }

  Future<void> fetchGlobalPaywallStatusIOS() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('is_active')
          .doc('GegLUC5O7c0mgm6bARgc')
          .get();

      final data = snapshot.data();

      if (data != null) {
        final iosIsActiveApp = data['2ios_app_active'] as bool? ?? false;

        final iosShowPayment = data['2ios_showpayment'] as bool? ?? false;

        // NEW
        final iosGuestMode = data['guestmoodios'] as bool? ?? false;

        Staticdata.isActive = iosIsActiveApp;
        Staticdata.showPayment = iosShowPayment;

        // NEW
        Staticdata.guestmood = iosGuestMode;

        log(
          "iOS → isActive: ${Staticdata.isActive}, "
          "showPayment: ${Staticdata.showPayment}, "
          "guestMode: ${Staticdata.guestmood}",
        );
      }
    } catch (e) {
      log("❌ Failed to fetch firestore flag: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: SizedBox(
            height: 200,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 150),
                Image.asset('assets/images/ustaad.png', width: 76, height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
