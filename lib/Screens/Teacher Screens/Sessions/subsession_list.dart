import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/urls.dart';

class SubSessionScreen extends StatefulWidget {
  final String name;
  final String tutorId;
  final String parentId;
  final String sessionId;
  const SubSessionScreen({
    super.key,
    required this.name,
    required this.tutorId,
    required this.parentId,
    required this.sessionId,
  });

  @override
  State<SubSessionScreen> createState() => _SubSessionScreenState();
}

class _SubSessionScreenState extends State<SubSessionScreen> {
  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  List<dynamic> subSession = [];

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    getSessions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar1(title: "Sub Sessions", backArrow: true),
      body: isLoading
          ? GifLoader()
          : subSession.isEmpty
          ? Center(
              child: AppText.appText(
                "No sub session yet",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: Colors.grey,
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: subSession.length,
              itemBuilder: (context, index) {
                var data = subSession[index];
                return Column(
                  children: [
                    if (index == 0) SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.only(
                        bottom: 15.0,
                        left: 20,
                        right: 20,
                      ),
                      child: Container(
                        width: ScreenSize(context).width,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border(
                            left: BorderSide(
                              width: 5,
                              color: AppTheme.primaryCOlor,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: ScreenSize(context).width * 0.5,
                                child: AppText.appText(
                                  "Session at ${data["parentName"]}'s House",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppTheme.black,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AppText.appText(
                                    formatDate("${data["createdAt"]}"),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppTheme.black,
                                  ),
                                  SizedBox(height: 10),
                                  AppText.appText(
                                    "${data["status"]}",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppTheme.appColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  String formatDate(String isoString) {
    DateTime date = DateTime.parse(isoString);
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  void getSessions(context) async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response = await dio.get(
        path: AppUrls.getSubsession,
        queryParameters: {'sessionId': widget.sessionId},
      );
      var responseData = response.data;

      if (response.statusCode == 200 && responseData["data"] != null) {
        final sessions = responseData["data"];

        setState(() {
          isLoading = false;
          if (sessions == null) {
            subSession = [];
          } else if (sessions is List) {
            subSession = sessions;
          } else if (sessions is Map) {
            subSession = [sessions];
          } else {
            subSession = [];
          }
        });
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
        debugPrint("Something went wrong: $e");
      }
      AppToast.error(context: context, msg: "Something went wrong$e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
