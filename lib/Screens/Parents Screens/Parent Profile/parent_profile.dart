import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/base_image.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parent%20Profile/child_detail.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parent%20Profile/child_teacher_notes.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parent%20Profile/parents_reviews.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/Custom%20widgets/ratings.dart';

class ParentProfileScreen extends StatefulWidget {
  final bool isTutorSide;
  final String? parentId;
  const ParentProfileScreen({
    super.key,
    this.isTutorSide = false,
    this.parentId,
  });

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  int selectedTab = 0;
  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();

  String? name = "";
  String? userPic = "";
  String? userId = "";
  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    getUserData();
    final provider = Provider.of<ParentProfileProvider>(context, listen: false);
    provider.isTutorSide = widget.isTutorSide;
    if (widget.isTutorSide == false) {
      Future.microtask(() {
        Provider.of<ParentProfileProvider>(
          context,
          listen: false,
        ).fetchChildren(context);
        Provider.of<ParentProfileProvider>(
          context,
          listen: false,
        ).getParentProfile(context);
      });
    } else {
      Future.microtask(() {
        Provider.of<ParentProfileProvider>(
          context,
          listen: false,
        ).fetchParentProfileFromTutorSide(context, widget.parentId);
      });
    }
  }

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      String? firstName = pref.getString(PrefKey.userFirstName);
      String? lastName = pref.getString(PrefKey.userLastName);
      name = "${firstName!} ${lastName!}";
      userPic = pref.getString(PrefKey.userPic);
      userId = pref.getString(PrefKey.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabTitles = widget.isTutorSide == false
        ? ['Children', 'Tutor Notes', 'Reviews']
        : ["Children", 'Reviews'];
    final provider = Provider.of<ParentProfileProvider>(context);
    final List<Widget> tabContents = widget.isTutorSide == false
        ? [
            ChildDetails(userId: userId!, isTutorSide: widget.isTutorSide),
            ChildTeacherNotes(isTutorSide: widget.isTutorSide),
            ParentsReviews(
              isTutorSide: widget.isTutorSide,
              ratingData: provider.profileData?["reviews"],
            ),
          ]
        : [
            ChildDetails(userId: userId!, isTutorSide: widget.isTutorSide),
            ParentsReviews(
              isTutorSide: widget.isTutorSide,
              ratingData: provider.ratingData,
            ),
          ];
    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              Image.asset(
                "assets/images/Background.png",
                fit: BoxFit.fill,
                width: ScreenSize(context).width,
              ),
              Padding(
                padding: widget.isTutorSide == false
                    ? const EdgeInsets.only(
                        left: 20.0,
                        right: 20,
                        top: 40,
                        bottom: 65,
                      )
                    : const EdgeInsets.only(left: 20.0, right: 20, top: 40),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/ustaad.png",
                        height: 28,
                        width: 78,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
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
                                        border: Border.all(
                                          width: 2,
                                          color: AppTheme.primaryCOlor,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: widget.isTutorSide == false
                                              ? (userPic == "" ||
                                                        userPic == null)
                                                    ? ClipOval(
                                                        child: Image.asset(
                                                          "assets/images/parentProfile.jpeg",
                                                        ),
                                                      )
                                                    : userPic!.startsWith(
                                                        "http",
                                                      )
                                                    ? ClipOval(
                                                        child: Image.network(
                                                          userPic!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Image.asset(
                                                                  "assets/images/parentProfile.jpeg",
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : ClipOval(
                                                        child:
                                                            Base64ImageWidget(
                                                              base64String:
                                                                  userPic!,
                                                            ),
                                                      )
                                              : (provider.parentImage == "")
                                              ? ClipOval(
                                                  child: Image.asset(
                                                    "assets/images/parentProfile.jpeg",
                                                  ),
                                                )
                                              : (provider.parentImage
                                                        .startsWith("http") ||
                                                    provider.parentImage
                                                        .startsWith("https"))
                                              ? ClipOval(
                                                  child: Image.network(
                                                    provider.parentImage,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            "assets/images/parentProfile.jpeg",
                                                          );
                                                        },
                                                  ),
                                                )
                                              : ClipOval(
                                                  child: Base64ImageWidget(
                                                    base64String:
                                                        provider.parentImage,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: AppText.appText(
                                              widget.isTutorSide == false
                                                  ? capitalizeEachWord(name!)
                                                  : capitalizeEachWord(
                                                      "${provider.fName} ${provider.lName}",
                                                    ),
                                              fontSize: 30,
                                              maxlines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w500,
                                              textColor: AppTheme.black,
                                            ),
                                          ),
                                          if (provider.isVerified == true)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child: Icon(
                                                Icons.verified,
                                                color: AppTheme.appColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                      AppText.appText(
                                        "${provider.children.length} children profiles",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        textColor: AppTheme.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RatingStars(
                                        rating: widget.isTutorSide == true
                                            ? double.tryParse(
                                                    provider.averageRating
                                                        .toString(),
                                                  ) ??
                                                  0.0
                                            : double.tryParse(
                                                    (provider.profileData?["reviewStats"]["averageRating"] ??
                                                            "")
                                                        .toString(),
                                                  ) ??
                                                  0.0,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          AppText.appText(
                                            widget.isTutorSide == true
                                                ? provider.averageRating
                                                : (provider.profileData?["reviewStats"]["averageRating"] ??
                                                          "0")
                                                      .toString(),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            textColor: const Color(0xff101219),
                                          ),
                                          const SizedBox(width: 5),
                                          AppText.appText(
                                            widget.isTutorSide == true
                                                ? "${provider.totalReviews} Reviews"
                                                : "${(provider.profileData?["reviewStats"]["totalReviews"] ?? "0").toString()} Reviews",
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

                            Padding(
                              padding: widget.isTutorSide == true
                                  ? const EdgeInsets.symmetric(horizontal: 30.0)
                                  : const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                              child: Container(
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
                                  child: Row(
                                    children: List.generate(tabTitles.length, (
                                      index,
                                    ) {
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedTab = index;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selectedTab == index
                                                  ? AppTheme.appColor
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              tabTitles[index],
                                              style: TextStyle(
                                                color: selectedTab == index
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            tabContents[selectedTab],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.isTutorSide == true && provider.parentProfileLoader)
          BlurGifLoader(),
      ],
    );
  }
}
