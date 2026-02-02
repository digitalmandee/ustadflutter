import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  GoogleSignInService._();
  static final GoogleSignInService instance = GoogleSignInService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> init() async {
    await _googleSignIn.initialize(
      serverClientId:
          '349544989753-bpcme9hi67ipua3iudgt5fmm5j692epa.apps.googleusercontent.com',
    );
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
      // if (context.mounted) {
      //   // ScaffoldMessenger.of(context).showSnackBar(
      //   //   SnackBar(
      //   //     content: Text("Signed in as ${account.displayName ?? 'User'}"),
      //   //   ),
      //   // );
      // }

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
