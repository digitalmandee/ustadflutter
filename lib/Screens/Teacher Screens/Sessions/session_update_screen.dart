import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Sessions/checkout.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/urls.dart';

class SessionUpdateScreen extends StatefulWidget {
  final String name;
  final String tutorId;
  final String parentId;
  final String sessionId;
  final String runningId;
  final bool isRunning;
  const SessionUpdateScreen({
    super.key,
    required this.name,
    required this.tutorId,
    required this.parentId,
    required this.sessionId,
    required this.isRunning,
    required this.runningId,
  });

  @override
  State<SessionUpdateScreen> createState() => _SessionUpdateScreenState();
}

class _SessionUpdateScreenState extends State<SessionUpdateScreen> {
  late String todayDate;
  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  @override
  void initState() {
    super.initState();
    super.initState();
    dio = AppDio(context);
    logger.init();
    todayDate = DateFormat("dd-MMMM-yyyy").format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar1(title: "Session Update", backArrow: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/Background.png",
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          text: 'Class at ',
                          style: TextStyle(
                            fontSize: 40,
                            color: AppTheme.black,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '${widget.name} House',
                              style: TextStyle(
                                color: AppTheme.appColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            text: 'Attendance ',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: todayDate,
                                style: TextStyle(
                                  color: AppTheme.primaryCOlor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: customButton(
                          text: widget.isRunning == true
                              ? "Check Out"
                              : "Check In Now",
                          color: AppTheme.appColor,
                          img: "assets/images/clock.png",
                          imgColor: AppTheme.white,
                          onTap: () {
                            if (widget.isRunning == true) {
                              pushReplacement(
                                context,
                                SessionCheckOut(
                                  ruuningId: widget.runningId,
                                  parentId: widget.parentId,
                                  tutorId: widget.tutorId,
                                  sessionId: widget.sessionId,
                                ),
                              );
                            } else {
                              createSession(context, "CREATED");
                            }
                          },
                        ),
                      ),
                      // customButton(
                      //     text: "Doing Holiday",
                      //     color: AppTheme.black,
                      //     img: "assets/images/holiday.png",
                      //     onTap: () {
                      //       createSession(context, 'TUTOR_HOLIDAY');
                      //     }),
                      // customButton(
                      //     text: "Public Holiday",
                      //     color: AppTheme.primaryCOlor,
                      //     img: "assets/images/calender.png",
                      //     onTap: () {
                      //       createSession(context, "PUBLIC_HOLIDAY");
                      //     }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget customButton({
    required String text,
    required Color color,
    required String img,
    required Function() onTap,
    Color? imgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: AppButton.appButton(
        text,
        context: context,
        onTap: onTap,
        width: ScreenSize(context).width * 0.8,
        height: 60,
        fontSize: 20,
        imgHeight: 20,
        textColor: AppTheme.white,
        border: false,
        image: img,
        imgColor: imgColor,
        backgroundColor: color,
      ),
    );
  }

  Future<void> createSession(context, status) async {
    setState(() => isLoading = true);

    try {
      Map<String, dynamic> params = {
        "tutorId": widget.tutorId,
        "parentId": widget.parentId,
        "sessionId": widget.sessionId,
        "status": status,
      };
      Response response = await dio.post(
        path: AppUrls.createSubSession,
        data: params,
      );
      final responseData = response.data;

      if (response.statusCode == 200 && responseData["data"] != null) {
        setState(() {
          isLoading = false;

          Future.delayed(const Duration(milliseconds: 400), () {
            if (context.mounted) Navigator.pop(context);
            if (mounted) {
              AppToast.success(
                context: context,
                msg: "Checked In Successfully!",
              );
            }
          });
        });

        return;
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      } else {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Something went wrong: $e");
      AppToast.error(context: context, msg: "Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
}
