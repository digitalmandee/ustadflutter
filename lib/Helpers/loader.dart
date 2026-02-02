import 'dart:ui';

import 'package:flutter/material.dart';

class BlurGifLoader extends StatelessWidget {
  const BlurGifLoader({super.key, });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur Background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withValues(alpha: 0.2), // 👈 fixed
            ),
          ),
        ),
        // Center GIF
        Center(
          child: Image.asset(
            "assets/images/loaderGif.gif",
            width: 120,
            height: 120,
          ),
        ),
      ],
    );
  }
}

class GifLoader extends StatelessWidget {
  const GifLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/images/loaderGif.gif",
        width: 60,
        height: 60,
      ),
    );
  }
}
