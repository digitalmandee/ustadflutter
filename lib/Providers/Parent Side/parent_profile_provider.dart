import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Models/Parent%20Side/child_detail_model.dart';
import 'package:flutterustad/Models/Parent%20Side/child_note_model.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/config/keys/urls.dart';

class ParentProfileProvider with ChangeNotifier {
  List<Child> _children = [];
  Child? _selectedChild;
  List<ChildNote> _childNotes = [];
  bool _isLoading = false;
  Map<String, dynamic>? profileData;
  bool _notesLoader = false;
  bool _parentProfileLoader = false;
  bool _getProfileLoader = false;

  final AppDio _dio;

  ParentProfileProvider(BuildContext context) : _dio = AppDio(context);

  List<Child> get children => _children;
  Child? get selectedChild => _selectedChild;
  List<ChildNote> get childNotes => _childNotes;
  bool get isLoading => _isLoading;
  bool get notesLoader => _notesLoader;
  bool get parentProfileLoader => _parentProfileLoader;
  bool get getProfileLoader => _getProfileLoader;
  String parentImage = '';
  String tasks = "0";
  bool isVerified = false;
  String profileBalance = "0";
  String bankName = "";
  String accountNumber = "";
  String fName = '';
  String lName = '';
  String averageRating = '';
  String totalReviews = '';
  String unReadMessages = "";
  bool isTutorSide = false;
  List ratingData = [];
  List<dynamic> parentTranferredHistory = [];

