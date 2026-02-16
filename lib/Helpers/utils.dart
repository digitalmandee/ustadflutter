import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:another_flushbar/flushbar.dart';

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

void safePop(BuildContext context) {
  if (!Navigator.canPop(context)) return;

  Future.delayed(Duration.zero, () {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  });
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

class AppToast {
  /// 🔹 Success Toast
  static void success({
    required BuildContext context,
    required String msg,
  }) {
    _show(
      context: context,
      msg: msg,
      indicatorColor: AppTheme.appColor,
      icon: Icons.check_circle,
      iconColor: AppTheme.appColor,
    );
  }

  /// 🔹 Error Toast
  static void error({
    required BuildContext context,
    required String msg,
  }) {
    _show(
      context: context,
      msg: msg,
      indicatorColor: Colors.red,
      icon: Icons.error,
      iconColor: Colors.red,
    );
  }

  /// 🔹 Internal Common Method
  static void _show({
    required BuildContext context,
    required String msg,
    required Color indicatorColor,
    required IconData icon,
    required Color iconColor,
  }) {
    if (!context.mounted) return;

    // Prevent stacking multiple toasts
    // Flushbar.dismissAll(context);

    Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(14),
      leftBarIndicatorColor: indicatorColor,
      backgroundColor: Colors.white,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      messageText: Row(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ).show(context);
  }
}
