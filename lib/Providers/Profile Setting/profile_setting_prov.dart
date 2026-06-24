import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/urls.dart';

class TutorEditProfileProvider extends ChangeNotifier {
  final AppDio dio;
  bool isLoading = false;
  bool picLoading = false;
  bool hasData = false;
  String fName = '';
  String lName = '';
  String email = '';
  String phone = '';
  String password = '';
  String image = '';
  bool isEmailEdit = false;
  bool isPhoneEdit = false;
  bool isPasswordEdit = false;

  TutorEditProfileProvider(BuildContext context) : dio = AppDio(context);
  void toggleEmailEdit() {
    isEmailEdit = !isEmailEdit;
    notifyListeners();
  }

  void resetEditStates() {
    isEmailEdit = false;
    isPhoneEdit = false;
    isPasswordEdit = false;
    notifyListeners();
  }

  void cancelEmailEdit(TextEditingController controller) {
    controller.text = email;
    isEmailEdit = false;
    notifyListeners();
  }

  void togglePhoneEdit() {
    isPhoneEdit = !isPhoneEdit;
    notifyListeners();
  }

  void cancelPhoneEdit(TextEditingController controller) {
    controller.text = phone;
    isPhoneEdit = false;
    notifyListeners();
  }

  void togglePasswordEdit() {
    isPasswordEdit = !isPasswordEdit;

    notifyListeners();
  }

  void updateEmailAndPhone({String? newEmail, String? newPhone}) {
    if (newEmail != null) email = newEmail;
    if (newPhone != null) phone = newPhone;
    notifyListeners();
  }

  Future<bool> updatePhoneNumber(BuildContext context, String newPhone) async {
    try {
      final response = await dio.post(
        path: globalUserRole == "TUTOR"
            ? AppUrls.editTutorProfile
            : AppUrls.editParentProfile,
        data: {"phone": newPhone},
      );
      if (!context.mounted) return false;

      if (response.statusCode == 200) {
        phone = '+$newPhone';
        notifyListeners();
        return true;
      }

      AppToast.error(
        context: context,
        msg:
            response.data["errors"]?[0]?["message"] ??
            "Failed to update mobile number",
      );
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context: context, msg: "Something went wrong: $e");
      }
    }

    return false;
  }

  void cancelPasswordEdit(TextEditingController controller) {
    controller.text = phone;
    isPasswordEdit = false;
    notifyListeners();
  }

  Future<void> getTutorProfile(context, {bool refresh = false}) async {
    if (!hasData || refresh) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final response = await dio.get(path: AppUrls.getTutorProfile);

      if (response.statusCode == 200) {
        final data = response.data["data"];
        fName = data["user"]["firstName"] ?? '';
        lName = data["user"]["lastName"] ?? '';
        email = data["user"]["email"] ?? '';
        phone = "+${data["user"]["phone"]}";
        password = "********";
        image = data["user"]["image"] ?? '';
        hasData = true;
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Something went wrong: $e");
      }
      // AppToast.error(
      //   context: context,
      //   msg: "Something went wrong: $e",
      // );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTutorProfileImage(context, XFile? imageFile) async {
    picLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        "image": imageFile != null
            ? "data:image/jpeg;base64,${base64Encode(File(imageFile.path).readAsBytesSync())}"
            : "",
      };

      final response = await dio.post(
        path: AppUrls.editTutorProfile,
        data: body,
      );

      if (response.statusCode == 200) {
        image = response.data["data"]["image"] ?? image;
        AppToast.success(
          context: context,
          msg: "Profile image updated successfully",
        );
        globalUserPic = image;
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString(PrefKey.userPic, image);
        getPrefData();
        picLoading = false;
        notifyListeners();
      } else {
        picLoading = false;
        notifyListeners();
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ??
              "Failed to update image",
        );
      }
    } catch (e) {
      picLoading = false;
      notifyListeners();
      AppToast.error(context: context, msg: "Something went wrong: $e");
    } finally {
      picLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePicture(context) async {
    picLoading = true;
    notifyListeners();

    try {
      final response = await dio.delete(path: AppUrls.deletePic);

      if (response.statusCode == 200) {
        image = '';
        globalUserPic = '';
        AppToast.success(
          context: context,
          msg: "Profile image Deleted successfully",
        );
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString(PrefKey.userPic, image);
        getPrefData();
        picLoading = false;
        notifyListeners();
        return true;
      } else {
        picLoading = false;
        notifyListeners();
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ??
              "Failed to update image",
        );
        return false;
      }
    } catch (e) {
      picLoading = false;
      notifyListeners();
      AppToast.error(context: context, msg: "Something went wrong: $e");
      return false;
    } finally {
      picLoading = false;
      notifyListeners();
    }
  }

  ///////////////////////////////////////////  PArent Side ////////////////////////////////////////////

  Future<void> getParentProfile(context, {bool refresh = false}) async {
    if (!hasData || refresh) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final response = await dio.get(path: AppUrls.getParentProfile);

      if (response.statusCode == 200) {
        final data = response.data["data"]["user"];
        fName = data["firstName"] ?? '';
        lName = data["lastName"] ?? '';
        email = data["email"] ?? '';
        phone = "+${data["phone"]}";
        password = "********";
        image = data["image"] ?? '';

        hasData = true;
      } else {
        if (kDebugMode) {
          print(
            "Something went wrong: ${response.data["errors"]?[0]?["message"]}",
          );
        }
        // AppToast.error(
        //   context: context,
        //   msg:
        //       response.data["errors"]?[0]?["message"] ?? "Something went wrong",
        // );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Something went wrong: $e");
      }
      // AppToast.error(
      //   context: context,
      //   msg: "Something went wrong: $e",
      // );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateParentProfileImage(context, XFile? imageFile) async {
    picLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        "image": imageFile != null
            ? "data:image/jpeg;base64,${base64Encode(File(imageFile.path).readAsBytesSync())}"
            : "",
      };

      final response = await dio.post(
        path: AppUrls.editParentProfile,
        data: body,
      );

      if (response.statusCode == 200) {
        image = response.data["data"]["image"] ?? image;
        AppToast.success(
          context: context,
          msg: "Profile image updated successfully",
        );
        globalUserPic = image;
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString(PrefKey.userPic, image);
        getPrefData();
        picLoading = false;
        notifyListeners();
      } else {
        picLoading = false;
        notifyListeners();
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ??
              "Failed to update image",
        );
      }
    } catch (e) {
      picLoading = false;
      notifyListeners();
      AppToast.error(context: context, msg: "Something went wrong: $e");
    } finally {
      picLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    isLoading = false;
    picLoading = false;
    hasData = false;

    fName = '';
    lName = '';
    email = '';
    phone = '';
    password = '';
    image = '';

    isEmailEdit = false;
    isPhoneEdit = false;
    isPasswordEdit = false;

    notifyListeners();
  }

  Future<bool> deleteAccount(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await dio.delete(path: AppUrls.deleteAccount);
      if (!context.mounted) return false;

      if (response.statusCode == 200) {
        AppToast.success(
          context: context,
          msg: "Your account has been deleted successfully.",
        );

        /// 🔥 Only call logout handler
        handleLogOut(context);

        return true;
      } else {
        AppToast.error(
          context: context,
          msg:
              response.data["errors"]?[0]?["message"] ??
              "Failed to delete account",
        );
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context: context, msg: "Something went wrong: $e");
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
