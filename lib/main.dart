import 'package:flutter/material.dart';
import 'package:project_simpl/aunt/login.dart';
import 'package:project_simpl/aunt/registration_screen.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const bool resetDb = false; // 👉 меняешь на true только когда надо дропнуть

  // ignore: dead_code
  if (resetDb) {
    await deleteDatabase(await getDatabasesPath() + '/app.db');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Simpl',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginScreen(),
        "/registration": (context) => const RegistrationScreen(),
      },
    );
  }
}
