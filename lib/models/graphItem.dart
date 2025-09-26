import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/database/database_helper.dart';

class GraphItem {
  final String title;
  final double value;
  final Color color;

  GraphItem({required this.title, required this.value, required this.color});
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<GraphItem>>((ref) {
      return ExpensesNotifier();
    });

class ExpensesNotifier extends StateNotifier<List<GraphItem>> {
  ExpensesNotifier() : super([]);

  /// Загружаем расходы по категориям
  Future<void> loadExpenses(int userId) async {
    final rawData = await DatabaseHelper.instance.getExpensesByCategory(userId);

    final categoryColors = {
      "Жильё": Colors.purple.shade700,
      "Еда": Colors.green.shade800,
      "Транспорт": Colors.blue.shade700,
      "Развлечения": Colors.orange.shade700,
      "Другое": Colors.grey.shade700,
    };

    state = rawData.map((e) {
      return GraphItem(
        title: e['category'] as String,
        value: (e['total'] as num).toDouble(),
        color: categoryColors[e['category']] ?? Colors.black,
      );
    }).toList();
  }

  /// Метод для форсированного обновления (например после добавления транзакции)
  Future<void> refresh(int userId) async {
    await loadExpenses(userId);
  }
}
