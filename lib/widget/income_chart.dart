import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class IncomeEntry {
  final DateTime date;
  final double income;

  IncomeEntry(this.date, this.income);
}

class IncomeChart extends StatelessWidget {
  final List<IncomeEntry> incomeData;

  const IncomeChart({super.key, required this.incomeData});

  @override
  Widget build(BuildContext context) {
    if (incomeData.isEmpty) {
      return const Center(child: Text("No income data"));
    }

    // ✅ Один доход — fallback UI
    if (incomeData.length == 1) {
      final entry = incomeData.first;
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.blueGrey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              NumberFormat.currency(symbol: '\$').format(entry.income),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat("MMMM yyyy").format(entry.date),
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      );
    }

    // ✅ Несколько доходов — график
    final double maxIncome = incomeData
        .map((e) => e.income)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.blueGrey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income over Time',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: incomeData.length * 60.0,
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxIncome * 1.1,
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 ||
                              value.toInt() >= incomeData.length) {
                            return Container();
                          }
                          final date = incomeData[value.toInt()].date;
                          return Text(
                            DateFormat("MMM yyyy").format(date),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxIncome / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        incomeData.length,
                        (index) =>
                            FlSpot(index.toDouble(), incomeData[index].income),
                      ),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
