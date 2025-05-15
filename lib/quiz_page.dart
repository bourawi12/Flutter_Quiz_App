import 'package:flutter/material.dart';
import 'models/question.dart';
import 'services/api_service.dart';
import 'dart:async';

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int score = 0;
  // Timer variables
  late Timer _timer;
  int _timeRemaining = 15; // 15 seconds per question
  final int _maxTimePerQuestion = 15;

  @override
  void initState() {
    super.initState();
    // Start the timer when the page is initialized
    _startTimer();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Reset time remaining to max time
    setState(() {
      _timeRemaining = _maxTimePerQuestion;
    });

    // Create a periodic timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          // Time's up, move to next question automatically
          _timer.cancel();
          // Move to next question without giving points
          _moveToNextQuestion();
        }
      });
    });
  }

  void checkAnswer(String selectedAnswer) {
    // Cancel the current timer
    _timer.cancel();

    if (selectedAnswer == widget.questions[currentIndex].correctAnswer) {
      score++;
    }

    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        // Start the timer for the next question
        _startTimer();
      });
    } else {
      // Quiz is completed
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (_) => AlertDialog(
        title: const Text("Quiz terminé"),
        content: Text("Votre score : $score/${widget.questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // revenir à l'écran de paramètres
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${currentIndex + 1}/${widget.questions.length}",
                  style: const TextStyle(fontSize: 18),
                ),
                // Timer display
                _buildTimerWidget(),
              ],
            ),
            const SizedBox(height: 10),

            // Question text
            Text(
                question.question,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),

            // Answer options
            ...question.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50), // set minimum height
                ),
                child: Text(option),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Timer widget with visual indicator
  Widget _buildTimerWidget() {
    // Calculate percentage of time remaining
    final percentRemaining = _timeRemaining / _maxTimePerQuestion;

    // Change color based on time remaining
    Color timerColor;
    if (_timeRemaining > 10) {
      timerColor = Colors.green;
    } else if (_timeRemaining > 5) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }

    return Row(
      children: [
        // Timer icon
        Icon(Icons.timer, color: timerColor),
        const SizedBox(width: 5),
        // Time text
        Text(
          "$_timeRemaining s",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        ),
        const SizedBox(width: 10),
        // Progress bar
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: percentRemaining,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
        ),
      ],
    );
  }
}