import 'package:flutter/material.dart';
import 'package:project_simpl/object/account.dart';
import 'package:project_simpl/object/user.dart';
import 'package:project_simpl/screens/account_sscreen.dart';
import 'package:project_simpl/screens/add_account_screen.dart';

import 'package:project_simpl/widget/income_chart.dart';
import 'package:project_simpl/database/database_helper.dart';
import 'package:project_simpl/widget/graph_with_circles.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;
  List<Account> _accounts = [];
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await db.getAccounts(widget.user!.id!);
    setState(() {
      _accounts = accounts;
      _totalBalance = accounts.fold<double>(
        0,
        (sum, acc) => sum + acc.balance,
      ); // ✅ теперь это List<Account>
    });
  }

  Future<void> _deleteAccount(Account account) async {
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
      await db.deleteAccount(account.id!);
      _loadAccounts();
    }
  }

  Future<void> _openAddAccountScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(user: widget.user),
      ),
    );

    if (result == true) {
      _loadAccounts();
    }
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Профиль пользователя
                Card(
                  color: widget.user.avatar != null
                      ? Colors.blueGrey.withOpacity(0.3)
                      : Colors.blueGrey.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: widget.user.avatar != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(widget.user.avatar!),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      widget.user.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 🔹 Общий баланс + кнопка ➕
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Баланс: ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${_totalBalance.toStringAsFixed(2)} €",
                      style: const TextStyle(
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
                      onPressed: _openAddAccountScreen,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Список счетов
                _accounts.isEmpty
                    ? const Center(
                        child: Text(
                          "Нет счетов",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _accounts.length,
                        itemBuilder: (context, index) {
                          final account = _accounts[index];

                          return Dismissible(
                            key: Key(account.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Удалить счёт?"),
                                  content: const Text(
                                    "Вы уверены, что хотите удалить этот счёт?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Отмена"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Удалить",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              await db.deleteAccount(account.id!);
                              _loadAccounts();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Счёт '${account.name}' удалён",
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  account.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  "Баланс: ${account.balance.toStringAsFixed(2)} €",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 20),

                // 🔹 Расходы по месяцам
                const Text(
                  "Расходы по месяцам",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                const GraphWithCircles(),
                const SizedBox(height: 30),

                // 🔹 Кнопки под графиком
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountsScreen(
                                user: widget.user,
                                source: "expense",
                              ),
                            ),
                          );
                          if (result == true) {
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
                              builder: (context) => AccountsScreen(
                                user: widget.user,
                                source: "income",
                              ),
                            ),
                          );
                          if (result == true) {
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

                const SizedBox(height: 30),

                // 🔹 График доходов
                const Text(
                  "Доходы по месяцам",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const IncomeLineChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
