import 'package:flutter/material.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Custom%20widgets/ratings.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/base_image.dart';

class TutorReviews extends StatefulWidget {
  final bool isParentSide;
  final tutorRatingData;
  const TutorReviews({
    super.key,
    required this.isParentSide,
    this.tutorRatingData,
  });

  @override
  State<TutorReviews> createState() => _TutorReviewsState();
}

class _TutorReviewsState extends State<TutorReviews> {
  @override
  Widget build(BuildContext context) {
    print(" nfo4f4mf${widget.tutorRatingData}");
    return widget.tutorRatingData == null || widget.tutorRatingData.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Center(
                child: Text("No Reviews yet."),
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.tutorRatingData.length,
            itemBuilder: (context, index) {
              final data = widget.tutorRatingData[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1, color: AppTheme.primaryCOlor),
                        ),
                        child: data["parent"]["image"] == null ||
                                data["parent"]["image"]!.isEmpty
                            ? ClipOval(
                                child: Image.asset(
                                    "assets/images/parentProfile.jpeg"))
                            : data["parent"]["image"]!.startsWith('http')
                                ? ClipOval(
                                    child: Image.network(
                                      data["parent"]["image"]!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                            "assets/images/parentProfile.jpeg");
                                      },
                                    ),
                                  )
                                : ClipOval(
                                    child: Base64ImageWidget(
                                        base64String: data["parent"]["image"]!),
                                  )),
                  ),
                  SizedBox(
                    width: 15,
                  ),
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
                                  "${data["parent"]["fullName"]}",
                                  fontSize: 18,
                                  maxlines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            RatingStars(
                                color: Colors.amber,
                                rating: double.tryParse(
                                        data!["rating"].toString()) ??
                                    0.0),
                          ],
                        ),
                        AppText.appText("${data["review"]}",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            textColor: Color(0xff3E3E3E)),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }
}
