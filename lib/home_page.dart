import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/pages/login_page.dart';
import 'quiz_page.dart';
import 'quiz_settings_page.dart';
import 'ThemeNotifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).isDark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizSettingsPage()),
                );
              },
              child: const Text('Commencer un quiz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Flutter Quiz App',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text(
                        'Développé par Mohamed Bouraoui Bouaziz.\nCe quiz utilise l\'API OpenTDB.')
                  ],
                );
              },
              child: const Text('À propos'),
            ),
          ],
        ),
      ),
    );
  }
}
