import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/auth/auth_gate.dart';
import 'ThemeNotifier.dart';
import 'home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(url: "https://oicukwtpqxlsqgktqdcn.supabase.co", anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pY3Vrd3RwcXhsc3Fna3RxZGNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyNzU0MTYsImV4cCI6MjA1ODg1MTQxNn0.yOnNdTLL6crltlxjunf_kb9sR1vW9LEO8FaM2rbOejE");
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode,
      home: const AuthGate(),
    );
  }
}
