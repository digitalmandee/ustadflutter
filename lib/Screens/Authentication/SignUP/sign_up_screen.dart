import 'package:flutter/material.dart';
import 'package:ustaad/Screens/Authentication/SignUP/additional_detail.dart';
import 'package:ustaad/Screens/Authentication/SignUP/signup_otp.dart';
import 'package:ustaad/Screens/Authentication/SignUP/stepper.dart';
import 'package:ustaad/Screens/Authentication/SignUP/user_detail_form.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  late SignupData signupData;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    signupData = SignupData();
    tabController.addListener(() {
      setState(() {}); // Force rebuild on tab change
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          authHeader(context: context, isSignInScreen: false),
          SignupStepper(tabController: tabController),
          Expanded(
            child: TabBarView(
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
                ),
              ],
            ),
          )
        ],
      ),
    );
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
  final TextEditingController phoneOtpController = TextEditingController();
}
