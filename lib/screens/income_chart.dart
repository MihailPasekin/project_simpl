import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IncomeLineChart extends StatelessWidget {
  const IncomeLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.white.withOpacity(
            0.1,
          ), // 🔹 полупрозрачный фон
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${value ~/ 1000}k",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text(
                        "Янв",
                        style: TextStyle(color: Colors.white),
                      );
                    case 1:
                      return const Text(
                        "Фев",
                        style: TextStyle(color: Colors.white),
                      );
                    case 2:
                      return const Text(
                        "Мар",
                        style: TextStyle(color: Colors.white),
                      );
                    case 3:
                      return const Text(
                        "Апр",
                        style: TextStyle(color: Colors.white),
                      );
                  }
                  return const Text("");
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 10000,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 5000),
                FlSpot(1, 7000),
                FlSpot(2, 6500),
                FlSpot(3, 8500),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.blueAccent,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
