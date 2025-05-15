import 'package:flutter/material.dart';
import 'quiz_page.dart'; // Assure-toi que ce chemin est correct
import 'quiz_settings_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
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
                    Text('Développé par Mohamed Bouraoui Bouaziz.\nCe quiz utilise l\'API OpenTDB.')
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
