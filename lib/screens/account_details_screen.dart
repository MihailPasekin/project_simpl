import 'package:flutter/material.dart';

import 'package:project_simpl/models/account.dart';
import 'package:project_simpl/database/database_helper.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final allTx = await DatabaseHelper.instance.getTransactions(
      widget.account.userId,
    );

    // Фильтруем только транзакции текущего счета
    final accountTx = allTx
        .where((tx) => tx['accountId'] == widget.account.id)
        .toList();

    setState(() => transactions = accountTx);
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = transactions
        .where((tx) => tx['type'] == 'expense')
        .fold<double>(0, (sum, tx) => sum + (tx['amount'] as double));

    final totalIncome = transactions
        .where((tx) => tx['type'] == 'income')
        .fold<double>(0, (sum, tx) => sum + (tx['amount'] as double));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.account.name),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Баланс: ${widget.account.balance.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Расходы",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${totalExpenses.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "Доходы",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${totalIncome.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: transactions.isEmpty
                      ? const Center(
                          child: Text(
                            "Нет транзакций",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            final isExpense = tx['type'] == 'expense';
                            final amountColor = isExpense
                                ? Colors.redAccent
                                : Colors.greenAccent;

                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: amountColor.withOpacity(0.2),
                                  child: Icon(
                                    isExpense ? Icons.remove : Icons.add,
                                    color: amountColor,
                                  ),
                                ),
                                title: Text(
                                  tx['category'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  DateTime.parse(
                                    tx['date'],
                                  ).toLocal().toString().split(' ')[0],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Text(
                                  "${tx['amount'].toStringAsFixed(2)} €",
                                  style: TextStyle(
                                    color: amountColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
