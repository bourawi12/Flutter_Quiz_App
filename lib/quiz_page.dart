import 'package:flutter/material.dart';
import 'models/question.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart'; // Import the package

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int score = 0;

  late Timer _timer;
  int _timeRemaining = 15;
  final int _maxTimePerQuestion = 15;

  final AudioPlayer _audioPlayer = AudioPlayer();

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
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer.cancel();
          _playSoundLocal('wrong.wav');
          _vibrate(); // Vibrate when time runs out
          _moveToNextQuestion();
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
    // Check if vibration is supported on the device
    bool canVibrate = await Vibrate.canVibrate;
    if (canVibrate) {
      // You can choose different vibration patterns:
      // Vibrate.feedback(FeedbackType.light); // Light tap
      // Vibrate.feedback(FeedbackType.medium); // Medium tap
      // Vibrate.feedback(FeedbackType.heavy); // Heavy tap
      // Vibrate.feedback(FeedbackType.selection); // A short, distinct vibration
      // Vibrate.vibrate(); // Default short vibration
      Vibrate.feedback(FeedbackType.light); // A subtle vibration for answer choice
    } else {
      debugPrint("Vibration not supported on this device.");
    }
  }

  void checkAnswer(String selectedAnswer) async {
    _timer.cancel();

    final isCorrect = selectedAnswer == widget.questions[currentIndex].correctAnswer;
    if (isCorrect) {
      score++;
      await _playSoundLocal('correct.wav');
    } else {
      await _playSoundLocal('wrong.wav');
    }

    _vibrate(); // Trigger vibration after an answer is chosen

    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        _startTimer();
      });
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
        content: Text("Votre score : $score/${widget.questions.length}"),
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
            ...question.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(option),
              ),
            )),
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