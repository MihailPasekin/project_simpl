import 'package:flutter/material.dart';
import 'package:project_simpl/aunt/login.dart';
import 'package:project_simpl/aunt/registration_screen.dart';
import 'package:project_simpl/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
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
        "/home": (context) => const HomeScreen(),
      },
    );
  }
}
