import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64ImageWidget extends StatefulWidget {
  final String base64String;

  const Base64ImageWidget({
    super.key,
    required this.base64String,
  });

  @override
  State<Base64ImageWidget> createState() => _Base64ImageWidgetState();
}

class _Base64ImageWidgetState extends State<Base64ImageWidget> {
  late Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = _decode(widget.base64String);
  }

  @override
  void didUpdateWidget(covariant Base64ImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 👇 Sirf jab base64 string change ho
    if (oldWidget.base64String != widget.base64String) {
      _imageBytes = _decode(widget.base64String);
    }
  }

  Uint8List _decode(String base64) {
    final cleaned =
        base64.contains(',') ? base64.split(',').last : base64;
    return base64Decode(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      _imageBytes,
      fit: BoxFit.cover,
      gaplessPlayback: true, // ✅ removes flicker
    );
  }
}
