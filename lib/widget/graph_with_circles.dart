import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PremiumPieChart extends StatefulWidget {
  const PremiumPieChart({super.key});

  @override
  State<PremiumPieChart> createState() => _PremiumPieChartState();
}

class _PremiumPieChartState extends State<PremiumPieChart>
    with SingleTickerProviderStateMixin {
  final List<double> targetValues = [40, 25, 20, 15, 15];
  final List<String> titles = [
    "Жильё",
    "Еда",
    "Транспорт",
    "Развлечения",
    "Другое",
  ];
  final List<List<Color>> gradients = [
    [Colors.redAccent.shade200, Colors.redAccent.shade700],
    [Colors.green.shade300, Colors.green.shade800],
    [Colors.blue.shade300, Colors.blue.shade700],
    [Colors.orange.shade300, Colors.orange.shade700],
    [Colors.purple.shade300, Colors.purple.shade700],
  ];

  List<double> animatedValues = [0, 0, 0, 0, 0];
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

    _animateSections();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Поочерёдная анимация секций
  void _animateSections() async {
    for (int i = 0; i < targetValues.length; i++) {
      for (double val = 0; val <= targetValues[i]; val += 1) {
        await Future.delayed(const Duration(milliseconds: 8));
        setState(() {
          animatedValues[i] = val;
        });
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  List<PieChartSectionData> getSections() {
    return List.generate(animatedValues.length, (i) {
      bool isTouched = i == touchedIndex;
      double radius =
          (isTouched ? 90 : 70) + (isTouched ? _pulseController.value * 10 : 0);
      return PieChartSectionData(
        value: animatedValues[i],
        title: "${titles[i]}\n${animatedValues[i].toInt()}%",
        radius: radius,
        showTitle: true,
        gradient: LinearGradient(
          colors: gradients[i],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
    return SizedBox(
      height: 270,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 4,
              sections: getSections(),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (response != null && response.touchedSection != null) {
                      touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    } else {
                      touchedIndex = -1;
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
