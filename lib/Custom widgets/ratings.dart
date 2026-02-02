import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star_outlined,
              color: color ?? AppTheme.primaryCOlor, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half,
              color: AppTheme.primaryCOlor, size: size);
        } else {
          return Icon(Icons.star_outlined,
              color: Color(0xffECEEF3), size: size);
        }
      }),
    );
  }
}
