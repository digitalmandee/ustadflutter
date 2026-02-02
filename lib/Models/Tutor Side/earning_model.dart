class MonthlyEarning {
  final String month;
  final int earnings;
  final int count;

  MonthlyEarning({
    required this.month,
    required this.earnings,
    required this.count,
  });

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) {
    return MonthlyEarning(
      month: json['month'],
      earnings: (json['earnings'] as num).toInt(),
      count: json['count'],
    );
  }
}
