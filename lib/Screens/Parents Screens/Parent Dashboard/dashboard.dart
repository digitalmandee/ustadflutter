import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom widgets/app_field.dart';
import 'package:ustaad/Custom widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Custom widgets/chart.dart';
import 'package:ustaad/Helpers/base_image.dart';
import 'package:ustaad/Helpers/get_location.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/subjets_format.dart';
import 'package:ustaad/Models/Tutor Side/subjects_model.dart';
import 'package:ustaad/Providers/Parent Side/dashboard_provider.dart';
import 'package:ustaad/Providers/Parent Side/get_tutors_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Drawer/drawer.dart';
import 'package:ustaad/Screens/Parents Screens/Categories Tutor/category_tutor.dart';
import 'package:ustaad/Screens/Parents Screens/Categories Tutor/subject_categories.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Dashboard/search_screeen.dart';
import 'package:ustaad/Screens/Teacher Screens/Profile/tutor_profile.dart';
import 'package:ustaad/Custom widgets/app_bar.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/keys/global.dart';

class ParentsDashBoardScreen extends StatefulWidget {
  const ParentsDashBoardScreen({super.key});

  @override
  State<ParentsDashBoardScreen> createState() => _ParentsDashBoardScreenState();
}

class _ParentsDashBoardScreenState extends State<ParentsDashBoardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SubjectsModel> subjects = [];
  AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    logger.init();
    Future.microtask(() async {
      final position = await getCurrentLocation();
      globalParentLatitutde = position!.latitude;
      globalParentLongitude = position.longitude;
      if (mounted) {
        Provider.of<ParentProfileProvider>(context, listen: false)
            .getParentProfile(context);
      }
      if (mounted) {
        Provider.of<GetTutorsProvider>(context, listen: false).fetchTutors(
            latitude: position.latitude, longitude: position.longitude);
      }
      if (mounted) {
        Provider.of<ParentDashboardProvider>(context, listen: false)
            .getMonthlySpending(context);
      }
    });
    loadSubjects();
  }

  void _hitNearbyTutorApi() {
    if (!mounted) return;

    Provider.of<GetTutorsProvider>(context, listen: false).fetchTutors(
      latitude: globalParentLatitutde,
      longitude: globalParentLongitude,
    );
  }

  Future<void> loadSubjects() async {
    final String response = await rootBundle.loadString('assets/subjects.json');
    final List data = json.decode(response);

    setState(() {
      subjects = data.map((e) => SubjectsModel.fromJson(e)).toList();
    });
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
        taskSummary: provider.tasks,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 90, // ✅ MUST
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildHeader(context),
            _buildFeaturedSubjects(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: AppText.appText("Trending Tutors in Your Area",
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                _buildTrendingTutors(),
              ],
            ),
            _buildMonthlySpendingChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ).then((_) {
                _hitNearbyTutorApi();
              });
            },
            child: AbsorbPointer(
              child: parentHomeSearchField(context, _searchController,
                  hintText: "Explore Tutors"),
            ),
          ),
          const SizedBox(height: 20),
          // Text.rich(
          //   TextSpan(
          //     text: 'Next Payment of ',
          //     style: const TextStyle(
          //       fontSize: 16,
          //       color: Color(0xff15112E),
          //       fontWeight: FontWeight.w400,
          //     ),
          //     children: [
          //       TextSpan(
          //         text: 'Rs. 25000',
          //         style: TextStyle(
          //           color: AppTheme.appColor,
          //           fontWeight: FontWeight.w600,
          //           fontSize: 16,
          //           decorationColor: AppTheme.appColor,
          //           decoration: TextDecoration.underline,
          //         ),
          //       ),
          //       const TextSpan(text: ' due on 01-Mar-25 '),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.appText("Subject Categories",
                  fontSize: 16, fontWeight: FontWeight.w600),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            SubjectCategoriesScreen(data: subjects)),
                  ).then((_) {
                    _hitNearbyTutorApi();
                  });
                },
                child: AppText.appText("View All",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    textColor: const Color(0xffA4B0BE)),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFeaturedSubjects() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length > 5 ? 6 : subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 20),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          TutorCategoriesScreen(categoryName: subject.name)),
                ).then((_) {
                  _hitNearbyTutorApi();
                });
              },
              child: SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryCOlor)),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(subject.logo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: AppText.appText(subject.name,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          textColor: AppTheme.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingTutors() {
    return Consumer<GetTutorsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return GifLoader();

        if (provider.tutors.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No tutors found nearby."),
          );
        }

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.tutors.length,
            itemBuilder: (context, index) {
              final tutor = provider.tutors[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TutorProfileScreen(
                              isParentSide: true,
                              name: "${tutor.firstName} ${tutor.lastName}",
                              tutorId: tutor.tutorId,
                              experience: tutor.experience)),
                    ).then((_) {
                      _hitNearbyTutorApi();
                    });
                  },
                  child: Container(
                    height: 150,
                    width: 142,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          tutor.image.isEmpty
                              ? Image.asset(
                                  "assets/images/tutorProfile.jpeg",
                                  fit: BoxFit.cover,
                                )
                              : tutor.image.startsWith("http")
                                  ? Image.network(
                                      tutor.image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                            "assets/images/tutorProfile.jpeg");
                                      },
                                    )
                                  : Base64ImageWidget(
                                      base64String: tutor.image),
                          _buildTutorCardOverlay(tutor),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTutorCardOverlay(dynamic tutor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 5),
              AppText.appText("${tutor.rating}",
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  textColor: AppTheme.black),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText("${tutor.firstName} ${tutor.lastName}",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      textColor: Colors.white),
                  AppText.appText(formatSubjects(tutor.subjects),
                      fontSize: 10,
                      maxlines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w400,
                      textColor: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySpendingChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.appText("Monthly Spending",
                  fontSize: 16, fontWeight: FontWeight.w600),
              const SizedBox(width: 10),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final provider =
                        Provider.of<ParentDashboardProvider>(context);

                    if (provider.monthlySpending.isEmpty) {
                      return AppText.appText(
                        "-",
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                        textColor: const Color(0xffB0B0B0),
                      );
                    }

                    final firstMonth =
                        provider.monthlySpending.first.month.toString();
                    final lastMonth =
                        provider.monthlySpending.last.month.toString();

                    String formatMonth(String monthString) {
                      final parts = monthString.split(" ");
                      if (parts.length == 2) {
                        final month = parts[0].substring(0, 3);
                        final year = parts[1].substring(2);
                        return "$month $year";
                      }
                      return monthString;
                    }

                    final formattedRange =
                        "${formatMonth(firstMonth)} to ${formatMonth(lastMonth)}";

                    return AppText.appText(
                      "( $formattedRange )",
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w600,
                      textColor: const Color(0xffB0B0B0),
                    );
                  },
                ),
              ),
            ],
          ),
          EarningsBarChart(isParent: true),
        ],
      ),
    );
  }
}
