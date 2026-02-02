import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustaad/Custom widgets/app_button.dart';
import 'package:ustaad/Custom widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Authentication/SignUP/google_signup_detail.dart';
import 'package:ustaad/Screens/Authentication/SignUP/sign_up_screen.dart';
import 'package:ustaad/Screens/Authentication/google_signin.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/Screens/Authentication/Forgot Pass/forgot_pass.dart';
import 'package:ustaad/Screens/Authentication/otp.dart';
import 'package:ustaad/Screens/BottomNavBar/bottom_bar.dart';
import 'package:ustaad/Screens/Parents Screens/Parents OnBoard/parents_onboard.dart';
import 'package:ustaad/Screens/Teacher Screens/0nBoard Screens/tutor_on_board.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/pref_keys.dart';
import 'package:ustaad/config/keys/urls.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool _isGoogleLoading = false;

  late AppDio dio;
  late GoogleSignInService _googleSignInService;
  final AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    getDeviceToken();
    isTokenRefresh();
    _googleSignInService = GoogleSignInService.instance;
    _googleSignInService.init();
    logger.init();
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("fcm_token", token);
        return token;
      }
    } catch (e) {
      print("Error getting device token: $e");
    }
    return "";
  }

  void isTokenRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      prefs.setString("fcm_token", event);
      if (kDebugMode) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            authHeader(
              context: context,
              isSignInScreen: true,
              onEmailTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                );
              },
              onGoogleTap: () async {
                setState(() => _isGoogleLoading = true);
                final userData = await _googleSignInService.signIn(context);
                if (userData != null) {
                  push(
                      context,
                      GoogleSignupDetail(
                        userData: userData,
                      ));
                }
                if (mounted) {
                  setState(() => _isGoogleLoading = false);
                }
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
              child: Column(
                children: [
                  customLableField(
                    lable: "Email",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  customLableField(
                    lable: "Password",
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Row(
                      //   children: [
                      //     Checkbox(value: false, onChanged: (_) {}),
                      //     AppText.appText(
                      //       "Remember me",
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w400,
                      //       textColor: AppTheme.grey,
                      //     ),
                      //   ],
                      // ),
                      GestureDetector(
                        onTap: () => push(
                            context,
                            ForgotPassScreen(
                              isEditing: false,
                            )),
                        child: AppText.appText(
                          "Forgot Password?",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          textColor: AppTheme.appColor,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: isLoading
                        ? GifLoader()
                        : AppButton.appButton(
                            "Sign In",
                            context: context,
                            onTap: () => _emailSignIn(context),
                            border: false,
                            backgroundColor: AppTheme.primaryCOlor,
                          ),
                  ),
                  loginDivider("Or login with"),
                  const SizedBox(height: 30),
                  _isGoogleLoading
                      ? const GifLoader()
                      : AppButton.appButton(
                          "Google",
                          context: context,
                          onTap: () async {
                            setState(() => _isGoogleLoading = true);
                            final userData =
                                await _googleSignInService.signIn(context);
                            if (userData != null) {
                              await _googleSignIn(context, userData);
                            }
                            if (mounted) {
                              setState(() => _isGoogleLoading = false);
                            }
                          },
                          fontWeight: FontWeight.w600,
                          textColor: AppTheme.lableText,
                          borderColor: AppTheme.borderCOlor,
                          backgroundColor: AppTheme.white,
                          image: "assets/images/google.png",
                        ),
                  const SizedBox(height: 40),
                  loginFooter(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _emailSignIn(context) async {
    setState(() => isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailPattern.hasMatch(email)) {
      AppToast.error(
          context: context, msg: "Please enter a valid email address.");
      setState(() => isLoading = false);
      return;
    }
    if (password.isEmpty) {
      AppToast.error(context: context, msg: "Please enter password");
      setState(() => isLoading = false);
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final fcm_tokenGEt = prefs.getString('fcm_token');

      final response = await dio.post(
        path: AppUrls.logIn,
        data: {"email": email, "password": password},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "deviceId":
                fcm_tokenGEt ?? "", // Use FCM token instead of device-id
          },
        ),
      );

      if (response.statusCode == 200) {
        await _handleLoginSuccess(context, response.data);
      } else {
        (context, "Something went wrong");

        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
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
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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

  Future<void> _googleSignIn(context, Map<String, dynamic> userData) async {
    try {
      final role = await _selectUserRole(context);
      final name = splitName(userData["displayName"] ?? "");

      if (role == null) return;

      final response = await dio.post(
        path: AppUrls.googleSignIn,
        data: {
          "email": userData["email"],
          "googleId": userData["id"],
          "firstName": name["firstName"],
          "lastName": name["lastName"],
          "image": userData["photoUrl"] ?? "",
          "accessToken": userData["idToken"] ?? "",
          "role": role.toUpperCase(),
        },
      );

      if (response.statusCode == 200) {
        await _handleLoginSuccess(context, response.data);
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      AppToast.error(
        context: context,
        msg: "Something went wrong. Please try again.",
      );
    }
  }

  Future<String?> _selectUserRole(BuildContext context) {
    String? selectedRole;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.only(top: 20),
              title: Center(
                child: Text(
                  "Select Your Role",
                  style: TextStyle(
                    color: AppTheme.appColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoleCard(
                          context,
                          label: "Parent",
                          selected: selectedRole == "Parent",
                          onSelect: () =>
                              setState(() => selectedRole = "Parent"),
                        ),
                        _buildRoleCard(
                          context,
                          label: "Tutor",
                          selected: selectedRole == "Tutor",
                          onSelect: () =>
                              setState(() => selectedRole = "Tutor"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedRole != null
                                ? () => Navigator.pop(context, selectedRole)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.appColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Continue",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Reusable role card widget
  Widget _buildRoleCard(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        width: ScreenSize(context).width * 0.3,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.appColor : AppTheme.borderCOlor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: label,
              groupValue: selected ? label : null,
              activeColor: AppTheme.appColor,
              onChanged: (_) => onSelect(),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? AppTheme.appColor : AppTheme.lighttxtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLoginSuccess(
      context, Map<String, dynamic> responseData) async {
    final data = responseData["data"];
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(PrefKey.authorization, data["token"] ?? '');
    await prefs.setString(PrefKey.id, data["id"]);
    await prefs.setString(PrefKey.userRole, data["role"]);
    await prefs.setString(PrefKey.userFirstName, data["firstName"]);
    await prefs.setString(PrefKey.userLastName, data["lastName"]);
    await prefs.setString(PrefKey.userPic, data["image"] ?? '');
    await prefs.setString(PrefKey.onBoard, data["isOnBoard"] ?? '');

    globalUserId = data["id"];
    globalUserFirstName = data["firstName"];
    globalUserLastName = data["lastName"];
    globalUserRole = data["role"];
    globalToken = data["token"];
    globalUserPic = data["image"] ?? '';
    globalUserOnBoardStatus = data["isOnBoard"] ?? '';

    if (data["isEmailVerified"] == false && data["isPhoneVerified"] == false) {
      push(
        context,
        OtpScreen(
          mode: OtpMode.both,
          userId: "${data["id"]}",
          email: data["email"],
          phone: "${data["phone"]}",
          fromEditProfile: false,
        ),
      );
    } else if (data["isEmailVerified"] == false) {
      push(
        context,
        OtpScreen(
          mode: OtpMode.email,
          userId: "${data["id"]}",
          fromEditProfile: false,
          email: data["email"],
        ),
      );
    }
    // else if (data["isPhoneVerified"] == false) {
    //   push(
    //     context,
    //     OtpScreen(
    //       mode: OtpMode.phone,
    //       userId: "${data["id"]}",
    //       fromEditProfile: false,
    //       phone: "${data["phone"]}",
    //     ),
    //   );
    // }
    else if (data["isOnBoard"] == "required" && data["role"] == "TUTOR") {
      push(context, TutorOnboardScreen());
    } else if (data["isOnBoard"] == "required" && data["role"] == "PARENT") {
      pushReplacement(context, ParentsOnboardScreen());
    } else if (data["role"] == "TUTOR") {
      pushReplacement(context, BottomNavView(tutor: true));
    } else if (data["role"] == "PARENT") {
      pushReplacement(context, BottomNavView(tutor: false));
    }
  }
}
