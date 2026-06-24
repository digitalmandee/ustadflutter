import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/urls.dart';

enum OtpMode { email, phone }

class OtpScreen extends StatefulWidget {
  final String? userId;
  final String? email;
  final String? phone;
  final OtpMode mode;
  final bool fromEditProfile;

  const OtpScreen({
    super.key,
    this.userId,
    this.email,
    this.phone,
    this.mode = OtpMode.email,
    this.fromEditProfile = false, // default false for SignIn
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _emailOtpController = TextEditingController();

  late Timer _emailTimer;

  int _emailCountdown = 120;

  bool _isEmailResendEnabled = false;
  bool isLoading = false;

  late AppDio _dio;
  final AppLogger _logger = AppLogger();

  bool get _isPhoneOtp => widget.mode == OtpMode.phone;

  @override
  void initState() {
    super.initState();
    _dio = AppDio(context);
    _logger.init();
    _startEmailTimer();
    _requestOtp(context);
  }

  @override
  void dispose() {
    _emailTimer.cancel();
    _emailOtpController.dispose();
    super.dispose();
  }

  void _startEmailTimer() {
    _isEmailResendEnabled = false;
    _emailCountdown = 120;
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_emailCountdown == 0) {
        _isEmailResendEnabled = true;
        timer.cancel();
      } else {
        _emailCountdown--;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildOtpContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: ScreenSize(context).width,
      height: 220,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/Head.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/logo1.png', height: 50),
            const SizedBox(height: 30),
            AppText.appText(
              "OTP Verification",
              fontSize: 32,
              fontWeight: FontWeight.w600,
              textColor: AppTheme.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildEmailOtpSection(),
            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailOtpSection() {
    return _buildOtpSection(
      iconPath: _isPhoneOtp
          ? "assets/images/otpPhone.png"
          : "assets/images/otpEmail.png",
      title: _isPhoneOtp ? "Please check your SMS" : "Please check your Email",
      subtitle:
          "We've sent a code to ${_isPhoneOtp ? '+${widget.phone}' : widget.email}",
      controller: _emailOtpController,
      onResend: () {
        _requestOtp(context);
        _startEmailTimer();
      },
      isResendEnabled: _isEmailResendEnabled,
      countdown: _emailCountdown,
    );
  }

  Widget _buildOtpSection({
    required String iconPath,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required VoidCallback onResend,
    required bool isResendEnabled,
    required int countdown,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(iconPath, height: 48),
        const SizedBox(height: 20),
        AppText.appText(
          title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: Colors.black87,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        AppText.appText(
          subtitle,
          fontSize: 16,
          textColor: AppTheme.lighttxtColor,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        PinCodeTextField(
          appContext: context,
          length: 4,
          controller: controller,
          enableActiveFill: true,
          keyboardType: TextInputType.number,
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
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Didn't get a code? ", style: TextStyle(fontSize: 14)),
            isResendEnabled
                ? GestureDetector(
                    onTap: onResend,
                    child: const Text(
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
                    "Resend in ${countdown}s",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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
          borderColor: Colors.transparent,
        ),
        AppButton.appButton(
          "Verify",
          context: context,
          onTap: () => _verifyOtp(context),
          width: ScreenSize(context).width * 0.4,
          borderColor: Colors.transparent,
          backgroundColor: AppTheme.primaryCOlor,
        ),
      ],
    );
  }

  /// OTP request
  Future<void> _requestOtp(context) async {
    setState(() => isLoading = true);

    final params = <String, dynamic>{
      "userId": widget.userId,
      "type": _isPhoneOtp ? "phone" : "email",
      "purpose": _isPhoneOtp ? "phone_verification" : "email_verification",
    };

    if (widget.fromEditProfile) {
      if (_isPhoneOtp && widget.phone != null) {
        params["phone"] = widget.phone;
      } else if (widget.email != null) {
        params["email"] = widget.email;
      }
    }

    try {
      final response = await _dio.post(path: AppUrls.otp, data: params);
      final data = response.data;

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: data["message"]);
      } else {
        AppToast.error(context: context, msg: data["message"]);
      }
    } catch (e) {
      if (kDebugMode) print("OTP request failed: $e");
      AppToast.error(context: context, msg: "Something went wrong: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// OTP verification
  Future<void> _verifyOtp(context) async {
    final otp = _emailOtpController.text;

    if (otp.isEmpty || otp.length < 4) {
      return AppToast.error(context: context, msg: "Please enter a valid OTP");
    }

    setState(() => isLoading = true);

    final verifyParams = {
      "userId": widget.userId,
      "otp": otp,
      "type": _isPhoneOtp ? "phone" : "email",
      "purpose": _isPhoneOtp ? "phone_verification" : "email_verification",
    };

    try {
      final verifyResponse = await _dio.post(
        path: AppUrls.verifyOtp,
        data: verifyParams,
      );
      final verifyData = verifyResponse.data;

      if (verifyResponse.statusCode == 200) {
        AppToast.success(context: context, msg: verifyData["message"]);
        if (widget.fromEditProfile) {
          final updateParams = <String, dynamic>{
            if (_isPhoneOtp && widget.phone != null) "phone": widget.phone,
            if (!_isPhoneOtp && widget.email != null) "email": widget.email,
          };
          final updateResponse = await _dio.post(
            path: globalUserRole == "TUTOR"
                ? AppUrls.editTutorProfile
                : AppUrls.editParentProfile,
            data: updateParams,
          );
          final updateData = updateResponse.data;

          if (updateResponse.statusCode == 200) {
            final provider = Provider.of<TutorEditProfileProvider>(
              context,
              listen: false,
            );
            provider.updateEmailAndPhone(
              newEmail: _isPhoneOtp ? null : widget.email,
              newPhone: _isPhoneOtp ? '+${widget.phone}' : null,
            );
            if (_isPhoneOtp) {
              Navigator.pop(context, true);
            } else {
              AppToast.success(context: context, msg: updateData["message"]);
              handleLogOut(context);
            }
          } else {
            AppToast.error(
              context: context,
              msg:
                  updateData["errors"]?[0]?["message"] ??
                  "Update profile failed",
            );
          }
        } else {
          // SignIn flow
          pushUntil(context, LogInScreen());
        }
      } else {
        AppToast.error(
          context: context,
          msg:
              verifyData["errors"]?[0]?["message"] ?? "OTP verification failed",
        );
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
