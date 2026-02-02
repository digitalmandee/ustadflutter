import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustaad/Models/Tutor Side/earning_model.dart'; 
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/pref_keys.dart';
import 'package:ustaad/config/keys/urls.dart';
import 'package:ustaad/Helpers/utils.dart';

class TutorDashBoardProvider extends ChangeNotifier {
  final AppDio dio;
  TutorDashBoardProvider(BuildContext context) : dio = AppDio(context);

  List<MonthlyEarning> monthlyEarnings = [];
  Map<String, dynamic>? summary;
  String profileBalance = "0";
  String displayedBalance = "0";
  String bankName = "";
  String accountNumber = "";
  String unReadMessages = "";
  String tasks = "0";
  List<dynamic> tranferredHistory = [];
  String selectedMonth = "None"; // ✅ default option

  List<dynamic> upcomingSessions = [];
  List<dynamic> runningSessions = [];
  bool isLoading = false;

  Future<void> getTutorEarnings(BuildContext context) async {
    try {
      final response = await dio.get(path: AppUrls.getTutorEarnings);
      if (response.statusCode == 200) {
        final responseData = response.data["data"];
        monthlyEarnings = (responseData["monthlyEarnings"] as List)
            .map((e) => MonthlyEarning.fromJson(e))
            .toList();

        summary = responseData["summary"];

        selectedMonth = "None";
        displayedBalance = profileBalance;

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) debugPrint("getTutorEarnings error: $e");
    }
  }

  Future<void> getTutorProfile(context) async {
    try {
      final response = await dio.get(path: AppUrls.getTutorProfile);

      if (response.statusCode == 200) {
        final data = response.data["data"];
        final tutorData = data["user"]["Tutor"];
        profileBalance = (data["user"]["Tutor"]["balance"] ?? '0').toString();
        displayedBalance = profileBalance;
        tasks = data["totalSessions"]?.toString() ?? "0";
        bankName = tutorData["bankName"] ?? "";
        accountNumber = tutorData["accountNumber"] ?? "";
        unReadMessages = data["unreadMessageCount"]?.toString() ?? "0";
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(PrefKey.unreadMessageCount, unReadMessages);

        globalUnreadChat = unReadMessages;
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      String message = "Something went wrong $e";

      // if (e is DioException) {
      //   message = e.error?.toString() ?? "Check Internet Connection";
      // } else {
      //   message = e.toString();
      // }

      AppToast.error(
        context: context,
        msg: message,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBankDetails(
      context, String newBankName, String newAccountNumber) async {
    isLoading = true;
    notifyListeners();

    try {
      final body = {
        "bankName": newBankName,
        "accountNumber": newAccountNumber,
      };

      final response = await dio.put(
        path:
            "${AppUrls.baseUrl}tutor/bank-details", // ✅ tumhare baseUrl + endpoint
        data: body,
      );

      if (response.statusCode == 200) {
        // ✅ Update locally after successful API
        bankName = newBankName;
        accountNumber = newAccountNumber;

        AppToast.success(
          context: context,
          msg: "Bank details updated successfully",
        );

        notifyListeners();
      } else {
        AppToast.error(
          context: context,
          msg: response.data["errors"]?[0]?["message"] ??
              "Failed to update bank details",
        );
      }
    } catch (e) {
      AppToast.error(
        context: context,
        msg: "Something went wrong: $e",
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeSelectedMonth(String month) {
    selectedMonth = month;

    if (month == "None") {
      // ✅ show full profile balance
      displayedBalance = profileBalance;
    } else {
      final earning = monthlyEarnings.firstWhere(
        (e) => e.month == month,
        orElse: () => MonthlyEarning(month: month, earnings: 0, count: 0),
      );
      displayedBalance = earning.earnings.toString();
    }

    notifyListeners();
  }

  Future<void> getSessions(context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await dio.get(path: AppUrls.getsessions);
      final responseData = response.data;

      if (response.statusCode == 200 && responseData["data"] != null) {
        final sessions = responseData["data"]["sessions"] as List<dynamic>;
        final running =
            responseData["data"]["runningSessions"] as List<dynamic>;

        upcomingSessions =
            sessions.where((s) => s["status"] == "active").toList();
        runningSessions = running;
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      } else {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"]?[0]?["message"] ?? "Unknown error"}",
        );
      }
    } catch (e) {
      String message = "Something went wrong $e";

      // if (e is DioException) {
      //   message = e.error?.toString() ?? "Check Internet Connection";
      // }

      AppToast.error(
        context: context,
        msg: message,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPaymentRequests(context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await dio.get(path: AppUrls.getPaymentRequests);

      if (response.statusCode == 200) {
        final data = response.data["data"];
        tranferredHistory = data["paymentRequests"];
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      AppToast.error(
        context: context,
        msg: "Something went wrong: $e",
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    monthlyEarnings.clear();
    summary = null;

    profileBalance = "0";
    displayedBalance = "0";
    bankName = "";
    accountNumber = "";
    unReadMessages = "";
    tasks = "0";

    tranferredHistory.clear();
    upcomingSessions.clear();
    runningSessions.clear();

    selectedMonth = "None";
    isLoading = false;

    notifyListeners();
  }
}
