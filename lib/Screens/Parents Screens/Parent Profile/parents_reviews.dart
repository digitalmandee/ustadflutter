import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Custom%20widgets/ratings.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/base_image.dart';

class ParentsReviews extends StatefulWidget {
  final bool isTutorSide;
  final ratingData;

  const ParentsReviews({super.key, this.isTutorSide = false, this.ratingData});

  @override
  State<ParentsReviews> createState() => _ParentsReviewsState();
}

class _ParentsReviewsState extends State<ParentsReviews> {
  @override
  Widget build(BuildContext context) {
    return widget.ratingData == null || widget.ratingData.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Center(
                child: AppText.appText("No Reviews yet", fontSize: 16),
              ),
            ),
          )
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.ratingData.length,
            itemBuilder: (context, index) {
              final data = widget.ratingData[index];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                        color: AppTheme.primaryCOlor,
                      ),
                    ),
                    child:
                        data["tutor"]["image"] == null ||
                            data["tutor"]["image"]!.isEmpty
                        ? ClipOval(
                            child: Image.asset(
                              "assets/images/tutorProfile.jpeg",
                            ),
                          )
                        : data["tutor"]["image"]!.startsWith('http')
                        ? ClipOval(
                            child: Image.network(
                              data["tutor"]["image"]!,
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
                              base64String: data["tutor"]["image"]!,
                            ),
                          ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: AppText.appText(
                                "${data["tutor"]["fullName"]}",
                                fontSize: 18,
                                maxlines: 2,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            RatingStars(
                              rating: data["rating"].toDouble(),
                              color: Colors.amber,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        AppText.appText(
                          "${data["review"]}",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          textColor: Color(0xff3E3E3E),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }
}
