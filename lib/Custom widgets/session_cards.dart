import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String? childName;
  final String fee;
  final Widget time;
  final String? days;
  final String? toDate;
  final String? fromDate;
  final String? duration;
  final String? rating;
  final String? startTime;
  final String? endTime;
  final bool isCompleted;
  final bool isParentSide;
  final bool isRunning;
  final int? totalSessions;
  final int? sessionsCompleted;
  final Color? color;
  final VoidCallback? onCheckout;

  const SessionCard({
    super.key,
    required this.title,
    required this.fee,
    required this.time,
    required this.isCompleted,
    this.days,
    this.toDate,
    this.fromDate,
    this.duration,
    this.rating,
    this.color,
    this.isRunning = false,
    this.onCheckout,
    this.startTime,
    this.endTime,
    this.isParentSide = false,
    this.childName,
    this.totalSessions,
    this.sessionsCompleted,
  });

  Color get _textColor {
    if (isCompleted) return AppTheme.lableText;
    if (color != null) return AppTheme.white;
    return AppTheme.black;
  }

  Color get _subTextColor {
    return color != null ? AppTheme.white : AppTheme.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Container(
        width: 185,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.white : (color ?? Colors.white),
          border: Border.all(
            color: isCompleted ? AppTheme.appColor : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRunning == false && isCompleted == false) SizedBox(height: 8),
            if (isRunning == true && isCompleted == false)
              Align(
                alignment: AlignmentGeometry.topRight,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.appColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            _buildTitle(),
            const SizedBox(height: 5),
            Row(
              children: [
                AppText.appText(
                  "Child Name:",
                  textColor: _textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: AppText.appText(
                    "$childName",
                    maxlines: 1,
                    overflow: TextOverflow.ellipsis,
                    textColor: _textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (!isCompleted) const SizedBox(height: 5),
            isCompleted ? _buildCompletedInfo() : _buildOngoingInfo(),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: AppText.appText(
                    "Remaining:  ",
                    overflow: TextOverflow.ellipsis,
                    textColor: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppText.appText(
                  "${totalSessions! - sessionsCompleted!}",
                  textColor: _textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    Flexible(
                      child: AppText.appText(
                        "Completed:  ",
                        overflow: TextOverflow.ellipsis,
                        textColor: _textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppText.appText(
                      "${sessionsCompleted!}",
                      textColor: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            if (!isCompleted) const SizedBox(height: 10),
            if (!isCompleted && days != null) _buildDays(),
            if (!isCompleted) const SizedBox(height: 10),
            if (!isCompleted) _dotRow(fee, textColor: _subTextColor),
            if (isCompleted) _dotRow(fee, textColor: AppTheme.white),
            if (!isCompleted) const SizedBox(height: 15),
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          child: AppText.appText(
            title,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            textColor: _textColor,
            maxlines: isCompleted ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedInfo() {
    return SizedBox();
  }

  Widget _buildOngoingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (duration != null)
          Row(
            children: [
              AppText.appText(
                "Duration:  ",
                textColor: _textColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              Expanded(
                child: AppText.appText(
                  duration!,
                  maxlines: 1,
                  overflow: TextOverflow.ellipsis,
                  textColor: _subTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDays() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppText.appText(
          "Days:   ",
          textColor: _textColor,
          overflow: TextOverflow.ellipsis,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        Expanded(
          child: AppText.appText(
            days!,
            textColor: _subTextColor,
            maxlines: 1,
            overflow: TextOverflow.ellipsis,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    if (isRunning) {
      return Center(
        child: AppText.appText(
          "Session in Progress",
          textColor: _textColor,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.appText(
          "Start Time:",
          textColor: _textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),

        AppText.appText(
          "$startTime",
          textColor: _textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ],
    );
  }

  Widget _dotRow(String value, {Color? textColor}) {
    return Row(
      children: [
        _dot(color: textColor),
        const SizedBox(width: 5),
        Expanded(
          child: AppText.appText(
            value,
            maxlines: 1,
            overflow: TextOverflow.ellipsis,
            textColor: textColor ?? _textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _dot({Color? color}) {
    return Image.asset(
      "assets/images/dot.png",
      height: 8,
      color: color ?? _subTextColor,
    );
  }
}
