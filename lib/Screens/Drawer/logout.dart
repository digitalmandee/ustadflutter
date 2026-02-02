import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';
import 'package:ustaad/Helpers/utils.dart';

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

      if (response.statusCode == 200) {
        handleLogOut(context, isLogout: true);
      } else {
        AppToast.error(
          context: context,
          msg: "Logout failed. Please try again.",
        );
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(
        context: context,
        msg: message,
      );
    }
  }
}
