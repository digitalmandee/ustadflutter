import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Dashboard/dashboard.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Profile/parent_profile.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Sessions/parent_session.dart';
import 'package:ustaad/Screens/Chats/chat.dart';
import 'package:ustaad/Screens/Teacher%20Screens/HomeScreen/dash_board.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Profile/tutor_profile.dart';
import 'package:ustaad/Screens/Teacher%20Screens/Sessions/tutor_session.dart';

class BottomNavView extends StatefulWidget {
  final bool tutor;
  final int index;

  const BottomNavView({
    super.key,
    required this.tutor,
    this.index = 0,
  });

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  int _currentIndex = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
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
                      setState(() => _currentIndex = index);
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
        size.width, size.height, size.width - borderRadius, size.height);

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
