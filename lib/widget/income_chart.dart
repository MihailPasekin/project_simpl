import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class SimpleFancyMonthlyIncomeChart extends StatefulWidget {
  final List<String> months;
  final List<double> values;

  const SimpleFancyMonthlyIncomeChart({
    Key? key,
    required this.months,
    required this.values,
  }) : super(key: key);

  @override
  _SimpleFancyMonthlyIncomeChartState createState() =>
      _SimpleFancyMonthlyIncomeChartState();
}

class _SimpleFancyMonthlyIncomeChartState
    extends State<SimpleFancyMonthlyIncomeChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '€',
      decimalDigits: 0,
    );

    // Безопасные maxY и barWidth
    final maxY = widget.values.isNotEmpty
        ? (widget.values.reduce(max) * 1.2)
        : 10.0;

    final barWidth = widget.values.isNotEmpty
        ? max(12.0, 300.0 / widget.values.length * 0.6)
        : 12.0; // все числа с .0, чтобы они были double

    List<BarChartGroupData> barGroups = List.generate(widget.values.length, (
      i,
    ) {
      final value = widget.values[i];

      // Цвет по сравнению с предыдущим месяцем
      Color topColor;
      Color bottomColor;
      if (i == 0 || value >= widget.values[i - 1]) {
        topColor = Colors.green;
        bottomColor = Colors.greenAccent.shade200;
      } else {
        topColor = Colors.red;
        bottomColor = Colors.redAccent.shade200;
      }

      final gradient = LinearGradient(
        colors: [bottomColor, topColor],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value,
            width: barWidth,
            borderRadius: BorderRadius.circular(6),
            gradient: gradient,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });

    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: barGroups,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < widget.months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.months[index],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        currencyFormatter.format(value),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (response != null &&
                      response.spot != null &&
                      event.isInterestedForInteractions) {
                    setState(() {
                      touchedIndex = response.spot!.touchedBarGroupIndex;
                    });
                  } else {
                    setState(() {
                      touchedIndex = null;
                    });
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${widget.months[groupIndex]}: ${currencyFormatter.format(widget.values[groupIndex])}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 800),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
          // Стрелки роста/падения
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxHeight;
                final chartWidth = constraints.maxWidth;
                return Stack(
                  children: List.generate(widget.values.length, (i) {
                    final barX =
                        (i + 0.5) * (chartWidth / widget.values.length);
                    final value = widget.values[i];
                    Icon? icon;
                    if (i > 0) {
                      if (value > widget.values[i - 1]) {
                        icon = const Icon(
                          Icons.arrow_upward,
                          color: Colors.green,
                          size: 18,
                        );
                      } else if (value < widget.values[i - 1]) {
                        icon = const Icon(
                          Icons.arrow_downward,
                          color: Colors.red,
                          size: 18,
                        );
                      }
                    }
                    if (icon != null) {
                      return Positioned(
                        left: barX - 9,
                        top: chartHeight - (value / maxY) * chartHeight - 25,
                        child: icon,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
