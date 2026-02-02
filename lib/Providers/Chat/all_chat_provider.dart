import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Chat/all_chat_model.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';

class AllChatProvider with ChangeNotifier {
  final AppDio dio;

  List<AllChatsModel> _chats = [];
  List<AllChatsModel> _filteredChats = [];

  bool _isLoading = true;

  AllChatProvider(BuildContext context) : dio = AppDio(context);

  List<AllChatsModel> get filteredChats => _filteredChats;

  List<AllChatsModel> get chats => _chats;
  bool get isLoading => _isLoading;

  Future<void> fetchChats(context) async {
    try {
      if (chats.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      final response = await dio.get(path: AppUrls.getAllChat);

      var responseData = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List conversations = responseData['data']['conversations'];

        _chats =
            conversations.map((json) => AllChatsModel.fromJson(json)).toList();
        _filteredChats = _chats;
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
        handleTokenExpiration();
      } else {
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
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

  void filterChats(String query) {
    if (query.isEmpty) {
      _filteredChats = _chats;
    } else {
      _filteredChats = _chats
          .where(
              (chat) => chat.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  void clear() {
    _chats.clear();
    _filteredChats.clear();
    _isLoading = false;
    notifyListeners();
  }
}
