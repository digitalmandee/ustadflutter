import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Helpers/utils.dart' as Navigator;
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';

class AuthService {
  static Future<void> logout(context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GifLoader(),
    );

    final dio = AppDio(context);

    try {
      Response response = await dio.post(
        path: AppUrls.logout,
      );

      Navigator.pop(context); // ✅ Close loader FIRST

      if (response.statusCode == 200) {
        handleLogOut(context, isLogout: true);
      } else {
        AppToast.error(
          context: context,
          msg: "Logout failed. Please try again.",
        );
      }
    } catch (e) {
      Navigator.pop(context); // ✅ Close loader on error

      String message = "Something went wrong";

      if (e is DioException) {
        message = e.response?.data?["message"] ?? "Check Internet Connection";
      }

      AppToast.error(
        context: context,
        msg: message,
      );
    }
  }
}
