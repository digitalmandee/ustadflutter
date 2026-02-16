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
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/Screens/Drawer/drawer.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/Custom%20widgets/session_cards.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/checkout.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/reverse_timer.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/session_update_screen.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/subsession_list.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';

class TutorSessionScreen extends StatefulWidget {
  const TutorSessionScreen({super.key});

  @override
  State<TutorSessionScreen> createState() => _TutorSessionScreenState();
}

class _TutorSessionScreenState extends State<TutorSessionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showUpcoming = true;
  bool isLoading = false;

  late AppDio dio;
  final AppLogger logger = AppLogger();

  List<dynamic> upcomingSessions = [];
  List<dynamic> runningSessions = [];

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    getSessions(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TutorDashBoardProvider>();
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SideMenuDrawer(
        crossOnTap: () => _scaffoldKey.currentState?.closeEndDrawer(),
        isTutor: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset("assets/images/Background.png", fit: BoxFit.fill),
          ),
          Column(
            children: [
              CustomAppBar(
                taskSummary: provider.tasks,
                onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildToggleTabs(),
                    const SizedBox(height: 10),
                    _buildSessionsContent(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      height: 40,
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xffECEEF3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Row(
          children: [
            _buildToggleButton("Upcoming", isSelected: showUpcoming, onTap: () {
              setState(() => showUpcoming = true);
            }),
            _buildToggleButton("Completed", isSelected: !showUpcoming,
                onTap: () {
              setState(() => showUpcoming = false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text,
      {required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.appColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: AppText.appText(
              text,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: isSelected ? AppTheme.white : AppTheme.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsContent() {
    if (isLoading) return Expanded(child: GifLoader());

    if (upcomingSessions.isEmpty) {
      if (showUpcoming) {
        return Expanded(
          child: Center(
            child: AppText.appText("No Upcoming Session at this Time"),
          ),
        );
      } else {
        return Expanded(
          child: Center(
            child: AppText.appText("No Completed Session at this Time"),
          ),
        );
      }
    }

    return Expanded(
      child: MasonryGridView.count(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 75),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: upcomingSessions.length,
        itemBuilder: (context, index) {
          final session = upcomingSessions[index];
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
            onTap: () => _onSessionTap(session, isRunning),
            child: SessionCard(
              sessionsCompleted: session["sessionsCompleted"],
              totalSessions: session["totalSessions"],
              startTime: formatTimeTo12Hour(session["startTime"]),
              childName: capitalizeEachWord(session["childName"]),
              title: showUpcoming
                  ? "Class at ${session["parentName"] ?? ""}'s House"
                  : "${session["parentName"] ?? ""}'s House",
              duration: "$duration session",
              fee: "Rs. ${(session["price"]).toStringAsFixed(0)}",
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
                  getSessions(context);
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

  void _onSessionTap(Map<String, dynamic> session, isonTap) {
    if (showUpcoming) {
      if (isonTap == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SessionCheckOut(
                    ruuningId: runningSessions[0]["id"],
                    parentId: "${session["parentId"]}",
                    tutorId: "${session["tutorId"]}",
                    sessionId: "${session["id"]}",
                  )),
        ).then((_) {
          getSessions(context);
        });
      } else if (runningSessions.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionUpdateScreen(
              runningId:
                  runningSessions.isEmpty ? "" : runningSessions[0]["id"],
              isRunning: isonTap,
              name: "${session["parentName"]}",
              parentId: "${session["parentId"]}",
              tutorId: "${session["tutorId"]}",
              sessionId: "${session["id"]}",
            ),
          ),
        ).then((_) {
          getSessions(context);
        });
      } else {
        AppToast.error(
          context: context,
          msg: "A session is already running at this time",
        );
      }
    } else {
      push(
        context,
        SubSessionScreen(
          name: "${session["parentName"]}",
          parentId: "${session["parentId"]}",
          tutorId: "${session["tutorId"]}",
          sessionId: "${session["id"]}",
        ),
      );
    }
  }

  // ------------------ Helpers ------------------ //
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

  // ------------------ API ------------------ //
  Future<void> getSessions(context) async {
    setState(() => isLoading = true);

    try {
      final response = await dio.get(path: AppUrls.getsessions);
      final responseData = response.data;

      if (response.statusCode == 200 && responseData["data"] != null) {
        final sessions = responseData["data"]["sessions"] as List<dynamic>;
        final running =
            responseData["data"]["runningSessions"] as List<dynamic>;

        setState(() {
          upcomingSessions =
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
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(
        context: context,
        msg: message,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
