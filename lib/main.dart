import 'package:class_sched/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3aGRlYnFmb293cWl3bnZiemRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc1NjEwMzIsImV4cCI6MjA1MzEzNzAzMn0.Fj6ZlvPJYZcLmFymYa21frwW2jLGb7HfRov-FhpJxgk",
    url: "https://dwhdebqfoowqiwnvbzdo.supabase.co",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassSched',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 117, 74),
          primary: const Color.fromARGB(255, 17, 117, 74),
          secondary: const Color.fromARGB(255, 224, 178, 36),
          tertiary: const Color.fromARGB(255, 236, 236, 236)
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold
          ),
          displayMedium: TextStyle(
            fontSize: 40,
          ),
          titleLarge: TextStyle(
            fontSize: 32
          ),
          bodyLarge: TextStyle(
            fontSize: 26
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
          ),
          bodySmall: TextStyle(
            fontSize: 14
          ),
          labelSmall: TextStyle(
            fontSize: 10,
          )
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.black26,
            fontSize: 14
          ),
          
        ),
        useMaterial3: true,
      ),
      home: const AuthGate()
    );
  }
}
