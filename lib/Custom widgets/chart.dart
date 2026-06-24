import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Models/Parent%20Side/spending_model.dart';
import 'package:flutterustad/Models/Tutor%20Side/earning_model.dart';
import 'package:flutterustad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:flutterustad/Providers/Parent%20Side/dashboard_provider.dart';

class EarningsBarChart extends StatelessWidget {
  final bool isParent;
  const EarningsBarChart({super.key, required this.isParent});

  @override
  Widget build(BuildContext context) {
    if (isParent) {
      final provider = Provider.of<ParentDashboardProvider>(context);
      if (provider.isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: GifLoader(),
        );
      }
      if (provider.monthlySpending.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text("No spending data available")),
        );
      }
      return buildChartForParent(provider.monthlySpending);
    } else {
      final provider = Provider.of<TutorDashBoardProvider>(context);
      if (provider.isLoading) {
        return const Padding(padding: EdgeInsets.all(20.0), child: GifLoader());
      }
      if (provider.monthlyEarnings.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text("No earnings data available")),
        );
      }
      return buildChartForTutor(provider.monthlyEarnings);
    }
  }

  Widget buildChartForParent(List<MonthlySpending> data) {
    return buildChart(
      title: "Spending (Rs)",
      data: data,
      getValue: (MonthlySpending e) => e.spending.toDouble(),
      getMonth: (MonthlySpending e) => e.month,
    );
  }

  Widget buildChartForTutor(List<MonthlyEarning> data) {
    return buildChart(
      title: "Earnings (Rs)",
      data: data,
      getValue: (MonthlyEarning e) => e.earnings.toDouble(),
      getMonth: (MonthlyEarning e) => e.month,
    );
  }

  Widget buildChart<T>({
    required String title,
    required List<T> data,
    required double Function(T) getValue,
    required String Function(T) getMonth,
  }) {
    final maxY = (data.isEmpty)
        ? 0
        : data.map(getValue).reduce((a, b) => a > b ? a : b);

    final safeMaxY = maxY == 0 ? 250000.0 : maxY;

    final interval = safeMaxY / 5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: safeMaxY + (interval),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) {
                              if (value == 0) return const Text("");
                              return Text(
                                "${(value ~/ 1000)}k",
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, _) {
                              if (value.toInt() < data.length) {
                                final month = getMonth(data[value.toInt()]);
                                final shortMonth = month.toString().substring(
                                  0,
                                  3,
                                );
                                return Text(
                                  shortMonth,
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text("");
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: data.asMap().entries.map((entry) {
                        final y = getValue(entry.value);
                        return makeGroupData(entry.key, y);
                      }).toList(),
                      gridData: FlGridData(
                        show: true,

                        // 🔹 Horizontal lines
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppTheme.dividerColor,
                            strokeWidth: 1,
                            dashArray: [5, 5], // optional
                          );
                        },

                        // 🔹 Vertical lines
                        drawVerticalLine: true,
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: AppTheme.dividerColor,
                            strokeWidth: 1,
                            dashArray: [5, 5], // optional
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 36.72,
          borderRadius: BorderRadius.circular(6),
          color: AppTheme.appColor,
        ),
      ],
    );
  }
}
