import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_page.dart';
import '../models/question.dart';
import 'package:audioplayers/audioplayers.dart';


class QuizSettingsPage extends StatefulWidget {
  const QuizSettingsPage({super.key});

  @override
  State<QuizSettingsPage> createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  final ApiService apiService = ApiService();
  final AudioPlayer _player = AudioPlayer();

  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  String? selectedDifficulty;
  int selectedAmount = 5;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    try {
      final fetchedCategories = await apiService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        selectedCategory = fetchedCategories.first['id'].toString();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
    }
  }

  void startQuiz() async {
    final questions = await apiService.fetchQuestions(
      amount: selectedAmount,
      category: selectedCategory,
      difficulty: selectedDifficulty,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres du Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Catégorie"),
              value: selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat['id'].toString(),
                  child: Text(cat['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Difficulté"),
              value: selectedDifficulty,
              items: ['easy', 'medium', 'hard'].map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Nombre de questions"),
              value: selectedAmount,
              items: [5, 10, 15].map((amount) {
                return DropdownMenuItem(
                  value: amount,
                  child: Text('$amount'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAmount = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: startQuiz,
              child: const Text("Commencer le Quiz"),
            )
          ],
        ),
      ),
    );
  }
}