  Future<void> fetchChildren(context) async {
    if (children.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await _dio.get(path: AppUrls.getChildren);
      var responseData = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"] as List;
        _children = data.map((json) => Child.fromJson(json)).toList();

        if (_children.isNotEmpty) {
          _selectedChild = _children.first;
        }
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(context: context, msg: message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChildNotes(context) async {
    if (_selectedChild == null) return;

    _notesLoader = true;
    _childNotes = [];
    notifyListeners();

    try {
      final response = await _dio.get(
        path:
            "${AppUrls.getChildrenNotes}/${(selectedChild!.firstName).toLowerCase()} ${(selectedChild!.lastname).toLowerCase()}",
      );
      var responseData = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"] as List;
        _childNotes = data.map((json) => ChildNote.fromJson(json)).toList();
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      debugPrint("Error fetching child notes: $e");
    } finally {
      _notesLoader = false;
      notifyListeners();
    }
  }

  Future<void> getPaymentRequests(context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(path: AppUrls.getParentPaymentRequests);

      if (response.statusCode == 200) {
        final data = response.data["data"];
        parentTranferredHistory = data;
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBankDetails(
    context,
    String newBankName,
    String newAccountNumber,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {"bankName": newBankName, "accountNumber": newAccountNumber};

      final response = await _dio.patch(
        path: AppUrls.parentUpdateBank,
        data: body,
      );

      if (response.statusCode == 200) {
        bankName = newBankName;
        accountNumber = newAccountNumber;

        notifyListeners();
        return true;
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ??
              "Failed to update bank details",
        );
        return false;
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectChild(Child child) {
    _selectedChild = child;

    if (!isTutorSide) {
      // 👈 Tutor side ho to notes wali api skip
      fetchChildNotes(navigatorKey.currentContext!);
    }

    notifyListeners();
  }

  Future<void> addChild({
    required String firstName,
    required String lastName,
    required String grade,
    required String age,
    required String schoolName,
    required String gender,
    required String curriculum,
    XFile? imageFile,
    context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        "firstName": firstName,
        "lastName": lastName,
        "grade": grade,
        "age": age,
        "schoolName": schoolName,
        "curriculum": curriculum,
        "gender": gender,
        "image": imageFile != null
            ? "data:image/jpeg;base64,${base64Encode(File(imageFile.path).readAsBytesSync())}"
            : "",
      };

      final response = await _dio.post(path: AppUrls.addChild, data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newChild = Child.fromJson(response.data['data']);
        _children.add(newChild);
        _selectedChild = newChild;
        notifyListeners();
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      debugPrint("Error adding child: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateChild({
    required String id,
    required String firstName,
    required String lastName,
    required String grade,
    required String age,
    required String schoolName,
    required String gender,
    required String curriculum,
    XFile? imageFile,
    String? base64Image,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "grade": grade,
        "age": age,
        "schoolName": schoolName,
        "curriculum": curriculum,
        "gender": gender,
      };
      if (imageFile != null) {
        body["image"] =
            "data:image/jpeg;base64,${base64Encode(File(imageFile.path).readAsBytesSync())}";
      }
      // ✅ OLD IMAGE (BASE64)
      else if (base64Image != null && base64Image.isNotEmpty) {
        body["image"] = base64Image;
      }

      final response = await _dio.put(path: AppUrls.editChild, data: body);

      final updatedChild = Child.fromJson(response.data['data']);

      final index = _children.indexWhere((c) => c.id == id);
      if (index != -1) {
        _children[index] = updatedChild;
        _selectedChild = updatedChild;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating child: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteChild(String id, context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.delete(path: "${AppUrls.delChild}/$id");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _children.removeWhere((c) => c.id == id);
        if (_children.isNotEmpty) {
          _selectedChild = _children.first;
        } else {
          _selectedChild = null;
        }
        AppToast.success(context: context, msg: "Child Deleted successfully");
        notifyListeners();
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      debugPrint("Error deleting child: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchParentProfileFromTutorSide(context, parentId) async {
    _parentProfileLoader = true;
    notifyListeners();

    try {
      final response = await _dio.get(
        path: "${AppUrls.getParentFromtutor}/$parentId",
      );
      var responseData = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"]["children"] as List;
        _children = data.map((json) => Child.fromJson(json)).toList();
        parentImage = (response.data["data"]["image"] ?? "").toString();
        isVerified = response.data["data"]["isAdminVerified"];
        fName = response.data["data"]["firstName"];
        lName = response.data["data"]["lastName"];
        totalReviews = (response.data["data"]["reviewStats"]["totalReviews"])
            .toString();
        averageRating = (response.data["data"]["reviewStats"]["averageRating"])
            .toString();

        ratingData = response.data["data"]["reviews"] as List;

        if (_children.isNotEmpty) {
          _selectedChild = _children.first;
        }
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      }
    } catch (e) {
      debugPrint("Error fetching children: $e");
    } finally {
      _parentProfileLoader = false;
      notifyListeners();
    }
  }

  Future<void> getParentProfile(context) async {
    _getProfileLoader = true;
    notifyListeners();

    try {
      final response = await _dio.get(path: AppUrls.getParentProfile);
      if (response.statusCode == 200) {
        final data = response.data["data"];
        isVerified = data["user"]["isAdminVerified"];
        profileData = data;
        tasks = data["totalSessions"]?.toString() ?? "0";
        unReadMessages = data["unreadMessageCount"]?.toString() ?? "0";
        profileBalance = (data["user"]["Parent"]["balance"] ?? '0').toString();
        bankName = data["user"]["Parent"]["bankName"] ?? "";
        accountNumber = data["user"]["Parent"]["accountNumber"] ?? "";
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(PrefKey.notiCount, unReadMessages);
        globalNotiCount = unReadMessages;
      } else if (response.statusCode == 401) {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(context: context, msg: message);
    } finally {
      _getProfileLoader = false;
      notifyListeners();
    }
  }

  void clear() {
    _children.clear();
    _selectedChild = null;
    _childNotes.clear();

    _isLoading = false;
    _notesLoader = false;
    _parentProfileLoader = false;
    _getProfileLoader = false;

    profileData = null;
    parentImage = '';
    tasks = "0";
    isVerified = false;
    fName = '';
    lName = '';
    averageRating = '';
    totalReviews = '';
    unReadMessages = '';
    ratingData.clear();

    notifyListeners();
  }
}
