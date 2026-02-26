import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Authentication/otp.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';

class ChangeEmailPhone extends StatefulWidget {
  final bool isPhone;
  const ChangeEmailPhone({super.key, required this.isPhone});

  @override
  State<ChangeEmailPhone> createState() => _ChangeEmailPhoneState();
}

class _ChangeEmailPhoneState extends State<ChangeEmailPhone> {
  final TextEditingController _controller = TextEditingController();

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
  //   // pref.clear();
  // }

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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isPhone == false
                      ? customLableField(
                          lable: "Email",
                          controller: _controller,
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
                                  _controller.text =
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
                  //     AppText.appText("Use your mobile phone number instead  ",
                  //         fontSize: 12,
                  //         textColor: Colors.black,
                  //         fontWeight: FontWeight.w400),
                  //     GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           isEmail = !isEmail;
                  //         });
                  //       },
                  //       child: AppText.appText(
                  //           isEmail == true ? "Phone Number." : "Email.",
                  //           fontSize: 12,
                  //           underLine: true,
                  //           textColor: AppTheme.appColor,
                  //           fontWeight: FontWeight.w400),
                  //     )
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
                              String text = _controller.text.trim();
                              if (widget.isPhone == false) {
                                final emailPattern = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (text.isEmpty ||
                                    !emailPattern.hasMatch(text)) {
                                  AppToast.error(
                                    context: context,
                                    msg: "Please enter a valid email address.",
                                  );
                                } else {
                                  push(
                                    context,
                                    OtpScreen(
                                      mode: OtpMode.email,
                                      userId: globalUserId,
                                      email: _controller.text,
                                      fromEditProfile: true,
                                    ),
                                  );
                                }
                              } else {
                                final phone = _controller.text.trim();
                                if (phone.isEmpty || phone.length != 13) {
                                  AppToast.error(
                                    context: context,
                                    msg: "Please enter a valid phone number.",
                                  );
                                } else {
                                  push(
                                    context,
                                    OtpScreen(
                                      mode: OtpMode.phone,
                                      userId: globalUserId,
                                      phone: _controller.text,
                                      fromEditProfile: true,
                                    ),
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
}
