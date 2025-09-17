import 'package:flutter/material.dart';
import 'package:project_simpl/database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final user = await DatabaseHelper.instance.getUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // ✅ Вход успешен
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Вход выполнен ✅")));

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        // ❌ Ошибка входа
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Неверный email или пароль ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔵 Фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      "Вход",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.blueAccent,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            hintText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Введите email"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Пароль
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.blueAccent,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            hintText: "Пароль",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Введите пароль"
                              : null,
                        ),
                        const SizedBox(height: 32),

                        // Кнопка Войти
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Войти",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Ссылка на регистрацию
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/registration");
                          },
                          child: const Text(
                            "Нет аккаунта? Зарегистрироваться",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
