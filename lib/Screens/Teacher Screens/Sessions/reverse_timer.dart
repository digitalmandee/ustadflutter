import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/app_theme.dart';

class ReverseTimer extends StatefulWidget {
  final String startTime;
  final String endTime;
  final Color? color;

  const ReverseTimer({
    super.key,
    required this.startTime,
    required this.endTime,
    this.color,
  });

  @override
  State<ReverseTimer> createState() => _ReverseTimerState();
}

class _ReverseTimerState extends State<ReverseTimer> {
  late Duration remaining;
  Timer? timer;
  late DateTime start;
  late DateTime end;

  @override
  void initState() {
    super.initState();
    start = _parseTime(widget.startTime);
    end = _parseTime(widget.endTime);

    _calculateRemaining();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(_calculateRemaining);
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();

    if (now.isBefore(start)) {
      // Class abhi start nahi hui
      remaining = start.difference(now);
    } else if (now.isAfter(end)) {
      // Class khatam ho gayi
      remaining = Duration(days: -1);
    } else {
      // Class chal rahi hai -> next session show karna
      remaining = Duration(days: -2);
    }
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(":").map(int.parse).toList();
    return DateTime(now.year, now.month, now.day, parts[0], parts[1], parts[2]);
  }

  String formatDuration(Duration d, DateTime now) {
    if (d.inDays == -1 || d.inDays == -2) {
      return "Next Session: Tomorrow";
    }

    // Class start hone ka wait (normal countdown)
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));

    return "${h}h:${m}m:${s}s";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final text = formatDuration(remaining, now);

    return Text(
      text,
      style: TextStyle(
        color: widget.color ?? AppTheme.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }
}


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ustaad/Helpers/app_theme.dart';

// class ReverseTimer extends StatefulWidget {
//   final String startTime; // e.g. "18:00:00"
//   final String endTime;   // e.g. "19:30:00"
//   final Color? color;

//   const ReverseTimer({
//     super.key,
//     required this.startTime,
//     required this.endTime,
//     this.color,
//   });

//   @override
//   State<ReverseTimer> createState() => _ReverseTimerState();
// }

// class _ReverseTimerState extends State<ReverseTimer> {
//   Timer? timer;
//   late Duration remaining;
//   late Duration sessionDuration;
//   late DateTime adjustedEndTime;

//   @override
//   void initState() {
//     super.initState();
//     _setupTimer();
//   }

//   void _setupTimer() {
//     // Parse start & end times
//     final now = DateTime.now();
//     final start = DateFormat("HH:mm:ss").parse(widget.startTime);
//     final end = DateFormat("HH:mm:ss").parse(widget.endTime);

//     // Calculate original session duration
//     sessionDuration = end.difference(start);

//     // Adjusted end = now + duration (user started now)
//     adjustedEndTime = now.add(sessionDuration);

//     // Initial remaining time
//     _updateRemaining();

//     // Update every second
//     timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       setState(_updateRemaining);
//     });
//   }

//   void _updateRemaining() {
//     final now = DateTime.now();
//     final diff = adjustedEndTime.difference(now);
//     remaining = diff.isNegative ? Duration.zero : diff;
//   }

//   String _format(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     final h = twoDigits(d.inHours);
//     final m = twoDigits(d.inMinutes.remainder(60));
//     final s = twoDigits(d.inSeconds.remainder(60));
//     return "${h}h:${m}m:${s}s";
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       _format(remaining),
//       style: TextStyle(
//         color: widget.color ?? AppTheme.white,
//         fontWeight: FontWeight.w600,
//         fontSize: 18,
//       ),
//     );
//   }
// }
