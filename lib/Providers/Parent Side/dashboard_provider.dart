import 'package:flutter/material.dart';
import 'package:ustaad/Models/Parent%20Side/spending_model.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/config/keys/urls.dart';

class ParentDashboardProvider extends ChangeNotifier {
  final AppDio dio;

  ParentDashboardProvider(BuildContext context) : dio = AppDio(context);

  bool isLoading = false;
  bool hasFetched = false; // ✅ new flag
  List<MonthlySpending> monthlySpending = [];
  Map<String, dynamic> summary = {};

  Future<void> getMonthlySpending(context, {bool forceRefresh = false}) async {
    // ✅ Only show loader if it's first time or forced refresh
    if (!hasFetched || forceRefresh) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final response = await dio.get(path: AppUrls.getParentSpendings);
      final data = response.data;

      if (response.statusCode == 200 && data["data"] != null) {
        monthlySpending = (data["data"]["monthlySpending"] as List)
            .map((e) => MonthlySpending.fromJson(e))
            .toList();
        summary = data["data"]["summary"] ?? {};
        hasFetched = true; // ✅ Mark as fetched
      } else {
        AppToast.error(
          context: context,
          msg: data["message"] ?? "Failed to fetch spending",
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
    monthlySpending.clear();
    summary.clear();
    isLoading = false;
    hasFetched = false;
    notifyListeners();
  }
}
