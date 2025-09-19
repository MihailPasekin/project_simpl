import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_simpl/database/database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final int userId; // ✅ принимаем userId

  const AddExpenseScreen({super.key, required this.userId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = "Еда";
  DateTime _selectedDate = DateTime.now();

  final db = DatabaseHelper.instance;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = {
        "userId": widget.userId, // ✅ теперь берём текущего пользователя
        "type": "expense",
        "category": _category,
        "amount": double.parse(_amountController.text),
        "note": _noteController.text,
        "date": _selectedDate.toIso8601String(),
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
      };

      await db.insertTransaction(expense);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Расход сохранён")));

      Navigator.pop(context, true); // вернём результат
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
        title: const Text("Добавить расход"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 💰 Сумма
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Сумма",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Введите сумму" : null,
              ),
              const SizedBox(height: 16),

              // 📂 Категория
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: "Категория",
                  border: OutlineInputBorder(),
                ),
                items: ["Еда", "Транспорт", "Развлечения", "Другое"]
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
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _saveExpense,
                  child: const Text("Сохранить расход"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
