import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/base_image.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/subjets_format.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Parent%20Side/get_tutors_provider.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/tutor_profile.dart';

class TutorCategoriesScreen extends StatefulWidget {
  final String categoryName;
  const TutorCategoriesScreen({super.key, required this.categoryName});

  @override
  State<TutorCategoriesScreen> createState() => _TutorCategoriesScreenState();
}

class _TutorCategoriesScreenState extends State<TutorCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<GetTutorsProvider>(
        context,
        listen: false,
      ).fetchTutors(subject: widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              CustomAppBar1(title: "${widget.categoryName} Tutors"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Consumer<GetTutorsProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) return GifLoader();

                      if (provider.tutors.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text("No tutors found.")),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.95,
                            ),
                        itemCount: provider.tutors.length,
                        itemBuilder: (context, index) {
                          final tutor = provider.tutors[index];

                          return InkWell(
                            onTap: () {
                              push(
                                context,
                                TutorProfileScreen(
                                  isParentSide: true,
                                  name: "${tutor.firstName} ${tutor.lastName}",
                                  tutorId: tutor.tutorId,
                                  experience: tutor.experience,
                                ),
                              );
                            },
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    Colors.grey.shade200, // fallback background
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // ✅ Image handling
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
                                                    "assets/images/tutorProfile.jpeg",
                                                  );
                                                },
                                          )
                                        : Base64ImageWidget(
                                            base64String: tutor.image,
                                          ),

                                    // ✅ Overlay always visible
                                    _buildTutorCardOverlay(tutor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
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
              AppText.appText(
                "${tutor.rating}",
                fontSize: 10,
                fontWeight: FontWeight.w400,
                textColor: AppTheme.black,
              ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText(
                    "${tutor.firstName} ${tutor.lastName}",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textColor: Colors.white,
                  ),
                  AppText.appText(
                    formatSubjects(tutor.subjects),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    textColor: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
