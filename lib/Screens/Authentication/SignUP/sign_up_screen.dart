import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:flutterustad/Screens/Authentication/SignUP/additional_detail.dart';
import 'package:flutterustad/Screens/Authentication/SignUP/signup_otp.dart';
import 'package:flutterustad/Screens/Authentication/SignUP/stepper.dart';
import 'package:flutterustad/Screens/Authentication/SignUP/user_detail_form.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/config/keys/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  late SignupData signupData;
  late AppDio dio;
  final AppLogger logger = AppLogger();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    signupData = SignupData();
    dio = AppDio(context);
    logger.init();
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Staticdata.isActive || tabController.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            authHeader(context: context, isSignInScreen: false),
            if (!Staticdata.isActive)
              SignupStepper(tabController: tabController),
            Expanded(
              child: Staticdata.isActive
                  ? UserDetailsForm(
                      tabController: tabController,
                      signupData: signupData,
                      isLoading: isLoading,
                      onActiveSignup: _activeSignup,
                    )
                  : TabBarView(
                      controller: tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        UserDetailsForm(
                          tabController: tabController,
                          signupData: signupData,
                        ),
                        AdditionalDetailsForm(
                          tabController: tabController,
                          signupData: signupData,
                        ),
                        OtpVerificationScreen(
                          signupData: signupData,
                          onCancel: _goToPreviousStep,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousStep() {
    if (tabController.index == 0) return;
    tabController.animateTo(tabController.index - 1);
  }

  Future<void> _activeSignup() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final params = {
      "role": signupData.selectedRole.toUpperCase(),
      "firstName": signupData.fNameController.text.trim(),
      "lastName": signupData.lNameController.text.trim(),
      "password": signupData.passwordController.text,
      "cnic": signupData.cnicController.text,
      "address": signupData.addressController.text,
      "city": signupData.cityController.text,
      "state": signupData.stateController.text,
      "country": signupData.selectedCountry,
      "gender": signupData.selectedGender.toLowerCase(),
      "email": signupData.emailController.text
          .trim()
          .replaceAll(' ', '')
          .toLowerCase(),
      "phone": signupData.phoneController.text,
    };

    try {
      final response = await dio.post(path: AppUrls.signUp, data: params);
      final responseData = response.data;

      if (response.statusCode == 200) {
        await _handleActiveSignupSuccess(responseData);
      } else {
        _handleError(responseData["errors"]?[0]?["message"] ?? "Signup failed");
      }
    } catch (e) {
      _handleError(_errorMessage(e));
    }
  }

  Future<void> _handleActiveSignupSuccess(dynamic data) async {
    signupData.finalData = data["data"];
    await _saveSignupSession();
    await _sendActiveOtp();
    await _verifyActiveOtp();
  }

  Future<void> _saveSignupSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefKey.authorization, signupData.finalData["token"] ?? '');
    prefs.setString(PrefKey.id, signupData.finalData["id"]);
    prefs.setString(PrefKey.userRole, signupData.finalData["role"]);
    prefs.setString(PrefKey.userFirstName, signupData.finalData["firstName"]);
    prefs.setString(PrefKey.userLastName, signupData.finalData["lastName"]);
    prefs.setString(PrefKey.userPic, signupData.finalData["profilePic"] ?? '');
    prefs.setString(PrefKey.onBoard, signupData.finalData["isOnBoard"] ?? '');
    signupData.userRole = signupData.finalData["role"];
  }

  Future<void> _sendActiveOtp() async {
    final params = {
      "userId": "${signupData.finalData["id"]}",
      "type": "email",
      "purpose": "email_verification",
    };

    await dio.post(path: AppUrls.otp, data: params);
  }

  Future<void> _verifyActiveOtp() async {
    final params = {
      "userId": "${signupData.finalData["id"]}",
      "otp": signupData.emailOtpController.text,
      "type": "email",
      "purpose": "email_verification",
    };

    try {
      final response = await dio.post(path: AppUrls.verifyOtp, data: params);
      final responseData = response.data;

      if (response.statusCode == 200) {
        if (!mounted) return;
        AppToast.success(context: context, msg: "${responseData["message"]}");
        pushUntil(context, LogInScreen());
      } else {
        _handleError(
          responseData["errors"]?[0]?["message"] ?? "OTP verification failed",
        );
      }
    } catch (e) {
      _handleError(_errorMessage(e));
    }
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      return e.error?.toString() ?? "Check Internet Connection";
    }
    return e.toString();
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() => isLoading = false);
    AppToast.error(context: context, msg: message);
  }
}

// Data model to pass between screens
class SignupData {
  String selectedRole = "Tutor";
  String selectedCountry = "Pakistan";
  String? userRole;
  dynamic finalData;
  String selectedGender = "Male";

  // Controllers
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController emailOtpController = TextEditingController();
}
