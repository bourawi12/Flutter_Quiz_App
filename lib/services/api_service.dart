import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  Future<List<Question>> fetchQuestions({
    int amount = 5,
    String? category,
    String? difficulty,
  }) async {
    String url = 'https://opentdb.com/api.php?amount=$amount&type=multiple';

    if (category != null) url += '&category=$category';
    if (difficulty != null) url += '&difficulty=$difficulty';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map((q) => Question.fromMap(q)).toList();
    } else {
      throw Exception('Erreur lors du chargement des questions');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final List categories = jsonDecode(response.body)['trivia_categories'];
      return categories.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des catégories');
    }
  }
}
