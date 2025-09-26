import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/models/graphItem.dart';

class PremiumPieChart extends ConsumerStatefulWidget {
  const PremiumPieChart({super.key});

  @override
  ConsumerState<PremiumPieChart> createState() => _PremiumPieChartState();
}

class _PremiumPieChartState extends ConsumerState<PremiumPieChart>
    with SingleTickerProviderStateMixin {
  List<double> animatedValues = [];
  int touchedIndex = -1;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<PieChartSectionData> getSections(List<GraphItem> data) {
    return List.generate(data.length, (i) {
      bool isTouched = i == touchedIndex;
      double radius =
          (isTouched ? 90 : 70) + (isTouched ? _pulseController.value * 10 : 0);

      return PieChartSectionData(
        value: animatedValues.isNotEmpty && i < animatedValues.length
            ? animatedValues[i]
            : 0,
        title:
            "${data[i].title}\n${(animatedValues.isNotEmpty && i < animatedValues.length ? animatedValues[i].toInt() : 0)}€",
        radius: radius,
        showTitle: true,
        color: data[i].color,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(expensesProvider);

    if (data.isEmpty) {
      return const SizedBox(
        height: 270,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 270,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 50,
          sectionsSpace: 4,
          sections: List.generate(data.length, (i) {
            bool isTouched = i == touchedIndex;
            double radius = isTouched ? 90 : 70;

            return PieChartSectionData(
              value: data[i].value,
              title: "${data[i].title}\n${data[i].value.toInt()}€",
              radius: radius,
              showTitle: true,
              color: data[i].color,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (response != null && response.touchedSection != null) {
                  touchedIndex = response.touchedSection!.touchedSectionIndex;
                } else {
                  touchedIndex = -1;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
