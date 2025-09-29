import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/database/database_helper.dart';

class GraphItem {
  final String title;
  final double value;
  final Color color;
  final DateTime date;

  GraphItem({
    required this.date,
    required this.title,
    required this.value,
    required this.color,
  });
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<GraphItem>>((ref) {
      return ExpensesNotifier();
    });

class ExpensesNotifier extends StateNotifier<List<GraphItem>> {
  ExpensesNotifier() : super([]);

  /// Загружаем расходы по категориям с фильтром по периоду
  /// period: "day", "week", "month", "year"
  Future<void> loadExpenses(int userId, String period) async {
    DateTime now = DateTime.now();
    DateTime start;

    // Определяем дату начала периода
    switch (period) {
      case 'day':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(2000); // на всякий случай
    }

    // Получаем агрегированные данные из базы с фильтром по дате
    final rawData = await DatabaseHelper.instance
        .getExpensesByCategoryAndPeriod(userId, start, now);

    final categoryColors = {
      "Жильё": Colors.purple.shade700,
      "Еда": Colors.green.shade800,
      "Транспорт": Colors.blue.shade700,
      "Развлечения": Colors.orange.shade700,
      "Другое": Colors.grey.shade700,
    };

    // Преобразуем данные в GraphItem
    state = rawData.map((e) {
      return GraphItem(
        date: now, // можно просто текущая дата, суммы уже агрегированы
        title: e['category'] as String,
        value: (e['total'] as num).toDouble(),
        color: categoryColors[e['category']] ?? Colors.black,
      );
    }).toList();
  }

  /// Метод для обновления после добавления транзакции
  Future<void> refresh(int userId, String period) async {
    await loadExpenses(userId, period);
  }
}
