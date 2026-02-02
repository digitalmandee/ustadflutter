import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/calculate_duration.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/timeformat.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/Custom%20widgets/session_cards.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Drawer/tutor_drawer.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Sessions/parent_sub_session.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/checkout.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/reverse_timer.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';

class ParentSessionScreen extends StatefulWidget {
  const ParentSessionScreen({super.key});

  @override
  State<ParentSessionScreen> createState() => _ParentSessionScreenState();
}

class _ParentSessionScreenState extends State<ParentSessionScreen> {
  final completedSessions = [
    SessionCard(
      title: "Class at Mir Ahmed's House",
      toDate: '3 December 2024',
      fee: 'Rs. 17000/mo',
      fromDate: "26 June 2024",
      time: const Text("01:00:00"),
      isCompleted: true,
      rating: "4.5",
    ),
    SessionCard(
      title: "Class at Mir Ahmed's House",
      toDate: '3 December 2024',
      fee: 'Rs. 17000/mo',
      fromDate: "26 June 2024",
      time: const Text("01:00:00"),
      isCompleted: true,
      rating: "4.5",
    ),
    SessionCard(
      title: "Class at Mir Ahmed's House",
      toDate: '3 December 2024',
      fee: 'Rs. 17000/mo',
      fromDate: "26 June 2024",
      time: const Text("01:00:00"),
      isCompleted: true,
      rating: "4.5",
    ),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showUpcoming = true;
  bool isLoading = false;

  late AppDio dio;
  final AppLogger logger = AppLogger();

  List<dynamic> upcomingParentSessions = [];
  List<dynamic> runningSessions = [];

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    getParentSessions(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentProfileProvider>();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SideMenuDrawer(
        crossOnTap: () => _scaffoldKey.currentState?.closeEndDrawer(),
        isTutor: false,
      ),
      appBar: CustomAppBar(
          onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          taskSummary: provider.tasks),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 40,
            width: 220,
            decoration: BoxDecoration(
                color: Color(0xffECEEF3),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        showUpcoming = true;
                      });
                    },
                    child: Container(
                      height: 35,
                      width: 108,
                      decoration: BoxDecoration(
                          color: showUpcoming
                              ? AppTheme.appColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: AppText.appText("Upcoming",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              textColor: showUpcoming
                                  ? AppTheme.white
                                  : AppTheme.black)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showUpcoming = false;
                      });
                    },
                    child: Container(
                      height: 35,
                      width: 108,
                      decoration: BoxDecoration(
                          color: !showUpcoming
                              ? AppTheme.appColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: AppText.appText("Completed",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              textColor: !showUpcoming
                                  ? AppTheme.white
                                  : AppTheme.black)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSessionsContent()
        ],
      ),
    );
  }

  Widget _buildSessionsContent() {
    if (isLoading) return Expanded(child: GifLoader());

    if (upcomingParentSessions.isEmpty) {
      return Expanded(
        child: Center(
          child: AppText.appText("No Upcoming Session at this Time"),
        ),
      );
    }

    return Expanded(
      child: MasonryGridView.count(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 75),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: upcomingParentSessions.length,
        itemBuilder: (context, index) {
          final session = upcomingParentSessions[index];
          final duration = calculateDuration(
            session["startTime"] ?? "00:00:00",
            session["endTime"] ?? "00:00:00",
          );

          final isRunning = runningSessions.any(
            (r) => r["sessionId"] == session["id"] && r["status"] == "CREATED",
          );

          final runningSubSessionId =
              runningSessions.isNotEmpty ? runningSessions[0]["id"] : "";

          return InkWell(
            onTap: () {
              if (showUpcoming == false) {
                push(
                    context,
                    ParentSubSessionScreen(
                      name: "${session["parentName"]}",
                      parentId: "${session["parentId"]}",
                      tutorId: "${session["tutorId"]}",
                      sessionId: "${session["id"]}",
                      childName: capitalizeEachWord(session['childName']),
                    ));
              }
            },
            child: SessionCard(
              isParentSide: true,
              childName: capitalizeEachWord(session['childName']),
              startTime: formatTimeTo12Hour(session["startTime"]),
              sessionsCompleted: session["sessionsCompleted"],
              totalSessions: session["totalSessions"],
              endTime: formatTimeTo12Hour(session["endTime"]),
              title: showUpcoming
                  ? capitalizeEachWord(
                      "Class of ${session["tutorName"] ?? ""}'s")
                  : capitalizeEachWord("${session["tutorName"] ?? ""}'s"),
              duration: "$duration session",
              fee: "Rs. ${session["price"]}",
              days: formatDays(session["daysOfWeek"] ?? []),
              isRunning: isRunning,
              onCheckout: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SessionCheckOut(
                            ruuningId: runningSubSessionId,
                            parentId: "${session["parentId"]}",
                            tutorId: "${session["tutorId"]}",
                            sessionId: "${session["id"]}",
                          )),
                ).then((_) {
                  getParentSessions(context);
                });
              },
              time: ReverseTimer(
                color: !isRunning ? AppTheme.white : AppTheme.appColor,
                startTime: session["startTime"],
                endTime: session["endTime"],
              ),
              fromDate: session["month"],
              isCompleted: !showUpcoming,
              color: showUpcoming && index == 0 ? AppTheme.primaryCOlor : null,
            ),
          );
        },
      ),
    );
  }

  String formatDays(List<dynamic> days) {
    if (days.isEmpty) return "";

    const weekDays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

    final sortedDays = days.map((d) => d.toString().toLowerCase()).toList()
      ..sort((a, b) => weekDays.indexOf(a).compareTo(weekDays.indexOf(b)));

    final startIndex = weekDays.indexOf(sortedDays.first);
    final endIndex = weekDays.indexOf(sortedDays.last);

    final expectedRange = weekDays.sublist(startIndex, endIndex + 1);
    final isContinuous = listEquals(expectedRange, sortedDays);

    if (isContinuous && sortedDays.length > 1) {
      return "${capitalize(sortedDays.first)}-${capitalize(sortedDays.last)}";
    }
    return sortedDays.map(capitalize).join(", ");
  }

  String capitalize(String day) =>
      day.isEmpty ? day : day[0].toUpperCase() + day.substring(1);
  Future<void> getParentSessions(context) async {
    setState(() => isLoading = true);

    try {
      final response = await dio.get(path: AppUrls.getparentSessions);
      final responseData = response.data;

      if (response.statusCode == 200 && responseData["data"] != null) {
        final sessions = responseData["data"]["sessions"] as List<dynamic>;
        final running =
            responseData["data"]["runningSessions"] as List<dynamic>;

        setState(() {
          upcomingParentSessions =
              sessions.where((s) => s["status"] == "active").toList();
          runningSessions = running;
          isLoading = false;
        });
        return;
      }

      if (response.statusCode == 401 &&
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
      String message = "Something went wrong $e";

      // if (e is DioException) {
      //   message = e.error?.toString() ?? "Check Internet Connection";
      // } else {
      //   message = e.toString();
      // }

      AppToast.error(
        context: context,
        msg: message,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
