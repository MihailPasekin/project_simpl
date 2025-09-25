import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_simpl/database/database_helper.dart';
import 'package:project_simpl/object/account.dart';
import 'package:project_simpl/object/user.dart';
import 'dart:async';

class AccountsNotifier extends StateNotifier<List<Account>> {
  final db = DatabaseHelper.instance;
  User? _user; // текущий пользователь
  Timer? _timer; // для автоматического обновления

  AccountsNotifier() : super([]);

  /// Устанавливаем пользователя и сразу загружаем счета
  void setUser(User user) {
    _user = user;
    loadAccounts();

    // запускаем таймер для автоматического обновления каждые 5 секунд
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadAccounts();
    });
  }

  Future<void> updateAccountBalance(Account updatedAccount) async {
    // Обновляем в БД
    await db.updateAccount(updatedAccount);
    // Обновляем в state
    state = [
      for (final acc in state)
        if (acc.id == updatedAccount.id) updatedAccount else acc,
    ];
  }

  /// Загружаем счета текущего пользователя
  Future<void> loadAccounts() async {
    if (_user == null || _user!.id == null) return;
    final accounts = await db.getAccounts(_user!.id!);
    state = accounts;
  }

  /// Добавляем новый счет и обновляем список
  Future<void> addAccount(Account account) async {
    if (_user == null || _user!.id == null) return;
    await db.insertAccount(account);
    await loadAccounts();
  }

  /// Удаляем счет и обновляем список
  Future<void> deleteAccount(int accountId) async {
    await db.deleteAccount(accountId);
    state = state.where((a) => a.id != accountId).toList();
  }

  /// Общий баланс всех счетов
  double get totalBalance =>
      state.fold(0, (sum, account) => sum + account.balance);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Провайдер без family
final accountsProvider = StateNotifierProvider<AccountsNotifier, List<Account>>(
  (ref) {
    return AccountsNotifier();
  },
);
