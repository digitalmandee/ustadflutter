import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/base_image.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:flutterustad/Screens/Drawer/Setting/setting_screen.dart';
import 'package:flutterustad/Screens/Notifications/notification_screen.dart';
import 'package:flutterustad/config/keys/global.dart';

class CircleIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color borderColor;
  final Color? iconColor;
  final double size;
  final EdgeInsets padding;

  const CircleIconButton({
    super.key,
    required this.assetPath,
    this.onTap,
    this.backgroundColor,
    this.borderColor = Colors.transparent,
    this.size = 32,
    this.padding = const EdgeInsets.all(5.0),
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: padding,
          child: Image.asset(assetPath, color: iconColor),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final double size;

  const ProfileAvatar({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorEditProfileProvider>(
      builder: (context, profileProvider, child) {
        String displayImage;

        if (profileProvider.image.isNotEmpty) {
          displayImage = profileProvider.image;
        } else if (globalUserPic != null && globalUserPic!.isNotEmpty) {
          displayImage = globalUserPic!;
        } else {
          displayImage = '';
        }

        return Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: AppTheme.primaryCOlor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: InkWell(
              onTap: () {
                push(context, SettingScreen());
              },
              child: Container(
                height: size,
                width: size,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: profileProvider.picLoading
                    ? GifLoader()
                    : displayImage.isEmpty
                    ? ClipOval(
                        child: Image.asset(
                          globalUserRole == 'TUTOR'
                              ? 'assets/images/tutorProfile.jpeg'
                              : "assets/images/parentProfile.jpeg",
                        ),
                      )
                    : displayImage.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          displayImage,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                globalUserRole == 'TUTOR'
                                    ? 'assets/images/tutorProfile.jpeg'
                                    : "assets/images/parentProfile.jpeg",
                              ),
                        ),
                      )
                    : ClipOval(
                        child: Base64ImageWidget(base64String: displayImage),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final String? taskSummary;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final bool backArrow;
  final bool menuIcon;
  final String? count;
  const CustomAppBar({
    super.key,
    this.username = "Usama Shoaib",
    this.taskSummary,
    this.onMenuTap,
    this.onNotificationTap,
    this.backArrow = false,
    this.menuIcon = true,
    this.count,
  });

  @override
  Size get preferredSize => Size.fromHeight(backArrow ? 125 : 120);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          children: [
            backArrow
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/images/arrowBack.png",
                        height: 28,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/ustaad.png",
                      width: 76,
                      height: 28,
                    ),
                  ),
            if (backArrow) const SizedBox(height: 5),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const ProfileAvatar(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.appText(
                              globalUserFirstName == null
                                  ? "Usama Shoaib"
                                  : capitalizeEachWord(
                                      "$globalUserFirstName $globalUserLastName",
                                    ),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              maxlines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppText.appText(
                              "$taskSummary tasks for Today",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              textColor: AppTheme.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        push(context, NotificationScreen());
                      },
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Stack(
                          children: [
                            if (globalNotiCount != "0")
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            CircleIconButton(
                              assetPath: "assets/images/notify.png",
                              borderColor: AppTheme.primaryCOlor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    if (menuIcon == true)
                      CircleIconButton(
                        assetPath: "assets/images/menu.png",
                        onTap: onMenuTap,
                        backgroundColor: AppTheme.primaryCOlor,
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar1 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backArrow;
  final bool isDel;
  final VoidCallback? onDeletePressed;

  const CustomAppBar1({
    super.key,
    this.title = "",
    this.backArrow = true,
    this.isDel = false,
    this.onDeletePressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(backArrow ? 88 : 100);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40),
      child: Column(
        children: [
          Image.asset("assets/images/ustaad.png", height: 28, width: 78),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (backArrow == true)
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.pop(context),
                  child: Image.asset("assets/images/arrowBack.png", height: 30),
                ),
              AppText.appText(title, fontSize: 20, fontWeight: FontWeight.w700),
              isDel == true
                  ? InkWell(
                      onTap: onDeletePressed,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(),
                        child: Image.asset(
                          "assets/images/del.png",
                          color: Colors.red,
                        ),
                      ),
                    )
                  : SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
