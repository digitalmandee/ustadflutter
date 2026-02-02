String formatSubjects(List<String> subjects) {
  if (subjects.isEmpty) return "No subjects";

  // Har subject ka pehla letter capital + baaki lower
  List<String> formatted = subjects.map((s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }).toList();

  if (formatted.length <= 2) {
    return formatted.join(", ");
  } else {
    final firstTwo = formatted.take(2).join(", ");
    final remaining = formatted.length - 2;
    return "$firstTwo +$remaining others";
  }
}
