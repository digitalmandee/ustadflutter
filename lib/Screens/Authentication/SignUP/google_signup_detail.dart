import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/otp.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/Screens/Authentication/widgets/country_picker.dart';
import 'package:flutterustad/Screens/BottomNavBar/bottom_bar.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parents%20OnBoard/parents_onboard.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/tutor_on_board.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/config/keys/urls.dart';

class GoogleSignupDetail extends StatefulWidget {
  final Map<String, dynamic> userData;
  const GoogleSignupDetail({super.key, required this.userData});

  @override
  State<GoogleSignupDetail> createState() => _GoogleSignupDetailState();
}

class _GoogleSignupDetailState extends State<GoogleSignupDetail> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedRole = "Tutor";
  String selectedCountry = "Pakistan";
  String selectedGender = "Male";
  final List<String> genderList = ["Male", "Female"];

  bool isLoading = false;

  late AppDio dio;
  final AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          authHeader(context: context, isSignInScreen: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.appText(
                      "Sign Up As:",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: AppTheme.lableText,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRoleOption("Tutor"),
                        const SizedBox(width: 20),
                        _buildRoleOption("Parent"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppText.appText(
                      "Gender",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: AppTheme.lableText,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderOption("Male"),
                        const SizedBox(width: 20),
                        _buildGenderOption("Female"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    customLableField(
                      lable: "Address",
                      controller: addressController,
                    ),
                    const SizedBox(height: 20),
                    customLableField(lable: "City", controller: cityController),
                    const SizedBox(height: 20),
                    CountryPickerField(
                      onCountrySelected: (country) => selectedCountry = country,
                    ),
                    const SizedBox(height: 20),
                    _phoneInput(),
                    const SizedBox(height: 20),
                    AppButton.appButton(
                      "Sign Up",
                      onTap: _validateAdditionalDetails,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText(
          "Phone Number",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          textColor: AppTheme.lableText,
        ),
        const SizedBox(height: 10),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffD4D8E2)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: PhoneFormField(
            initialValue: PhoneNumber.parse('+92'),
            countrySelectorNavigator:
                const CountrySelectorNavigator.draggableBottomSheet(),
            autovalidateMode: AutovalidateMode.disabled,
            onChanged: (phoneNumber) {
              phoneController.text =
                  "${phoneNumber.countryCode}${phoneNumber.nsn}";
            },
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        height: 36,
        width: MediaQuery.of(context).size.width * 0.41,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedGender == gender
                ? AppTheme.appColor
                : const Color(0xffD4D8E2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: selectedGender,
              activeColor: AppTheme.appColor,
              onChanged: (value) => setState(() => selectedGender = value!),
            ),
            AppText.appText(gender, fontSize: 14, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }

  void _validateAdditionalDetails() {
    final phone = phoneController.text.trim();

    if (addressController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter Address");
    } else if (cityController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter City");
    } else if (phone.isEmpty || phone.length != 12) {
      AppToast.error(
        context: context,
        msg: "Please enter a valid phone number.",
      );
    } else {
      _googleSignUp(context);
    }
  }

  Widget _buildRoleOption(String role) {
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        height: 36,
        width: MediaQuery.of(context).size.width * 0.41,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.appColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: role,
              groupValue: selectedRole,
              activeColor: AppTheme.appColor,
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
            AppText.appText(role, fontSize: 14, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }

  Map<String, String> splitName(String displayName) {
    if (displayName.trim().isEmpty) {
      return {"firstName": "", "lastName": ""};
    }

    List<String> parts = displayName.trim().split(RegExp(r'\s+'));

    String firstName = parts.first;
    String lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return {
      "firstName": capitalizeEachWord(firstName),
      "lastName": capitalizeEachWord(lastName),
    };
  }

  Future<void> _googleSignUp(context) async {
    try {
      final name = splitName(widget.userData["displayName"] ?? "");
      final response = await dio.post(
        path: AppUrls.googleSignUp,
        data: {
          "email": (widget.userData["email"] ?? "")
              .toString()
              .trim()
              .toLowerCase(),
          "googleId": widget.userData["id"],
          "firstName": name["firstName"],
          "lastName": name["lastName"],
          "image": widget.userData["photoUrl"] ?? "",
          "accessToken": widget.userData["idToken"] ?? "",
          "role": selectedRole.toUpperCase(),
          "address": addressController.text,
          "city": cityController.text,
          "country": selectedCountry,
          "phone": phoneController.text.trim(),
          "gender": selectedGender.toLowerCase(),
        },
      );

      if (response.statusCode == 200) {
        await _handleLoginSuccess(context, response.data);
      } else {
        Navigator.pop(context);
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (_) {
      AppToast.error(
        context: context,
        msg: "Something went wrong. Please try again.",
      );
    }
  }

  Future<void> _handleLoginSuccess(
    context,
    Map<String, dynamic> responseData,
  ) async {
    final data = responseData["data"];
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(PrefKey.authorization, data["token"] ?? '');
    await prefs.setString(PrefKey.id, data["id"]);
    await prefs.setString(PrefKey.userRole, data["role"]);
    await prefs.setString(PrefKey.userFirstName, data["firstName"]);
    await prefs.setString(PrefKey.userLastName, data["lastName"]);
    await prefs.setString(PrefKey.userPic, data["image"] ?? '');
    await prefs.setString(PrefKey.onBoard, data["isOnBoard"] ?? '');
    await prefs.setString(PrefKey.isGoogleId, data["googleId"] ?? '');

    globalUserId = data["id"];
    globalUserFirstName = data["firstName"];
    globalUserLastName = data["lastName"];
    globalUserRole = data["role"];
    globalToken = data["token"];
    globalUserPic = data["image"] ?? '';
    globalUserOnBoardStatus = data["isOnBoard"] ?? '';
    globalGoogleId = data["googleId"] ?? "";

    if (data["isEmailVerified"] == false && data["isPhoneVerified"] == false) {
      push(
        context,
        OtpScreen(
          mode: OtpMode.both,
          userId: "${data["id"]}",
          email: data["email"].toString().trim().toLowerCase(),
          phone: "${data["phone"]}",
        ),
      );
    } else if (data["isOnBoard"] == "required" && data["role"] == "TUTOR") {
      pushReplacement(context, TutorOnboardScreen());
    } else if (data["isOnBoard"] == "required" && data["role"] == "PARENT") {
      pushReplacement(context, ParentsOnboardScreen());
    } else if (data["role"] == "TUTOR") {
      pushReplacement(context, BottomNavView(tutor: true));
    } else if (data["role"] == "PARENT") {
      pushReplacement(context, BottomNavView(tutor: false));
    }
  }
}
