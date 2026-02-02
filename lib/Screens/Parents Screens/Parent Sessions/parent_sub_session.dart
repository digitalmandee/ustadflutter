import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class ParentSubSessionScreen extends StatefulWidget {
  final String name;
  final String tutorId;
  final String parentId;
  final String sessionId;
  final String childName;
  const ParentSubSessionScreen(
      {super.key,
      required this.name,
      required this.tutorId,
      required this.parentId,
      required this.sessionId,
      required this.childName});

  @override
  State<ParentSubSessionScreen> createState() => _ParentSubSessionScreenState();
}

class _ParentSubSessionScreenState extends State<ParentSubSessionScreen> {
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
      appBar: CustomAppBar1(
        title: "Sub Sessions",
        backArrow: true,
      ),
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
                        if (index == 0)
                          SizedBox(
                            height: 20,
                          ),
                        Card(
                          margin: const EdgeInsets.only(
                              bottom: 15.0, left: 20, right: 20),
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
                                        color: AppTheme.primaryCOlor)),
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: ScreenSize(context).width * 0.5,
                                    child: AppText.appText(
                                        capitalizeEachWord(
                                          "${data["tutorName"]} for ${widget.childName}",
                                        ),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        textColor: AppTheme.black),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AppText.appText(
                                          formatDate("${data["createdAt"]}"),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          textColor: AppTheme.black),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      AppText.appText("${data["status"]}",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          textColor: AppTheme.appColor),
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

  void getSessions(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response = await dio.get(
        path: AppUrls.getSubsession,
        queryParameters: {'sessionId': widget.sessionId},
      );

      final responseData = response.data;

      if (response.statusCode == 200) {
        final data = responseData["data"];

        setState(() {
          isLoading = false;

          if (data == null) {
            // ✅ No subsession yet
            subSession = [];
          } else if (data is List) {
            subSession = data;
          } else if (data is Map) {
            subSession = [data];
          } else {
            subSession = [];
          }
        });
      } else {
        setState(() => isLoading = false);
        AppToast.error(
          context: context,
          msg: responseData["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error: $e");
      AppToast.error(
        context: context,
        msg: "Something went wrong",
      );
    }
  }
}
