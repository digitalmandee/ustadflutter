import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/Screens/Authentication/Forgot%20Pass/confirm_pass.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/urls.dart';

class ForgotPassScreen extends StatefulWidget {
  final bool isEditing;
  const ForgotPassScreen({super.key, required this.isEditing});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    // clearPref();
    logger.init();
  }

  // clearPref() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   pref.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          authHeader(context: context, isPass: true, isEdit: widget.isEditing),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customLableField(
                    lable: "Email",
                    controller: _emailController,
                  ),
                  SizedBox(height: 20),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: isLoading == true
                        ? GifLoader()
                        : AppButton.appButton(
                            "Continue",
                            context: context,
                            onTap: () {
                              final email = _emailController.text.trim();
                              final emailPattern = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (email.isEmpty ||
                                  !emailPattern.hasMatch(email)) {
                                AppToast.error(
                                  context: context,
                                  msg: "Please enter a valid email address.",
                                );
                              } else {
                                forgotPass(context, email: email);
                              }
                            },
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

  void forgotPass(context, {required String email}) async {
    setState(() {
      isLoading = true;
    });

    final params = {"email": email.toLowerCase()};

    try {
      Response response = await dio.post(
        path: AppUrls.forgotPass,
        data: params,
      );
      var responseData = response.data;

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "${responseData["message"]}");
        setState(() {
          isLoading = false;
        });
        pushReplacement(
          context,
          ConfirmPassScreen(
            email: responseData["data"]["email"],
            userId: responseData["data"]["userId"],
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
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
