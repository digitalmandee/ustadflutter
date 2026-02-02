import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:password_strength_indicator/password_strength_indicator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Authentication/widgets/widgets.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class ConfirmPassScreen extends StatefulWidget {
  final String? email;
  final String? userId;
  const ConfirmPassScreen({super.key, this.email, this.userId});

  @override
  State<ConfirmPassScreen> createState() => _ConfirmPassScreenState();
}

class _ConfirmPassScreenState extends State<ConfirmPassScreen> {
  final TextEditingController emailOtpController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  late Timer emailTimer;
  int emailSeconds = 120;

  String? email;
  String? userId;

  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  bool emailResendEnabled = false;

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    startEmailTimer();
  }

  void startEmailTimer() {
    emailResendEnabled = false;
    emailSeconds = 120;
    emailTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (emailSeconds == 0) {
        emailResendEnabled = true;
        timer.cancel();
        setState(() {});
      } else {
        emailSeconds--;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    emailTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [header(), Expanded(child: otpScreen())],
      ),
    );
  }

  Widget header() {
    return Container(
      width: ScreenSize(context).width,
      height: 220,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/images/Head.png",
              ),
              fit: BoxFit.fill)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/logo1.png', height: 50),
            const SizedBox(height: 30),
            AppText.appText("OTP Verification",
                fontSize: 32,
                fontWeight: FontWeight.w600,
                textColor: AppTheme.white),
          ],
        ),
      ),
    );
  }

  Widget otpScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            emailOtpFunction(),
            SizedBox(
              height: 40,
            ),
            customLableField(
                lable: "New Password",
                controller: _passController,
                isPassword: true),
            SizedBox(
              height: 10,
            ),
            PasswordStrengthIndicator(
              password: _passController.text,
              width: ScreenSize(context).width,
              thickness: 5,
              backgroundColor: Colors.grey,
              radius: 8,
              colors: StrengthColors(
                weak: Colors.orange,
                medium: Colors.yellow,
                strong: Colors.green,
              ),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              callback: (double strength) {},
              strengthBuilder: (String password) {
                return password.length / 10;
              },
              style: StrengthBarStyle.dashed,
            ),
            SizedBox(
              height: 10,
            ),
            passwordRequirements(),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton.appButton("Cancel", context: context, onTap: () {
                  Navigator.pop(context);
                },
                    width: ScreenSize(context).width * 0.4,
                    backgroundColor: AppTheme.button2ndCOlor,
                    textColor: AppTheme.black,
                    borderColor: Colors.transparent),
                AppButton.appButton(
                  "Verify",
                  context: context,
                  onTap: () {
                    if (emailOtpController.text.isEmpty ||
                        emailOtpController.text.length < 4) {
                      AppToast.error(
                          context: context,
                          msg: "Please enter valid Email OTP");
                    } else {
                      changePass(context);
                    }
                  },
                  width: ScreenSize(context).width * 0.4,
                  borderColor: Colors.transparent,
                  backgroundColor: AppTheme.primaryCOlor,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget emailOtpFunction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: AssetImage("assets/images/otpEmail.png"),
          height: 48,
        ),
        SizedBox(height: 20),
        AppText.appText(
          "Please check your email",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        AppText.appText(
          "We've sent a code to ${widget.email}",
          fontSize: 16,
          textColor: AppTheme.lighttxtColor,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 4,
          controller: emailOtpController,
          enableActiveFill: true,
          onChanged: (value) {},
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 70,
            activeFillColor: Color(0xffECEEF3),
            inactiveFillColor: Color(0xffECEEF3),
            selectedFillColor: Color(0xffECEEF3),
            activeColor: Colors.teal,
            selectedColor: Colors.teal,
            inactiveColor: Colors.grey,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Didn't get a code? ", style: TextStyle(fontSize: 14)),
            emailResendEnabled
                ? GestureDetector(
                    onTap: () {
                      forgotPass(context);
                      startEmailTimer(); // restart timer
                    },
                    child: Text(
                      "Resend",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    "Resend in ${emailSeconds}s",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
          ],
        ),
      ],
    );
  }

  void forgotPass(context) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> params = {
      "email": "${widget.email}",
    };
    try {
      Response response =
          await dio.post(path: AppUrls.forgotPass, data: params);
      var responseData = response.data;

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "${responseData["message"]}");

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
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
      setState(() {
        isLoading = false;
      });
    }
  }

  void changePass(context) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> params = {
      "userId": "${widget.userId}",
      "newPassword": _passController.text,
      "email": widget.email,
      "otp": emailOtpController.text,
      "type": "email",
      "purpose": "password_reset"
    };
    try {
      Response response =
          await dio.post(path: AppUrls.confirmPass, data: params);
      var responseData = response.data;

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "${responseData["message"]}");

        setState(() {
          isLoading = false;
        });
        pushUntil(context, LogInScreen());
      } else {
        setState(() {
          isLoading = false;
        });
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Something went wrong: $e");
      }
      AppToast.error(context: context, msg: "Something went wrong$e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
