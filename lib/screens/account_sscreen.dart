import 'package:flutter/material.dart';
import 'package:project_simpl/database/database_helper.dart';
import 'package:project_simpl/screens/add_expense_screen.dart';
import 'package:project_simpl/screens/add_income_screen.dart';

import 'add_account_screen.dart';

class AccountsScreen extends StatefulWidget {
  final int userId;
  final String source; // 🔹 откуда пришёл пользователь: "expense", "income"

  const AccountsScreen({super.key, required this.userId, required this.source});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await db.getAccounts(widget.userId);
    setState(() {
      _accounts = accounts;
    });
  }

  Future<void> _openAddAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      _loadAccounts();
    }
  }

  Future<bool> _deleteAccount(int accountId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить счёт?"),
        content: const Text("Вы уверены, что хотите удалить этот счёт?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await db.deleteAccount(accountId);
      _loadAccounts();
      return true;
    }
    return false;
  }

  // 🔹 Цвет AppBar в зависимости от source
  Color _getAppBarColor() {
    switch (widget.source) {
      case "expense":
        return Colors.redAccent;
      case "income":
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.source == "expense"
              ? "Выберите счет для расхода"
              : widget.source == "income"
              ? "Выберите счет для дохода"
              : "Мои счета",
        ),
        backgroundColor: _getAppBarColor(),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _openAddAccount),
        ],
      ),
      body: _accounts.isEmpty
          ? const Center(
              child: Text(
                "Нет счетов",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                return Dismissible(
                  key: ValueKey(account["id"]),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await _deleteAccount(account["id"]);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.indigo,
                      ),
                      title: Text(account["name"]),
                      subtitle: Text(
                        "Баланс: ${account["balance"].toStringAsFixed(2)} €",
                      ),
                      // 👇 при клике открываем экран расходов конкретного счёта
                      onTap: () {
                        if (widget.source == "expense") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(
                                userId: widget.userId,
                                accountName: account["name"],
                              ),
                            ),
                          );
                        }
                        if (widget.source == "income") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddIncomeScreen(
                                userId: widget.userId,
                                accountName: account["name"],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
