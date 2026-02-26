import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:flutterustad/Screens/Authentication/SignUP/sign_up_screen.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/urls.dart';

class OtpVerificationScreen extends StatefulWidget {
  final SignupData signupData;

  const OtpVerificationScreen({super.key, required this.signupData});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late AppDio dio;
  final AppLogger logger = AppLogger();

  late Timer emailTimer;
  late Timer smsTimer;

  int emailSeconds = 120;
  int smsSeconds = 120;
  bool emailResendEnabled = false;
  bool smsResendEnabled = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();

    startEmailTimer();
    startSmsTimer();
    getOtp(context);
  }

  @override
  void dispose() {
    emailTimer.cancel();
    smsTimer.cancel();
    super.dispose();
  }

  void startEmailTimer() {
    emailResendEnabled = false;
    emailSeconds = 120;
    emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (emailSeconds == 0) {
        setState(() => emailResendEnabled = true);
        timer.cancel();
      } else {
        setState(() => emailSeconds--);
      }
    });
  }

  void startSmsTimer() {
    smsResendEnabled = false;
    smsSeconds = 120;
    smsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (smsSeconds == 0) {
        setState(() => smsResendEnabled = true);
        timer.cancel();
      } else {
        setState(() => smsSeconds--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _emailOtpWidget(),
            const SizedBox(height: 40),
            _phoneOtpWidget(),
            const SizedBox(height: 40),
            _otpActions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _emailOtpWidget() {
    return Column(
      children: [
        const Image(
          image: AssetImage("assets/images/otpEmail.png"),
          height: 48,
        ),
        const SizedBox(height: 20),
        AppText.appText(
          "Please check your Email",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
        ),
        AppText.appText(
          "We've sent a code to ${widget.signupData.emailController.text}",
          textAlign: TextAlign.center,
          fontSize: 16,
          textColor: AppTheme.lighttxtColor,
        ),
        const SizedBox(height: 20),
        _otpField(widget.signupData.emailOtpController),
        const SizedBox(height: 10),
        _resendWidget(emailResendEnabled, emailSeconds, () {
          getOtp(context);
          startEmailTimer();
        }),
      ],
    );
  }

  Widget _phoneOtpWidget() {
    return Column(
      children: [
        const Image(
          image: AssetImage("assets/images/otpPhone.png"),
          height: 48,
        ),
        const SizedBox(height: 20),
        AppText.appText(
          "Please check your SMS",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
        ),
        AppText.appText(
          "We've sent a code to +${widget.signupData.phoneController.text}",
          fontSize: 16,
          textColor: AppTheme.lighttxtColor,
        ),
        const SizedBox(height: 20),
        _otpField(widget.signupData.phoneOtpController),
        const SizedBox(height: 10),
        _resendWidget(smsResendEnabled, smsSeconds, () {
          // Implement SMS resend functionality
          startSmsTimer();
        }),
      ],
    );
  }

  Widget _otpField(TextEditingController controller) {
    return PinCodeTextField(
      appContext: context,
      length: 4,
      controller: controller,
      keyboardType: TextInputType.number,
      enableActiveFill: true,
      onChanged: (_) {},
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 70,
        activeFillColor: const Color(0xffECEEF3),
        inactiveFillColor: const Color(0xffECEEF3),
        selectedFillColor: const Color(0xffECEEF3),
        activeColor: Colors.teal,
        selectedColor: Colors.teal,
        inactiveColor: Colors.grey,
      ),
    );
  }

  Widget _resendWidget(bool enabled, int seconds, VoidCallback onResend) {
    return Row(
      children: [
        const Text("Didn't get a code?", style: TextStyle(fontSize: 14)),
        enabled
            ? GestureDetector(
                onTap: onResend,
                child: const Text(
                  " Resend",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                " Resend in ${seconds}s",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
      ],
    );
  }

  Widget _otpActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton.appButton(
          "Cancel",
          context: context,
          onTap: () => Navigator.pop(context),
          width: ScreenSize(context).width * 0.4,
          backgroundColor: AppTheme.button2ndCOlor,
          textColor: AppTheme.black,
        ),
        AppButton.appButton(
          "Verify",
          context: context,
          width: ScreenSize(context).width * 0.4,
          backgroundColor: AppTheme.primaryCOlor,
          onTap: _verifyOtpHandler,
        ),
      ],
    );
  }

  void _verifyOtpHandler() {
    if (widget.signupData.emailOtpController.text.isEmpty ||
        widget.signupData.emailOtpController.text.length < 4) {
      AppToast.error(context: context, msg: "Please enter valid Email OTP");
    } else {
      // if (widget.signupData.phoneOtpController.text.isEmpty ||
      //     widget.signupData.phoneOtpController.text.length < 4) {
      //   AppToast.error(
      //       context: context, msg: "Please enter valid Phone OTP");
      // } else {
      verifyOtp(context);
      // }
    }
  }

  Future<void> getOtp(context) async {
    setState(() => isLoading = true);

    final params = {
      "userId": "${widget.signupData.finalData["id"]}",
      "type": "email",
      "purpose": "email_verification",
    };

    try {
      final response = await dio.post(path: AppUrls.otp, data: params);
      final responseData = response.data;

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "${responseData["message"]}");
        setState(() => isLoading = false);
      } else {
        _handleError(responseData["message"]);
      }
    } catch (e) {
      _handleError("Something went wrong $e");
    }
  }

  Future<void> verifyOtp(context) async {
    setState(() => isLoading = true);

    final params = {
      "userId": "${widget.signupData.finalData["id"]}",
      "otp": widget.signupData.emailOtpController.text,
      "type": "email",
      "purpose": "email_verification",
    };

    try {
      final response = await dio.post(path: AppUrls.verifyOtp, data: params);
      final responseData = response.data;

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "${responseData["message"]}");
        pushUntil(context, LogInScreen());
      } else {
        _handleError(responseData["errors"][0]["message"]);
      }
    } catch (e) {
      _handleError("Something went wrong $e");
    }
  }

  void _handleError(String message) {
    setState(() => isLoading = false);
    AppToast.error(context: context, msg: message);
  }
}
