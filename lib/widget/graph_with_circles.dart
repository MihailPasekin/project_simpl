import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/models/graphItem.dart';

class PremiumPieChart extends ConsumerStatefulWidget {
  final int userId; // передаем userId, чтобы знать, какие данные загружать

  const PremiumPieChart({super.key, required this.userId});

  @override
  ConsumerState<PremiumPieChart> createState() => _PremiumPieChartState();
}

class _PremiumPieChartState extends ConsumerState<PremiumPieChart>
    with SingleTickerProviderStateMixin {
  List<double> animatedValues = [];
  int touchedIndex = -1;
  late AnimationController _pulseController;
  String selectedPeriod = 'day'; // день, неделя, месяц, год
  DateTime _selectedDate = DateTime.now(); // дата, выбранная пользователем

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // Загружаем данные по умолчанию
    ref
        .read(expensesProvider.notifier)
        .loadExpenses(widget.userId, selectedPeriod);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void setPeriod(String period) {
    setState(() {
      selectedPeriod = period;
    });

    // Загружаем расходы с выбранным периодом
    ref
        .read(expensesProvider.notifier)
        .loadExpenses(widget.userId, selectedPeriod);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Фильтрация данных относительно выбранной даты
  List<GraphItem> getFilteredData(List<GraphItem> allData) {
    return allData.where((item) {
      DateTime date = item.date;
      switch (selectedPeriod) {
        case 'day':
          return isSameDate(date, _selectedDate);
        case 'week':
          return date.isAfter(
                _selectedDate.subtract(const Duration(days: 7)),
              ) &&
              date.isBefore(_selectedDate.add(const Duration(days: 1)));
        case 'month':
          return date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
        case 'year':
          return date.year == _selectedDate.year;
        default:
          return true;
      }
    }).toList();
  }

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<PieChartSectionData> getSections(List<GraphItem> data) {
    return List.generate(data.length, (i) {
      bool isTouched = i == touchedIndex;
      double radius =
          (isTouched ? 90 : 70) + (isTouched ? _pulseController.value * 10 : 0);

      return PieChartSectionData(
        value: animatedValues.isNotEmpty && i < animatedValues.length
            ? animatedValues[i]
            : data[i].value,
        title:
            "${data[i].title}\n${(animatedValues.isNotEmpty && i < animatedValues.length ? animatedValues[i].toInt() : data[i].value.toInt())}€",
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

    final filteredData = getFilteredData(data);

    return Column(
      children: [
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildGradientChoice('Д', 'day'),
            const SizedBox(width: 8),
            _buildGradientChoice('Н', 'week'),
            const SizedBox(width: 8),
            _buildGradientChoice('М', 'month'),
            const SizedBox(width: 8),
            _buildGradientChoice('Г', 'year'),
          ],
        ),
        const SizedBox(height: 16),

        // График
        SizedBox(
          height: 270,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 4,
              sections: getSections(filteredData),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    touchedIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientChoice(String label, String period) {
    final bool isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () => setPeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                )
              : LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade100],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.shade300.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
