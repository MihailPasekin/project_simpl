import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_simpl/screens/add_expense_screen.dart';
import 'package:project_simpl/screens/add_income_screen.dart';
import 'package:project_simpl/screens/income_chart.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 🔹 Баланс + кнопка ➕
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "  Баланс: ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "  1200 €",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      // TODO: добавить новую операцию
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              const SizedBox(height: 32),

              // 🔹 Заголовок
              const Text(
                "Pасходы по месяцам",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // 🔵 Pie Chart
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        color: Colors.redAccent,
                        title: "Жильё\n40%",
                        radius: 80,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      PieChartSectionData(
                        value: 25,
                        color: Colors.green,
                        title: "Еда\n25%",
                        radius: 80,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: Colors.blue,
                        title: "Транспорт\n20%",
                        radius: 80,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      PieChartSectionData(
                        value: 15,
                        color: Colors.orange,
                        title: "Развлечения\n15%",
                        radius: 80,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 🔻 Кнопки под графиком
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(
                                userId: widget.userId,
                              ), // пока userId=1
                            ),
                          );

                          if (result == true) {
                            // можно обновить список транзакций или график
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: const Text(
                          "Расход",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddIncomeScreen(
                                userId: widget.userId,
                              ), // пока userId=1
                            ),
                          );

                          if (result == true) {
                            // можно обновить список транзакций или график
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Доход",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Доходы по месяцам",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const IncomeLineChart(), // 🔥 наш линейный график
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
