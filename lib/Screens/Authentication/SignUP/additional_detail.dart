import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/SignUP/sign_up_screen.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/Screens/Authentication/widgets/country_picker.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/config/keys/urls.dart';

class AdditionalDetailsForm extends StatefulWidget {
  final TabController tabController;
  final SignupData signupData;

  const AdditionalDetailsForm({
    super.key,
    required this.tabController,
    required this.signupData,
  });

  @override
  State<AdditionalDetailsForm> createState() => _AdditionalDetailsFormState();
}

class _AdditionalDetailsFormState extends State<AdditionalDetailsForm> {
  late AppDio dio;
  final AppLogger logger = AppLogger();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            customLableField(
              lable: "CNIC",
              controller: widget.signupData.cnicController,
              textType: TextInputType.numberWithOptions(),
            ),
            const SizedBox(height: 20),
            customLableField(
              lable: "Address",
              controller: widget.signupData.addressController,
            ),
            const SizedBox(height: 20),
            customLableField(
              lable: "City",
              controller: widget.signupData.cityController,
            ),
            const SizedBox(height: 20),
            customLableField(
              lable: "State",
              controller: widget.signupData.stateController,
            ),
            const SizedBox(height: 20),
            CountryPickerField(
              onCountrySelected: (country) =>
                  widget.signupData.selectedCountry = country,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const GifLoader()
                : AppButton.appButton(
                    "Next",
                    onTap: _validateAdditionalDetails,
                    context: context,
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _validateAdditionalDetails() {
    if (widget.signupData.cnicController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter CNIC");
    } else if (widget.signupData.cnicController.text.trim().length != 13 ||
        !RegExp(
          r'^\d{13}$',
        ).hasMatch(widget.signupData.cnicController.text.trim())) {
      AppToast.error(context: context, msg: "CNIC must be exactly 13 digits.");
    } else if (widget.signupData.addressController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter Address");
    } else if (widget.signupData.cityController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter City");
    } else if (widget.signupData.stateController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter State");
    } else {
      signUp(context);
    }
  }

  Future<void> signUp(context) async {
    setState(() => isLoading = true);

    final params = {
      "role": widget.signupData.selectedRole.toUpperCase(),
      "firstName": widget.signupData.fNameController.text,
      "lastName": widget.signupData.lNameController.text,
      "password": widget.signupData.passwordController.text,
      "cnic": widget.signupData.cnicController.text,
      "address": widget.signupData.addressController.text,
      "city": widget.signupData.cityController.text,
      "state": widget.signupData.stateController.text,
      "country": widget.signupData.selectedCountry,
      "gender": widget.signupData.selectedGender.toLowerCase(),
      "email": widget.signupData.emailController.text
          .trim()
          .replaceAll(' ', '')
          .toLowerCase(),
      "phone": widget.signupData.phoneController.text,
    };

    try {
      final response = await dio.post(path: AppUrls.signUp, data: params);
      final responseData = response.data;

      if (response.statusCode == 200) {
        _handleSignupSuccess(context, responseData);
      } else {
        _handleError(responseData["errors"][0]["message"]);
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(context: context, msg: message);
    }
  }

  void _handleSignupSuccess(context, dynamic data) async {
    AppToast.success(context: context, msg: "${data["message"]}");
    widget.signupData.finalData = data["data"];

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      PrefKey.authorization,
      widget.signupData.finalData["token"] ?? '',
    );
    prefs.setString(PrefKey.id, widget.signupData.finalData["id"]);
    prefs.setString(PrefKey.userRole, widget.signupData.finalData["role"]);
    prefs.setString(
      PrefKey.userFirstName,
      widget.signupData.finalData["firstName"],
    );
    prefs.setString(
      PrefKey.userLastName,
      widget.signupData.finalData["lastName"],
    );
    prefs.setString(
      PrefKey.userPic,
      widget.signupData.finalData["profilePic"] ?? '',
    );
    prefs.setString(
      PrefKey.onBoard,
      widget.signupData.finalData["isOnBoard"] ?? '',
    );

    widget.signupData.userRole = widget.signupData.finalData["role"];
    setState(() => isLoading = false);

    widget.tabController.animateTo(2);
  }

  void _handleError(String message) {
    setState(() => isLoading = false);
    AppToast.error(context: context, msg: message);
  }
}
