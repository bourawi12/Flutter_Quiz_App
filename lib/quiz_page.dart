import 'package:flutter/material.dart';
import 'models/question.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

// Class to store quiz results
class QuizResult {
  final String question;
  final String correctAnswer;
  final String? userAnswer; // null if time ran out
  final bool isCorrect;
  final bool timedOut;

  QuizResult({
    required this.question,
    required this.correctAnswer,
    this.userAnswer,
    required this.isCorrect,
    required this.timedOut,
  });
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int score = 0;

  late Timer _timer;
  int _timeRemaining = 15;
  final int _maxTimePerQuestion = 15;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // State variables for answer feedback
  String? _selectedAnswer;
  bool _isAnswerChecked = false;
  Map<String, Color?> _answerButtonColors = {};

  // Store quiz results for final summary
  List<QuizResult> _quizResults = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timeRemaining = _maxTimePerQuestion;
      _isAnswerChecked = false;
      _selectedAnswer = null;
      _answerButtonColors.clear(); // Use clear() instead of {}
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer.cancel();
          _playSoundLocal('wrong.wav');
          _vibrate();

          // When time runs out, show correct answer
          final currentQuestion = widget.questions[currentIndex];
          _isAnswerChecked = true;
          _answerButtonColors[currentQuestion.correctAnswer] = Colors.green;

          // Record the result for time out
          _quizResults.add(QuizResult(
            question: currentQuestion.question,
            correctAnswer: currentQuestion.correctAnswer,
            userAnswer: null, // No answer selected
            isCorrect: false,
            timedOut: true,
          ));

          // Move to next question after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _moveToNextQuestion();
            }
          });
        }
      });
    });
  }

  Future<void> _playSoundLocal(String fileName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint("Error playing local sound: $e");
    }
  }

  Future<void> _vibrate() async {
    try {
      bool canVibrate = await Vibrate.canVibrate;
      if (canVibrate) {
        Vibrate.feedback(FeedbackType.light);
      }
    } catch (e) {
      debugPrint("Vibration error: $e");
    }
  }

  void checkAnswer(String selectedAnswer) async {
    if (_isAnswerChecked) return; // Prevent multiple selections

    _timer.cancel(); // Stop the timer immediately

    final currentQuestion = widget.questions[currentIndex];
    final isCorrect = selectedAnswer == currentQuestion.correctAnswer;

    setState(() {
      _selectedAnswer = selectedAnswer;
      _isAnswerChecked = true;

      // Always show the correct answer in green
      _answerButtonColors[currentQuestion.correctAnswer] = Colors.green;

      // If the selected answer is wrong, show it in red
      if (!isCorrect) {
        _answerButtonColors[selectedAnswer] = Colors.red;
      }
    });

    // Update score and play sound
    if (isCorrect) {
      score++;
      await _playSoundLocal('correct.wav');
    } else {
      await _playSoundLocal('wrong.wav');
    }

    // Record the result
    _quizResults.add(QuizResult(
      question: currentQuestion.question,
      correctAnswer: currentQuestion.correctAnswer,
      userAnswer: selectedAnswer,
      isCorrect: isCorrect,
      timedOut: false,
    ));

    await _vibrate();

    // Wait 2 seconds to show feedback colors, then move to next question
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _moveToNextQuestion();
    }
  }

  void _moveToNextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
      });
      _startTimer(); // This will reset all the feedback state
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz terminé"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Votre score : $score/${widget.questions.length}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Détail des réponses :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SizedBox(
                  height: 300, // Fixed height for scrollable content
                  child: ListView.builder(
                    itemCount: _quizResults.length,
                    itemBuilder: (context, index) {
                      final result = _quizResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Q${index + 1}: ${result.question}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    result.isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: result.isCorrect ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    result.isCorrect ? "Correct" : "Incorrect",
                                    style: TextStyle(
                                      color: result.isCorrect ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bonne réponse: ${result.correctAnswer}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (result.userAnswer != null)
                                Text(
                                  "Votre réponse: ${result.userAnswer}",
                                  style: TextStyle(
                                    color: result.isCorrect ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              else
                                const Text(
                                  "Temps écoulé - Aucune réponse",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${currentIndex + 1}/${widget.questions.length}",
                  style: const TextStyle(fontSize: 18),
                ),
                _buildTimerWidget(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Build answer buttons
            ...question.options.map((option) {
              Color? buttonColor = _answerButtonColors[option];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isAnswerChecked ? null : () => checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: buttonColor, // Keep color when disabled
                      foregroundColor: buttonColor != null ? Colors.white : null,
                      disabledForegroundColor: buttonColor != null ? Colors.white : null,
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: buttonColor != null ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    final percentRemaining = _timeRemaining / _maxTimePerQuestion;

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
        Icon(Icons.timer, color: timerColor),
        const SizedBox(width: 5),
        Text(
          "$_timeRemaining s",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        ),
        const SizedBox(width: 10),
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