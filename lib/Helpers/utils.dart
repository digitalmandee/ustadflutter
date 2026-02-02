import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/app_theme.dart';

Route _zoomRoute(Widget screen) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

push(context, screen) {
  Navigator.push(context, _zoomRoute(screen));
}

pushReplacement(context, screen) {
  Navigator.pushReplacement(context, _zoomRoute(screen));
}

pushUntil(context, screen) {
  Navigator.pushAndRemoveUntil(context, _zoomRoute(screen), (route) => false);
}

pop(context) {
  Navigator.pop(context);
}

class ScreenSize {
  BuildContext context;

  ScreenSize(this.context);

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;
}

///////////////////////  Toaster /////////////////////////////////

enum ToastType { success, error }

class AppToast {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    try {
      if (_overlayEntry?.mounted ?? false) {
        _overlayEntry?.remove();
      }

      _overlayEntry = _createOverlay(context, message, type);

      final overlay = Overlay.of(context);
      // ignore: unnecessary_null_comparison
      if (overlay != null && _overlayEntry != null) {
        overlay.insert(_overlayEntry!);
      }
      Timer(duration, () {
        if (_overlayEntry?.mounted ?? false) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint("Failed to show toast: $e");
    }
  }

  static OverlayEntry _createOverlay(
      BuildContext context, String message, ToastType type) {
    return OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 16,
        right: 16,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.up,
          onDismissed: (_) {
            if (_overlayEntry?.mounted ?? false) {
              _overlayEntry?.remove();
              _overlayEntry = null;
            }
          },
          child: _ToastView(message: message, type: type),
        ),
      ),
    );
  }

  static void success({context, required String msg}) {
    show(context, message: msg, type: ToastType.success);
  }

  static void error({context, required String msg}) {
    show(context, message: msg, type: ToastType.error);
  }
}

class _ToastView extends StatefulWidget {
  final String message;
  final ToastType type;

  const _ToastView({required this.message, required this.type});

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == ToastType.success;

    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
                top: BorderSide(
                    color: isSuccess ? AppTheme.appColor : Colors.red,
                    width: 2)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? AppTheme.appColor : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
