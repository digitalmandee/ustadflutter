import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._();

  static final GoogleSignInService instance = GoogleSignInService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  static const String webClientId =
      "1022247289156-m8el3dk5mqb3jrj1smdrmuvk2fqk9n9e.apps.googleusercontent.com";

  static const String iosClientId =
      "1022247289156-3c1g398qovpn8o3ei9dv6not6m5lcn4d.apps.googleusercontent.com";

  Future<void> init() async {
    if (_initialized) {
      log("GOOGLE INIT: already initialized");
      return;
    }

    log("GOOGLE INIT: started");
    log("GOOGLE INIT: Platform Android = ${Platform.isAndroid}");
    log("GOOGLE INIT: Platform iOS = ${Platform.isIOS}");

    try {
      if (Platform.isAndroid) {
        log("GOOGLE INIT: Android initialize with serverClientId only");

        await _googleSignIn.initialize(serverClientId: webClientId);
      } else if (Platform.isIOS) {
        log("GOOGLE INIT: iOS initialize with clientId + serverClientId");

        await _googleSignIn.initialize(
          clientId: iosClientId,
          serverClientId: webClientId,
        );
      }

      _initialized = true;
      log("GOOGLE INIT: completed successfully");
    } catch (e, st) {
      log("GOOGLE INIT ERROR: $e");
      log("GOOGLE INIT STACKTRACE: $st");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signIn(BuildContext context) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No internet connection.")),
          );
        }
        return null;
      }

      final account = await _googleSignIn.authenticate();

      final auth = account.authentication;
      final userData = {
        "displayName": account.displayName,
        "email": account.email,
        "photoUrl": account.photoUrl,
        "id": account.id,
        "idToken": auth.idToken,
      };

      if (kDebugMode) {
        print("object$userData");
      }

      return userData;
    } on SocketException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No internet connection.")),
        );
      }
      return null;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In failed. Try again.")),
        );
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
