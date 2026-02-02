import 'package:flutter/material.dart';
import 'package:password_strength_indicator/password_strength_indicator.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Screens/Authentication/SignUP/sign_up_screen.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/Screens/Authentication/widgets/widgets.dart';

class UserDetailsForm extends StatefulWidget {
  final TabController tabController;
  final SignupData signupData;

  const UserDetailsForm({
    super.key,
    required this.tabController,
    required this.signupData,
  });

  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  @override
  void initState() {
    super.initState();
    widget.signupData.passwordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.appText("Sign Up As:",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textColor: AppTheme.lighttxtColor),
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
            AppText.appText("Gender",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: AppTheme.lableText),
            SizedBox(
              height: 10,
            ),
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
                lable: "First Name",
                controller: widget.signupData.fNameController),
            const SizedBox(height: 20),
            customLableField(
                lable: "Last Name",
                controller: widget.signupData.lNameController),
            const SizedBox(height: 20),
            customLableField(
                lable: "Email", controller: widget.signupData.emailController),
            const SizedBox(height: 20),
            _phoneInput(),
            const SizedBox(height: 20),
            customLableField(
                lable: "Password",
                isPassword: true,
                controller: widget.signupData.passwordController),
            const SizedBox(height: 20),
            _passwordStrength(),
            const SizedBox(height: 10),
            passwordRequirements(),
            const SizedBox(height: 20),
            AppButton.appButton("Next",
                onTap: _validateUserDetails, context: context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    return GestureDetector(
      onTap: () => setState(() => widget.signupData.selectedGender = gender),
      child: Container(
        height: 36,
        width: MediaQuery.of(context).size.width * 0.41,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.signupData.selectedGender == gender
                ? AppTheme.appColor
                : const Color(0xffD4D8E2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: widget.signupData.selectedGender,
              activeColor: AppTheme.appColor,
              onChanged: (value) =>
                  setState(() => widget.signupData.selectedGender = value!),
            ),
            AppText.appText(
              gender,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText("Phone Number",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: AppTheme.lableText),
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
              widget.signupData.phoneController.text =
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

  Widget _passwordStrength() {
    return PasswordStrengthIndicator(
      password: widget.signupData.passwordController.text,
      width: ScreenSize(context).width,
      thickness: 5,
      radius: 8,
      backgroundColor: Colors.grey,
      colors: StrengthColors(
        weak: Colors.orange,
        medium: Colors.yellow,
        strong: Colors.green,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      callback: (_) {},
      strengthBuilder: (password) => password.length / 10,
      style: StrengthBarStyle.dashed,
    );
  }

  void _validateUserDetails() {
    print("nfkf{${widget.signupData.selectedGender}");
    final firstName = widget.signupData.fNameController.text.trim();
    final lastName = widget.signupData.lNameController.text.trim();
    final email = widget.signupData.emailController.text.trim();
    final phone = widget.signupData.phoneController.text.trim();
    final password = widget.signupData.passwordController.text.trim();

    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');

    if (firstName.isEmpty) {
      AppToast.error(context: context, msg: "Please enter your First name.");
    }
    if (lastName.isEmpty) {
      AppToast.error(context: context, msg: "Please enter your First name.");
    } else if (email.isEmpty || !emailPattern.hasMatch(email)) {
      AppToast.error(
          context: context, msg: "Please enter a valid email address.");
    } else if (phone.isEmpty || phone.length != 12) {
      AppToast.error(
          context: context, msg: "Please enter a valid phone number.");
    } else if (password.isEmpty || password.length < 6) {
      AppToast.error(
          context: context,
          msg: "Password must be at least 6 characters long.");
    } else if (!passwordRegex.hasMatch(password)) {
      AppToast.error(
          context: context,
          msg:
              "Password must include uppercase, number, and special character.");
    } else {
      widget.tabController.animateTo(1);
    }
  }

  Widget _buildRoleOption(String role) {
    return GestureDetector(
      onTap: () => setState(() => widget.signupData.selectedRole = role),
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
              groupValue: widget.signupData.selectedRole,
              activeColor: AppTheme.appColor,
              onChanged: (value) =>
                  setState(() => widget.signupData.selectedRole = value!),
            ),
            AppText.appText(role, fontSize: 14, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
