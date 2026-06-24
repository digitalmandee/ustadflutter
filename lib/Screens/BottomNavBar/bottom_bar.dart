import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parent%20Dashboard/dashboard.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parent%20Profile/parent_profile.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parent%20Sessions/parent_session.dart';
import 'package:flutterustad/Screens/Chats/chat.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/HomeScreen/dash_board.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Profile/tutor_profile.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/Sessions/tutor_session.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/Helpers/guest_helper.dart';

class BottomNavView extends StatefulWidget {
  final bool tutor;
  final int index;
  final String? snackbarMessage;

  const BottomNavView({
    super.key,
    required this.tutor,
    this.index = 0,
    this.snackbarMessage,
  });

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  int _currentIndex = 0;
  bool _profileDialogShown = false;

  final List<String> _titles = ["Home", "Chat", "Sessions", "Profile"];
  final List<String> _icons = [
    "assets/images/dashBoard_icon.png",
    "assets/images/chatss.png",
    "assets/images/clock.png",
    "assets/images/profilenav.png",
  ];

  List<Widget> get _screens => widget.tutor
      ? const [
          TutorDashBoardScreen(),
          ChatScreen(),
          TutorSessionScreen(),
          TutorProfileScreen(isParentSide: false),
        ]
      : const [
          ParentsDashBoardScreen(),
          ChatScreen(),
          ParentSessionScreen(),
          ParentProfileScreen(),
        ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    if (widget.snackbarMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.snackbarMessage!)));
      });
    }
    if (widget.tutor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkTutorProfileCompletion();
      });
    }
  }

  Future<void> _checkTutorProfileCompletion() async {
    if (!mounted || _profileDialogShown) return;

    final educationProvider = context.read<EducationProvider>();
    final experienceProvider = context.read<ExperienceProvider>();

    await Future.wait([
      educationProvider.fetchEducation(context),
      experienceProvider.fetchExperiences(context),
    ]);

    if (!mounted || _profileDialogShown) return;

    final hasNoEducation = educationProvider.education.isEmpty;
    final hasNoExperience = experienceProvider.experiences.isEmpty;

    if (hasNoEducation || hasNoExperience) {
      _profileDialogShown = true;
      _showProfileIncompleteDialog();
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Profile Incomplete",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  "Kindly complete your profile to\nproceed further.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff0B2B66),
                    fontSize: 21,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (!mounted) return;
                      setState(() => _currentIndex = 3);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0D6EFD),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      "Open Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "I will do it later",
                    style: TextStyle(
                      color: AppTheme.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _screens[_currentIndex],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _customBottomNav(bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== CUSTOM NAV BAR =====================

  Widget _customBottomNav(double bottomInset) {
    return Container(
      color: Colors.transparent,
      height: 90 + bottomInset,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: const Size(double.infinity, 150),
            painter: CurvedNavPainter(
              selectedIndex: _currentIndex,
              itemCount: _titles.length,
              borderColor: AppTheme.appColor,
            ),
          ),
          Positioned.fill(
            child: Row(
              children: List.generate(_titles.length, (index) {
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isGuest && index != 0) {
                        showLoginRequiredDialog(context, _titles[index]);
                      } else {
                        setState(() => _currentIndex = index);
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(top: isSelected ? 11 : 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: isSelected ? 40 : 26,
                              width: isSelected ? 40 : 26,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryCOlor
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  _icons[index],
                                  height: 22,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _titles[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primaryCOlor
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== CUSTOM PAINTER =====================

class CurvedNavPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final Color borderColor;

  CurvedNavPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double borderRadius = 10; // radius for all corners

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final itemWidth = size.width / itemCount;
    final centerX = (selectedIndex * itemWidth) + itemWidth / 2;

    final double notchWidth = 75;
    final double notchHeight = 15;

    final path = Path();

    // Start from top-left corner
    path.moveTo(0, borderRadius + 26);
    path.quadraticBezierTo(0, 26, borderRadius, 26);

    // Notch start
    path.lineTo(centerX - notchWidth / 2, 26);

    // Notch curves
    path.cubicTo(
      centerX - notchWidth / 4,
      26,
      centerX - notchWidth / 4,
      26 - notchHeight,
      centerX,
      26 - notchHeight,
    );
    path.cubicTo(
      centerX + notchWidth / 4,
      26 - notchHeight,
      centerX + notchWidth / 4,
      26,
      centerX + notchWidth / 2,
      26,
    );

    // Top-right corner
    path.lineTo(size.width - borderRadius, 26);
    path.quadraticBezierTo(size.width, 26, size.width, borderRadius + 26);

    // Bottom-right corner
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - borderRadius,
      size.height,
    );

    // Bottom-left corner
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    // Close path back to start
    path.lineTo(0, borderRadius + 26);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
