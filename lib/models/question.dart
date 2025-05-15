class Question {
  final String question;
  final String correctAnswer;
  final List<String> options;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    final incorrectAnswers = List<String>.from(map['incorrect_answers']);
    final correctAnswer = map['correct_answer'] as String;
    final allAnswers = List<String>.from(incorrectAnswers)..add(correctAnswer);
    allAnswers.shuffle(); // Mélange les réponses

    return Question(
      question: map['question'],
      correctAnswer: correctAnswer,
      options: allAnswers,
    );
  }

}
