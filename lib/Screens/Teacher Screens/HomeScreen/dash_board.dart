import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Custom%20widgets/chart.dart';
import 'package:flutterustad/Helpers/calculate_duration.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Helpers/timeformat.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:flutterustad/Screens/BottomNavBar/bottom_bar.dart';
import 'package:flutterustad/Screens/Chats/bubble_widget.dart';
import 'package:flutterustad/Screens/Drawer/drawer.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Custom%20widgets/session_cards.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Sessions/checkout.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Sessions/reverse_timer.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Sessions/session_update_screen.dart';
import 'package:flutterustad/config/dio/app_logger.dart';

class TutorDashBoardScreen extends StatefulWidget {
  const TutorDashBoardScreen({super.key});

  @override
  State<TutorDashBoardScreen> createState() => _TutorDashBoardScreenState();
}

class _TutorDashBoardScreenState extends State<TutorDashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedMonth = 'March';
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    logger.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TutorDashBoardProvider>(
        context,
        listen: false,
      );
      provider.getTutorEarnings(context);
      provider.getSessions(context);
      provider.getTutorProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TutorDashBoardProvider>();
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SideMenuDrawer(
        isTutor: true,
        crossOnTap: () => _scaffoldKey.currentState?.closeEndDrawer(),
      ),
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
              CustomAppBar(
                taskSummary: provider.tasks,
                onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const DocumentAlertBanner(),
                      _buildBalanceSection(provider),
                      const SizedBox(height: 30),
                      _buildUpcomingSessions(provider),
                      // const SizedBox(height: 30),
                      _buildMonthlyProductivity(provider),
                      EarningsBarChart(isParent: false),
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

  /// ---------------- BALANCE SECTION ----------------

  Widget _buildBalanceSection(TutorDashBoardProvider provider) {
    final months = ["None", ...provider.monthlyEarnings.map((e) => e.month)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AppText.appText(
            "Your Balance",
            fontSize: 18,
            fontWeight: FontWeight.w400,
            textColor: AppTheme.black,
          ),
          const SizedBox(height: 3),
          AppText.appText(
            "Rs. ${provider.displayedBalance}",
            fontSize: 44,
            fontWeight: FontWeight.w600,
            textColor: AppTheme.black,
          ),
          const SizedBox(height: 4),

          /// ---------------- Dropdown Under Text ----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Balance for the month of ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: provider.selectedMonth,
                    isExpanded: true,
                    hint: Text(
                      "Select Month",
                      style: TextStyle(
                        color: AppTheme.hintColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    items: months.map((month) {
                      final isSelected = month == provider.selectedMonth;
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(
                          month,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.appColor
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    iconStyleData: IconStyleData(
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.appColor,
                      ),
                      iconSize: 18,
                      iconEnabledColor: AppTheme.appColor,
                      iconDisabledColor: Colors.grey,
                    ),
                    buttonStyleData: const ButtonStyleData(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250,
                      width: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      offset: const Offset(0, 5),
                    ),
                    onChanged: (value) {
                      if (value != null) provider.changeSelectedMonth(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- UPCOMING SESSIONS ----------------
  Widget _buildUpcomingSessions(TutorDashBoardProvider provider) {
    final sessions = provider.upcomingSessions;
    final limitedSessions = sessions.length > 2
        ? sessions.sublist(0, 2)
        : sessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          title: "Upcoming Sessions",
          actionText: provider.upcomingSessions.isEmpty ? "" : "View All",
          onTap: () {
            pushReplacement(context, BottomNavView(tutor: true, index: 2));
          },
        ),
        const SizedBox(height: 16),
        provider.upcomingSessions.isEmpty
            ? Center(child: AppText.appText("No Upcoming Sessions"))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: limitedSessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final session = entry.value;

                    final duration = calculateDuration(
                      session["startTime"] ?? "00:00:00",
                      session["endTime"] ?? "00:00:00",
                    );

                    final isRunning = provider.runningSessions.any(
                      (r) =>
                          r["sessionId"] == session["id"] &&
                          r["status"] == "CREATED",
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 20),
                      child: InkWell(
                        onTap: () => _onSessionTap(session, isRunning, context),
                        child: SessionCard(
                          sessionsCompleted: session["sessionsCompleted"],
                          totalSessions: session["totalSessions"],
                          startTime: formatTimeTo12Hour(session["startTime"]),
                          endTime: formatTimeTo12Hour(session["endTime"]),
                          childName: capitalizeEachWord(session["childName"]),
                          title:
                              "Class at ${session["parentName"] ?? ""}'s House",
                          duration: "$duration session",
                          fee: "Rs. ${(session["price"]).toStringAsFixed(0)}",
                          days: formatDays(session["daysOfWeek"] ?? []),
                          isRunning: isRunning,
                          onCheckout: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SessionCheckOut(
                                  ruuningId:
                                      provider.runningSessions[index]["id"],
                                  parentId: "${session["parentId"]}",
                                  tutorId: "${session["tutorId"]}",
                                  sessionId: "${session["id"]}",
                                ),
                              ),
                            ).then((_) {
                              provider.getSessions(context);
                            });
                          },
                          time: ReverseTimer(
                            color: index == 0
                                ? AppTheme.white
                                : AppTheme.appColor,
                            startTime: session["startTime"],
                            endTime: session["endTime"],
                          ),
                          fromDate: session["month"],
                          isCompleted: false,
                          color: index == 0 ? AppTheme.primaryCOlor : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMonthlyProductivity(TutorDashBoardProvider provider) {
    String getFormattedRange() {
      if (provider.monthlyEarnings.isEmpty) return "-";

      final first = provider.monthlyEarnings.first.month.toString();
      final last = provider.monthlyEarnings.last.month.toString();

      String formatMonth(String monthString) {
        final parts = monthString.split(" ");
        if (parts.length == 2) {
          final month = parts[0].substring(0, 3);
          final year = parts[1].substring(2);
          return "$month $year";
        }
        return monthString;
      }

      return "${formatMonth(first)} to ${formatMonth(last)}";
    }

    return Row(
      children: [
        AppText.appText(
          "Monthly Productivity",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.appText(
            "( ${getFormattedRange()} )",
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w600,
            textColor: const Color(0xffB0B0B0),
          ),
        ),
      ],
    );
  }

  /// ---------------- REUSABLE SECTION HEADER ----------------
  Widget _sectionHeader({
    required String title,
    String? actionText,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.appText(title, fontSize: 16, fontWeight: FontWeight.w600),
        if (actionText != null && onTap != null)
          InkWell(
            onTap: onTap,
            child: AppText.appText(
              actionText,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              textColor: const Color(0xffA4B0BE),
            ),
          ),
      ],
    );
  }

  void _onSessionTap(
    Map<String, dynamic> session,
    isonTap,
    BuildContext context,
  ) {
    final provider = Provider.of<TutorDashBoardProvider>(
      this.context,
      listen: false,
    );
    print("show and $isonTap hh ${provider.runningSessions}");

    if (isonTap == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionUpdateScreen(
            isRunning: isonTap,
            runningId: provider.runningSessions.isEmpty
                ? ""
                : provider.runningSessions[0]["id"],
            name: "${session["parentName"]}",
            parentId: "${session["parentId"]}",
            tutorId: "${session["tutorId"]}",
            sessionId: "${session["id"]}",
          ),
        ),
      ).then((_) {
        if (mounted) provider.getSessions(this.context);
      });
    } else if (provider.runningSessions.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionUpdateScreen(
            runningId: provider.runningSessions.isEmpty
                ? ""
                : provider.runningSessions[0]["id"],
            isRunning: isonTap,
            name: "${session["parentName"]}",
            parentId: "${session["parentId"]}",
            tutorId: "${session["tutorId"]}",
            sessionId: "${session["id"]}",
          ),
        ),
      ).then((_) {
        if (mounted) provider.getSessions(this.context);
      });
    } else {
      AppToast.error(
        context: context,
        msg: "A session is already running at this time",
      );
    }
  }
}
