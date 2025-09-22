import 'package:flutter/material.dart';
import 'package:project_simpl/aunt/login.dart';
import 'package:project_simpl/aunt/registration_screen.dart';
import 'package:project_simpl/screens/home_screen.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await deleteDatabase(
  //await getDatabasesPath() + '/app.db',
  //); // удаляем старую базу
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginScreen(),
        "/registration": (context) => const RegistrationScreen(),
        "/home": (context) => HomeScreen(userId: 1),
      },
    );
  }
}
