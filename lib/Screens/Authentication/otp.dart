import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:ustaad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';

enum OtpMode { both, email, phone }

class OtpScreen extends StatefulWidget {
  final String? userId;
  final String? email;
  final String? phone;
  final OtpMode mode;
  final bool fromEditProfile; // Add this flag to distinguish flows

  const OtpScreen({
    super.key,
    this.userId,
    this.email,
    this.phone,
    required this.mode,
    this.fromEditProfile = false, // default false for SignIn
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();

  late Timer _emailTimer;
  late Timer _smsTimer;

  int _emailCountdown = 120;
  int _smsCountdown = 120;

  bool _isEmailResendEnabled = false;
  bool _isSmsResendEnabled = false;
  bool isLoading = false;

  late AppDio _dio;
  final AppLogger _logger = AppLogger();

  @override
  void initState() {
    super.initState();
    _dio = AppDio(context);
    _logger.init();

    if (_isEmailRequired) _startEmailTimer();
    if (_isSmsRequired) _startSmsTimer();

    // Request OTP automatically on open
    if (widget.fromEditProfile) {
      if (_isEmailRequired) _requestOtp(context, true);
      if (_isSmsRequired) _requestOtp(context, false);
    } else {
      if (_isEmailRequired) _requestOtp(context, true);
      if (_isSmsRequired) _requestOtp(context, false);
    }
  }

  bool get _isEmailRequired =>
      widget.mode == OtpMode.email || widget.mode == OtpMode.both;

  bool get _isSmsRequired =>
      widget.mode == OtpMode.phone || widget.mode == OtpMode.both;

  @override
  void dispose() {
    if (_isEmailRequired) _emailTimer.cancel();
    if (_isSmsRequired) _smsTimer.cancel();
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

  void _startSmsTimer() {
    _isSmsResendEnabled = false;
    _smsCountdown = 120;
    _smsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_smsCountdown == 0) {
        _isSmsResendEnabled = true;
        timer.cancel();
      } else {
        _smsCountdown--;
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
            if (_isEmailRequired) _buildEmailOtpSection(),
            if (_isEmailRequired) const SizedBox(height: 40),
            if (_isSmsRequired) _buildSmsOtpSection(),
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
      iconPath: "assets/images/otpEmail.png",
      title: "Please check your email",
      subtitle: "We've sent a code to ${widget.email}",
      controller: _emailOtpController,
      onResend: () {
        _requestOtp(context, true);
        _startEmailTimer();
      },
      isResendEnabled: _isEmailResendEnabled,
      countdown: _emailCountdown,
    );
  }

  Widget _buildSmsOtpSection() {
    return _buildOtpSection(
      iconPath: "assets/images/otpPhone.png",
      title: "Please check your SMS",
      subtitle: "We've sent a code to ${widget.phone}",
      controller: _phoneOtpController,
      onResend: () {
        _requestOtp(context, false);
        _startSmsTimer();
      },
      isResendEnabled: _isSmsResendEnabled,
      countdown: _smsCountdown,
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
  Future<void> _requestOtp(context, bool isEmail) async {
    setState(() => isLoading = true);

    final params = <String, dynamic>{
      "userId": widget.userId,
      "type": isEmail ? "email" : "phone",
      "purpose": isEmail ? "email_verification" : "phone_verification",
    };

    // Only send email/phone if coming from EditProfile
    if (widget.fromEditProfile) {
      if (isEmail && widget.email != null) params["email"] = widget.email;
      if (!isEmail && widget.phone != null) params["phone"] = widget.phone;
    }

    try {
      final response = await _dio.post(path: AppUrls.otp, data: params);
      final data = response.data;

      if (response.statusCode == 200) {
        AppToast.success(
          context: context,
          msg: data["message"],
        );
      } else {
        AppToast.error(
          context: context,
          msg: data["message"],
        );
      }
    } catch (e) {
      if (kDebugMode) print("OTP request failed: $e");
      AppToast.error(
        context: context,
        msg: "Something went wrong: $e",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// OTP verification
  Future<void> _verifyOtp(context) async {
    final otp =
        _isEmailRequired ? _emailOtpController.text : _phoneOtpController.text;

    if (otp.isEmpty || otp.length < 4) {
      return AppToast.error(
        context: context,
        msg: "Please enter a valid OTP",
      );
    }

    setState(() => isLoading = true);

    final verifyParams = {
      "userId": widget.userId,
      "otp": otp,
      "type": _isEmailRequired ? "email" : "phone",
      "purpose": _isEmailRequired ? "email_verification" : "phone_verification",
    };

    try {
      final verifyResponse =
          await _dio.post(path: AppUrls.verifyOtp, data: verifyParams);
      final verifyData = verifyResponse.data;

      if (verifyResponse.statusCode == 200) {
        AppToast.success(
          context: context,
          msg: verifyData["message"],
        );

        // Only call updateProfile if coming from EditProfile
        if (widget.fromEditProfile) {
          final updateParams = <String, dynamic>{
            if (_isEmailRequired && widget.email != null) "email": widget.email,
            if (_isSmsRequired && widget.phone != null) "phone": widget.phone!.replaceAll("+", ""),
          };
          final updateResponse = await _dio.post(
              path: globalUserRole == "TUTOR"
                  ? AppUrls.editTutorProfile
                  : AppUrls.editParentProfile,
              data: updateParams);
          final updateData = updateResponse.data;

          if (updateResponse.statusCode == 200) {
            AppToast.success(
              context: context,
              msg: updateData["message"],
            );
            final provider =
                Provider.of<TutorEditProfileProvider>(context, listen: false);
            provider.updateEmailAndPhone(
              newEmail: _isEmailRequired ? widget.email : null,
              newPhone: _isSmsRequired ? widget.phone : null,
            );
            handleLogOut(context);
          } else {
            AppToast.error(
              context: context,
              msg: updateData["errors"]?[0]?["message"] ??
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
      AppToast.error(
        context: context,
        msg: "Something went wrong: $e",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
