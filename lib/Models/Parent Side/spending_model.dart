class MonthlySpending {
  final String month;
  final int spending;
  final int transactionCount;
  final int childrenCount;

  MonthlySpending({
    required this.month,
    required this.spending,
    required this.transactionCount,
    required this.childrenCount,
  });

  factory MonthlySpending.fromJson(Map<String, dynamic> json) {
    return MonthlySpending(
      month: json["month"] ?? "",
      spending: json["spending"] ?? 0,
      transactionCount: json["transactionCount"] ?? 0,
      childrenCount: json["childrenCount"] ?? 0,
    );
  }
}
