import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
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
  TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  bool isEmail = true;
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
                  isEmail == true
                      ? customLableField(
                          lable: "Email",
                          controller: _emailController,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.appText(
                              "Phone Number",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              textColor: AppTheme.lableText,
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xffD4D8E2),
                                ),
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PhoneFormField(
                                initialValue: PhoneNumber.parse('+92'),
                                countrySelectorNavigator:
                                    const CountrySelectorNavigator.draggableBottomSheet(),
                                onChanged: (phoneNumber) {
                                  phoneController.text =
                                      "+${phoneNumber.countryCode}${phoneNumber.nsn}";
                                },
                                enabled: true,
                                isCountrySelectionEnabled: true,
                                isCountryButtonPersistent: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                countryButtonStyle: const CountryButtonStyle(
                                  showDialCode: true,
                                  showFlag: true,
                                  flagSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: 20),
                  // Row(
                  //   children: [
                  //     AppText.appText(
                  //       isEmail == true
                  //           ? "Use your phone number instead  "
                  //           : "Use your email instead  ",
                  //       fontSize: 12,
                  //       textColor: Colors.black,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           isEmail = !isEmail;
                  //         });
                  //       },
                  //       child: AppText.appText(
                  //         isEmail == true ? "Phone Number." : "Email.",
                  //         fontSize: 12,
                  //         underLine: true,
                  //         textColor: AppTheme.appColor,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: isLoading == true
                        ? GifLoader()
                        : AppButton.appButton(
                            "Continue",
                            context: context,
                            onTap: () {
                              if (isEmail == true) {
                                print("nfjn3f3f  $isEmail");

                                String email = _emailController.text.trim();
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
                                  forgotPass(
                                    context,
                                    text: _emailController.text,
                                    isPhone: false,
                                  );
                                }
                              } else {
                                final phone = phoneController.text.trim();
                                if (phone.isEmpty || phone.length != 13) {
                                  AppToast.error(
                                    context: context,
                                    msg: "Please enter a valid phone number.",
                                  );
                                } else {
                                  forgotPass(
                                    context,
                                    text: _emailController.text
                                        .trim()
                                        .toLowerCase(),
                                    isPhone: false,
                                  );
                                }
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

  void forgotPass(context, {text, isPhone}) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> params = isPhone
        ? {"phone": text.replaceAll("+", "")}
        : {"email": text.toString().trim().toLowerCase()};

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
            isEmail: isPhone == true ? false : true,
            email: responseData["data"]["email"],
            userId: responseData["data"]["userId"],
            phone: responseData["data"]["phone"],
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
