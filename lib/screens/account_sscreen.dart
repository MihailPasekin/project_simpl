import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/models/account.dart';
import 'package:project_simpl/models/user.dart';
import 'package:project_simpl/providers/account_provider.dart';
import 'package:project_simpl/screens/add_expense_screen.dart';
import 'package:project_simpl/screens/add_income_screen.dart';
import 'add_account_screen.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  final User user;
  final String source; // "expense" или "income"

  const AccountsScreen({super.key, required this.user, required this.source});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем счета пользователя через провайдер
    Future.microtask(() {
      ref.read(accountsProvider.notifier).setUser(widget.user);
    });
  }

  Future<void> _openAddAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAccountScreen(user: widget.user)),
    );

    if (result == true) {
      // Обновляем счета через провайдер
      ref.read(accountsProvider.notifier).loadAccounts();
    }
  }

  Future<bool> _deleteAccount(Account account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
      await ref.read(accountsProvider.notifier).deleteAccount(account.id!);
      return true;
    }
    return false;
  }

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
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.source == "expense"
              ? "Выберите счёт для расхода"
              : widget.source == "income"
              ? "Выберите счёт для дохода"
              : "Мои счета",
        ),
        backgroundColor: _getAppBarColor(),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _openAddAccount),
        ],
      ),
      body: accounts.isEmpty
          ? const Center(
              child: Text(
                "Нет счетов",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Dismissible(
                  key: ValueKey(account.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _deleteAccount(account),
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
                      title: Text(account.name),
                      subtitle: Text(
                        "Баланс: ${account.balance.toStringAsFixed(2)} €",
                      ),
                      onTap: () {
                        if (widget.source == "expense") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddExpenseScreen(
                                user: widget.user,
                                account: account,
                              ),
                            ),
                          );
                        } else if (widget.source == "income") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddIncomeScreen(
                                user: widget.user,
                                account: account,
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
