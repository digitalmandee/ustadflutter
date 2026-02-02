import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class NotificationProvider with ChangeNotifier {
  bool _isLoading = false;
  final AppDio _dio;

  NotificationProvider(BuildContext context) : _dio = AppDio(context);

  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> notifications = [];
  ////////// ..... Fetch All Notifications.... ////////
  Future<void> fetchNotifications(context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(path: AppUrls.getnotifications);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"] as List;
        notifications = List<Map<String, dynamic>>.from(data.reversed);
      } else {
        notifications = [];
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
      _isLoading = false;
      notifyListeners();
    }
  }

  ///////////// ....... Delete Multiple Notifications ........ ////////////
  Future<void> deleteNotifications(
    BuildContext context,
    List<String> ids,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = {"ids": ids};

      final response = await _dio.postJson(
        path: AppUrls.dellnotifications,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchNotifications(context);
      }
    } catch (e) {
      debugPrint("Error deleting notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    notifications = [];
    _isLoading = false;
    notifyListeners();
  }
}
