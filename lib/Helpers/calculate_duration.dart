String calculateDuration(String startTime, String endTime) {
  try {
    final start = DateTime.parse("1970-01-01 $startTime");
    final end = DateTime.parse("1970-01-01 $endTime");
    final diff = end.difference(start);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) return "$hours hr $minutes min";
    if (hours > 0) return "$hours hr";
    return "$minutes min";
  } catch (_) {
    return "";
  }
}
