import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/base_image.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/Helpers/guest_helper.dart';

import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Chat/all_chat_provider.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:flutterustad/Screens/Chats/single_chat_tutor.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/about/tutor_about.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/education/tutor_educ.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/experience/tutor_exp.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/tutor_reviews.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/urls.dart';
import 'package:flutterustad/Custom%20widgets/ratings.dart';

class TutorProfileScreen extends StatefulWidget {
  final bool isParentSide;
  final String? name;
  final String? tutorId;
  final double? experience;

  final bool isFromChat;

  const TutorProfileScreen({
    super.key,
    required this.isParentSide,
    this.name,
    this.tutorId,
    this.experience,
    this.isFromChat = false,
  });

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  final ValueNotifier<int> selectedTab = ValueNotifier(0);

  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  Map<String, dynamic>? tutorData;

  String? name = "";
  String? userPic = "";
  bool _profileCompletionChecked = false;

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    if (widget.isParentSide == false) {
      getUserData();
      if (widget.isParentSide == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AboutProvider>(
            context,
            listen: false,
          ).fetchAboutData(context);
          _loadProfileCompletionData();
        });
      }
    }
    if (widget.isParentSide == true) {
      getTutorProfileFromParentSide(context: context, tutorId: widget.tutorId);
    }
  }

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      String? firstName = pref.getString(PrefKey.userFirstName);
      String? lastName = pref.getString(PrefKey.userLastName);
      name = "${firstName!} ${lastName!}";
      userPic = pref.getString(PrefKey.userPic);
    });
  }

  Future<void> _loadProfileCompletionData() async {
    await Future.wait([
      Provider.of<EducationProvider>(
        context,
        listen: false,
      ).fetchEducation(context),
      Provider.of<ExperienceProvider>(
        context,
        listen: false,
      ).fetchExperiences(context),
    ]);

    if (!mounted) return;
    setState(() => _profileCompletionChecked = true);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabTitles = [
      'About',
      'Education',
      'Experience',
      'Reviews',
    ];
    final provider = Provider.of<AboutProvider>(context);
    final List reviewsList = widget.isParentSide == true
        ? (tutorData?["reviews"] ?? [])
        : (provider.profileData?["reviews"] ?? []);
    final bool showVerifiedBadge = widget.isParentSide == true
        ? tutorData == null
              ? false
              : tutorData!["isAdminVerified"] == true
        : provider.isVerified == true;
    final List<Widget> tabContents = [
      TutorAboutSection(isParentSide: widget.isParentSide, data: tutorData),
      TutorEducationScreen(isParentSide: widget.isParentSide, data: tutorData),
      TutorExperience(isParentSide: widget.isParentSide, data: tutorData),
      TutorReviews(
        isParentSide: widget.isParentSide,
        tutorRatingData: reviewsList,
      ),
    ];
    String formatExperienceFromMonths(int months) {
      final years = months / 12;

      if (years % 1 == 0) {
        // pura number hai
        return "${years.toInt()} years Experience";
      } else {
        // decimal hai
        return "${years.toStringAsFixed(1)} years Experience";
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/Background.png", // replace with your image path
            fit: BoxFit.fill,
            width: ScreenSize(context).width,
          ),
          Padding(
            padding: widget.isParentSide == true
                ? const EdgeInsets.only(left: 20.0, right: 20, top: 40)
                : const EdgeInsets.only(
                    left: 20.0,
                    right: 20,
                    top: 40,
                    bottom: 65,
                  ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/ustaad.png",
                    width: 76,
                    height: 28,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ProfileImageWidget(
                          isParentSide: widget.isParentSide,
                          isLoading: isLoading,
                          userPic: userPic,
                          tutorData: tutorData,
                        ),
                        if (widget.isParentSide == true &&
                            widget.isFromChat == false)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AppButton.appButton(
                              context: context,
                              "Contact",
                              height: 36.0,
                              onTap: () {
                                if (isGuest) {
                                  showLoginRequiredDialog(
                                    context,
                                    "Chat Tutor",
                                  );
                                } else {
                                  createConverstion(context);
                                }
                              },
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: AppText.appText(
                                          widget.isParentSide == true
                                              ? capitalizeEachWord(
                                                  "${widget.name}",
                                                )
                                              : capitalizeEachWord(name!),
                                          fontSize: 30,
                                          maxlines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w500,
                                          textColor: AppTheme.black,
                                        ),
                                      ),
                                      if (showVerifiedBadge)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4,
                                          ),
                                          child: Icon(
                                            Icons.verified,
                                            color: AppTheme.appColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Consumer<AboutProvider>(
                                    builder: (context, exp, child) {
                                      return AppText.appText(
                                        widget.isParentSide == true
                                            ? widget.isFromChat == true
                                                  ? tutorData == null
                                                        ? "0 years Experience"
                                                        : formatExperienceFromMonths(
                                                            tutorData!["totalExperienceMonths"],
                                                          )
                                                  : widget.experience == null
                                                  ? "0 years Experience"
                                                  : "${widget.experience} years Experience"
                                            : "${exp.totalExp} years Experience",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        textColor: AppTheme.grey,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RatingStars(
                                    rating: widget.isParentSide == true
                                        ? double.tryParse(
                                                (tutorData?["reviewStats"]?["averageRating"] ??
                                                        "")
                                                    .toString(),
                                              ) ??
                                              0.0
                                        : double.tryParse(
                                                (provider.profileData?["reviewStats"]?["averageRating"] ??
                                                        "")
                                                    .toString(),
                                              ) ??
                                              0.0,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      AppText.appText(
                                        widget.isParentSide == true
                                            ? "${tutorData?["reviewStats"]?["averageRating"]}"
                                            : "${provider.profileData?["reviewStats"]?["averageRating"]}",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        textColor: const Color(0xff101219),
                                      ),
                                      const SizedBox(width: 5),
                                      AppText.appText(
                                        widget.isParentSide == true
                                            ? "${tutorData?["reviewStats"]["totalReviews"]} Reviews"
                                            : "${provider.profileData?["reviewStats"]["totalReviews"]} Reviews",
                                        underLine: true,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        textColor: const Color(0xff4D5874),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (widget.isParentSide == false)
                          Consumer2<EducationProvider, ExperienceProvider>(
                            builder:
                                (
                                  context,
                                  educationProvider,
                                  experienceProvider,
                                  _,
                                ) {
                                  final hasNoEducation =
                                      educationProvider.education.isEmpty;
                                  final hasNoExperience =
                                      experienceProvider.experiences.isEmpty;

                                  if (!_profileCompletionChecked ||
                                      (!hasNoEducation && !hasNoExperience)) {
                                    return const SizedBox.shrink();
                                  }

                                  final missingItems = [
                                    if (hasNoEducation) "education",
                                    if (hasNoExperience) "experience",
                                  ].join(" and ");

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: _buildIncompleteProfileBanner(
                                      "Incomplete profile: add $missingItems.",
                                    ),
                                  );
                                },
                          ),
                        ValueListenableBuilder<int>(
                          valueListenable: selectedTab,
                          builder: (context, currentTab, _) {
                            return Column(
                              children: [
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                      vertical: 2.0,
                                    ),
                                    child: Consumer2<EducationProvider, ExperienceProvider>(
                                      builder:
                                          (
                                            context,
                                            educationProvider,
                                            experienceProvider,
                                            _,
                                          ) {
                                            return Row(
                                              children: List.generate(tabTitles.length, (
                                                index,
                                              ) {
                                                final showMissingDot =
                                                    widget.isParentSide ==
                                                        false &&
                                                    _profileCompletionChecked &&
                                                    ((index == 1 &&
                                                            educationProvider
                                                                .education
                                                                .isEmpty) ||
                                                        (index == 2 &&
                                                            experienceProvider
                                                                .experiences
                                                                .isEmpty));

                                                return Expanded(
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        selectedTab.value =
                                                            index,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            currentTab == index
                                                            ? AppTheme.appColor
                                                            : Colors
                                                                  .transparent,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              tabTitles[index],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color:
                                                                    currentTab ==
                                                                        index
                                                                    ? Colors
                                                                          .white
                                                                    : Colors
                                                                          .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                          if (showMissingDot) ...[
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Container(
                                                              height: 7,
                                                              width: 7,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                if (widget.isParentSide == false)
                                  const SizedBox(height: 20),
                                tabContents[currentTab],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteProfileBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffFDECEC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE53935)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xffE53935), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: AppText.appText(
              message,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              textColor: const Color(0xffC62828),
            ),
          ),
        ],
      ),
    );
  }

  void getTutorProfileFromParentSide({context, tutorId}) async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response = await dio.get(
        path: "${AppUrls.getTutorProfileFromParentSide}$tutorId",
      );
      var responseData = response.data;
      if (response.statusCode == 200) {
        setState(() {
          tutorData = responseData["data"]; // 👈 Save the tutor data
          isLoading = false;
        });

        AppToast.success(context: context, msg: "${responseData["message"]}");
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
        handleTokenExpiration();
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
      AppToast.error(context: context, msg: "Something went wrong$e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void createConverstion(context) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> params = {
      "name": "${widget.name}",
      "description": "New chat",
      "type": "DIRECT",
      "participantIds": ["${widget.tutorId}"],
      "isPrivate": true,
      "maxParticipants": 2,
    };
    try {
      Response response = await dio.postJson(
        path: AppUrls.createConversation,
        data: params,
      );
      var responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // AppToast.success(
        //     context: context, msg: "${responseData["message"]}");
        Provider.of<AllChatProvider>(
          context,
          listen: false,
        ).fetchChats(context);
        final conversationId = response.data["data"]["id"];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleChatScreen(
              conversationId: conversationId,
              userId: globalUserId!,
              recieverId: tutorData!["id"],
              image: tutorData!["image"] ?? "",
              recieverName:
                  "${tutorData!["firstName"]} ${tutorData!["lastName"]}",
            ),
          ),
        );

        setState(() {
          isLoading = false;
        });
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "Tokend") {
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
        pushUntil(context, LogInScreen());
      } else {
        setState(() {
          isLoading = false;
        });
        AppToast.error(
          context: context,
          msg: "sdsdd ${responseData["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong $e");
      setState(() {
        isLoading = false;
      });
    }
  }
}

class ProfileImageWidget extends StatelessWidget {
  final bool isParentSide;
  final bool isLoading;
  final String? userPic;
  final Map<String, dynamic>? tutorData;

  const ProfileImageWidget({
    super.key,
    required this.isParentSide,
    required this.isLoading,
    this.userPic,
    this.tutorData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      width: 130,
      child: Stack(
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 218, 231, 234),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: AppTheme.primaryCOlor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: isParentSide
                      ? isLoading
                            ? GifLoader()
                            : (tutorData == null || tutorData?["image"] == null)
                            ? ClipOval(
                                child: Image.asset(
                                  "assets/images/tutorProfile.jpeg",
                                ),
                              )
                            : tutorData!["image"].startsWith("http")
                            ? ClipOval(
                                child: Image.network(
                                  tutorData!["image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/tutorProfile.jpeg",
                                    );
                                  },
                                ),
                              )
                            : ClipOval(
                                child: Base64ImageWidget(
                                  base64String: tutorData?["image"],
                                ),
                              )
                      : (globalUserPic == "" || globalUserPic == null)
                      ? ClipOval(
                          child: Image.asset("assets/images/tutorProfile.jpeg"),
                        )
                      : globalUserPic!.startsWith("http")
                      ? ClipOval(
                          child: Image.network(
                            globalUserPic!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/tutorProfile.jpeg",
                              );
                            },
                          ),
                        )
                      : ClipOval(
                          child: Base64ImageWidget(
                            base64String: globalUserPic!,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
