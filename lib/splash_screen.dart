import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:flutterustad/Screens/BottomNavBar/bottom_bar.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    fetchGlobalPaywallStatus();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
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
      if (token != null && token.isNotEmpty) {
        if (role == "PARENT" && isOnBoard != "required") {
          pushReplacement(context, const BottomNavView(tutor: false));
        } else if (role == "TUTOR" && isOnBoard != "required") {
          pushReplacement(context, const BottomNavView(tutor: true));
        } else {
          pushReplacement(context, const LogInScreen());
        }
      } else {
        pushReplacement(context, const LogInScreen());
      }
    });
  }

  /// Fetch global paywall status from Firestore
  Future<void> fetchGlobalPaywallStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('is_active')
          .doc('GegLUC5O7c0mgm6bARgc')
          .get();

      final data = snapshot.data();
      log('here is before fetch status: ${Staticdata.isActive} ');
      if (data != null) {
        final isactiveapp = data['app_active'] as bool? ?? false;
        log('here is firebase status: $isactiveapp');

        Staticdata.isActive = isactiveapp;

        if (isactiveapp) {
          log("is active data set to  ${Staticdata.isActive}");
        } else {
          // 🔑 Paywall disabled → unlock premium for everyone
          Staticdata.isActive = false;
          log("is active data set to false ${Staticdata.isActive}");
        }

        log("final active data value set  = ${Staticdata.isActive}");
      } else {
        log("⚠️ No document found, defaulting to paywall enabled");
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
