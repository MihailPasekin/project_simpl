import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphWithCircles extends StatelessWidget {
  const GraphWithCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.redAccent,
              title: "Жильё\n40%",
              radius: 70,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              value: 25,
              color: Colors.green,
              title: "Еда\n25%",
              radius: 70,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              value: 20,
              color: Colors.blue,
              title: "Транспорт\n20%",
              radius: 70,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              value: 15,
              color: Colors.orange,
              title: "Развлечения\n15%",
              radius: 70,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
