import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/database/database_helper.dart';
import 'package:project_simpl/widget/income_chart.dart';

final incomeProvider = FutureProvider.family<List<IncomeEntry>, int>((
  ref,
  userId,
) async {
  final rows = await DatabaseHelper.instance.getTransactionsByType(
    userId,
    null, // null если хочешь все аккаунты, можно фильтровать по accountId
    "income",
  );
  return rows.map((row) {
    return IncomeEntry(
      DateTime.parse(row["date"] as String),
      (row["amount"] as num).toDouble(),
    );
  }).toList();
});
