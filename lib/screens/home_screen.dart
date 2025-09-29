import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/models/user.dart';
import 'package:project_simpl/providers/account_provider.dart';
import 'package:project_simpl/screens/add_account_screen.dart';
import 'package:project_simpl/screens/account_sscreen.dart';
import 'package:project_simpl/widget/graph_with_circles.dart';
import 'package:project_simpl/widget/income_chart.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Устанавливаем пользователя и автоматически загружаем счета
    Future.microtask(() {
      ref.read(accountsProvider.notifier).setUser(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final accountsNotifier = ref.read(accountsProvider.notifier);

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
                // 🔹 Профиль
                Card(
                  color: Colors.blueGrey.withOpacity(0.3),
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

                // 🔹 Общий баланс
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
                      "${accountsNotifier.totalBalance.toStringAsFixed(2)} €",
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
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddAccountScreen(user: widget.user),
                          ),
                        );
                        if (result == true) {
                          accountsNotifier.loadAccounts();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Список аккаунтов
                accounts.isEmpty
                    ? const Center(
                        child: Text(
                          "Нет счетов",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
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
                            onDismissed: (_) {
                              accountsNotifier.deleteAccount(account.id!);
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

                const SizedBox(height: 30),
                const Text(
                  "Расходы по месяцам",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                PremiumPieChart(userId: widget.user.id!),
                const SizedBox(height: 30),
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

                const Text(
                  "Доходы по месяцам",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                SimpleFancyMonthlyIncomeChart(
                  months: [
                    'Янв',
                    'Фев',
                    'Мар',
                    'Апр',
                    'Май',
                    'Июнь',
                    'Июль',
                    'Август',
                    'Сентябрь',
                    'Октябрь',
                    'Ноябрь',
                    'Декабарь',
                  ],
                  values: [
                    3200,
                    4000,
                    1000,
                    2000,
                    3200,
                    4000,
                    1000,
                    2000,
                    3200,
                    4000,
                    1000,
                    2000,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
