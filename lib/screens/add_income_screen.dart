import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project_simpl/database/database_helper.dart';
import 'package:project_simpl/object/account.dart';
import 'package:project_simpl/object/user.dart';
import 'package:project_simpl/providers/account_provider.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  final User user;
  final Account account;
  const AddIncomeScreen({super.key, required this.user, required this.account});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = "Зарплата";
  DateTime _selectedDate = DateTime.now();

  final db = DatabaseHelper.instance;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

      final income = {
        "userId": widget.user.id!,
        "type": "income",
        "category": _category,
        "amount": amount,
        "note": _noteController.text,
        "date": _selectedDate.toIso8601String(),
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
      };

      await db.insertTransaction(income);

      // Обновляем баланс через провайдер
      final accountsNotifier = ref.read(accountsProvider.notifier);
      final updatedAccount = widget.account.copyWith(
        balance: widget.account.balance + amount,
      );
      await accountsNotifier.updateAccountBalance(updatedAccount);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Доход сохранён")));

      Navigator.pop(context, true);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Счет ${widget.account.name}"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Баланс ${widget.account.balance} €",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // 💰 Сумма
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Сумма",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Введите сумму";
                  final number = double.tryParse(value.replaceAll(',', '.'));
                  if (number == null) return "Введите корректное число";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 📂 Категория
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: "Категория",
                  border: OutlineInputBorder(),
                ),
                items: ["Зарплата", "Подарок", "Бизнес", "Другое"]
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),

              // 📝 Заметка
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Заметка",
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 📅 Дата
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Дата: ${DateFormat('dd.MM.yyyy').format(_selectedDate)}",
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Выбрать дату"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ Кнопка сохранить
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _saveIncome,
                  child: const Text("Сохранить доход"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
