import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:flutterustad/Screens/Authentication/otp.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/Screens/BottomNavBar/bottom_bar.dart';
import 'package:flutterustad/config/keys/global.dart';

class ChangeEmailPhone extends StatefulWidget {
  final bool isPhone;
  final String? initialPhone;

  const ChangeEmailPhone({super.key, required this.isPhone, this.initialPhone});

  @override
  State<ChangeEmailPhone> createState() => _ChangeEmailPhoneState();
}

class _ChangeEmailPhoneState extends State<ChangeEmailPhone> {
  final TextEditingController _controller = TextEditingController();
  PhoneNumber? _initialPhoneNumber;

  @override
  void initState() {
    super.initState();
    if (widget.isPhone) {
      try {
        _initialPhoneNumber = PhoneNumber.parse(widget.initialPhone ?? '+92');
        _controller.text =
            '${_initialPhoneNumber!.countryCode}${_initialPhoneNumber!.nsn}';
      } catch (_) {
        _initialPhoneNumber = PhoneNumber.parse('+92');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          authHeader(
            context: context,
            isFromSetting: true,
            isEditPhone: widget.isPhone,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isPhone) _buildPhoneField(),
                  if (!widget.isPhone)
                    customLableField(lable: "Email", controller: _controller),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: AppButton.appButton(
                      "Continue",
                      context: context,
                      onTap: widget.isPhone
                          ? _continueWithPhone
                          : _continueWithEmail,
                      backgroundColor: AppTheme.primaryCOlor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText(
          "Mobile Number",
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
            initialValue: _initialPhoneNumber,
            countrySelectorNavigator:
                const CountrySelectorNavigator.draggableBottomSheet(),
            autovalidateMode: AutovalidateMode.disabled,
            onChanged: (phoneNumber) {
              _controller.text = '${phoneNumber.countryCode}${phoneNumber.nsn}';
            },
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            countryButtonStyle: const CountryButtonStyle(
              showDialCode: true,
              showFlag: true,
              flagSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _continueWithEmail() {
    final email = _controller.text.trim().toLowerCase();
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || !emailPattern.hasMatch(email)) {
      AppToast.error(
        context: context,
        msg: "Please enter a valid email address.",
      );
      return;
    }

    push(
      context,
      OtpScreen(
        userId: globalUserId,
        email: email,
        mode: OtpMode.email,
        fromEditProfile: true,
      ),
    );
  }

  Future<void> _continueWithPhone() async {
    final phone = _controller.text.replaceAll(RegExp(r'\D'), '');

    if (phone.length < 8 || phone.length > 15) {
      AppToast.error(
        context: context,
        msg: "Please enter a valid mobile number.",
      );
      return;
    }

    final updated = await Provider.of<TutorEditProfileProvider>(
      context,
      listen: false,
    ).updatePhoneNumber(context, phone);

    if (!mounted) return;
    if (updated) {
      pushUntil(
        context,
        BottomNavView(
          tutor: globalUserRole == "TUTOR",
          snackbarMessage: "Mobile number updated successfully",
        ),
      );
    }
  }
}
