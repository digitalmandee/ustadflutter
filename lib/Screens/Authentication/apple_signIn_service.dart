import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInService {
  AppleSignInService._();
  static final AppleSignInService instance = AppleSignInService._();

  Future<void> init() async {
    // Apple Sign-In does not need initialization like Google.
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

      final bool isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Apple Sign-In is not available on this device."),
            ),
          );
        }
        return null;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final prefs = await SharedPreferences.getInstance();

      final String appleId = credential.userIdentifier ?? "";
      final String identityToken = credential.identityToken ?? "";

      final String? tokenEmail = _getEmailFromIdentityToken(identityToken);

      String email = credential.email ?? "";

      if (email.trim().isEmpty && tokenEmail != null) {
        email = tokenEmail;
      }

      if (email.trim().isEmpty && appleId.isNotEmpty) {
        email = prefs.getString("apple_email_$appleId") ?? "";
      }

      String firstName = credential.givenName ?? "";
      String lastName = credential.familyName ?? "";

      if (firstName.trim().isEmpty && appleId.isNotEmpty) {
        firstName = prefs.getString("apple_first_name_$appleId") ?? "";
      }

      if (lastName.trim().isEmpty && appleId.isNotEmpty) {
        lastName = prefs.getString("apple_last_name_$appleId") ?? "";
      }

      if (email.trim().isNotEmpty && appleId.isNotEmpty) {
        await prefs.setString("apple_email_$appleId", email.trim());
      }

      if (firstName.trim().isNotEmpty && appleId.isNotEmpty) {
        await prefs.setString("apple_first_name_$appleId", firstName.trim());
      }

      if (lastName.trim().isNotEmpty && appleId.isNotEmpty) {
        await prefs.setString("apple_last_name_$appleId", lastName.trim());
      }

      final String displayName = [
        firstName,
        lastName,
      ].where((name) => name.trim().isNotEmpty).join(" ");

      if (email.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Apple did not return email. Please try again or use another login method.",
              ),
            ),
          );
        }
        return null;
      }

      final userData = {
        // Same keys as GoogleSignupDetail expects
        "displayName": displayName,
        "email": email.trim(),
        "photoUrl": "",
        "id": appleId,
        "idToken": identityToken,

        // Apple-specific keys
        "provider": "apple",
        "appleId": appleId,
        "identityToken": identityToken,
        "authorizationCode": credential.authorizationCode,
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
      };

      if (kDebugMode) {
        print("Apple userData: $userData");
      }

      return userData;
    } on SocketException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No internet connection.")),
        );
      }
      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Apple Sign-In failed. Try again.")),
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Apple Sign-In Error: $e");
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Apple Sign-In failed. Try again.")),
        );
      }
      return null;
    }
  }

  String? _getEmailFromIdentityToken(String identityToken) {
    try {
      if (identityToken.trim().isEmpty) return null;

      final parts = identityToken.split('.');

      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = jsonDecode(decodedPayload);

      final email = payloadMap["email"];

      if (email == null) return null;

      final emailText = email.toString().trim();

      if (emailText.isEmpty) return null;

      return emailText;
    } catch (e) {
      if (kDebugMode) {
        print("Apple identityToken decode error: $e");
      }
      return null;
    }
  }
}
