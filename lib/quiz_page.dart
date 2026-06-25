import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'quiz_result_page.dart';
import 'data/hindi_easy.dart';
import 'data/hindi_medium.dart';
import 'data/hindi_hard.dart';
import 'data/bengali_easy.dart';
import 'data/bengali_medium.dart';
import 'data/bengali_hard.dart';
import 'data/marathi_easy.dart';
import 'data/marathi_medium.dart';
import 'data/marathi_hard.dart';
import 'data/gujarati_easy.dart';
import 'data/gujarati_medium.dart';
import 'data/gujarati_hard.dart';
import 'data/telugu_easy.dart';
import 'data/telugu_medium.dart';
import 'data/telugu_hard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPage extends StatefulWidget {
  final String language;
  final int quizLength;
  final bool isScoreMode;
  final String difficulty;

  const QuizPage(
      this.language,
      this.quizLength,
      this.isScoreMode,
      this.difficulty,
      {super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Color backgroundColor = const Color(0xFFF9C55E);

  FlutterTts tts = FlutterTts();

  int currentQuestion = 0;
  int score = 0;
  int correctAnswers = 0;
  int? selectedIndex;

  late int totalQuestions;

  int timeLeft = 20;
  Timer? timer;


  List<Map<String, dynamic>> questions = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> shuffleOptions(List<Map<String, dynamic>> qs) {
    for (var q in qs) {
      List options = List.from(q["options"]);
      options.shuffle();
      q["options"] = options;
    }
    return qs;
  }

  @override
  void initState() {
    super.initState();

    if (widget.language == "Hindi") {

      if (widget.difficulty == "Easy") {
        questions = List.from(hindiEasy);
      } else if (widget.difficulty == "Medium") {
        questions = List.from(hindiMedium);
      } else {
        questions = List.from(hindiHard);
      }

    }
    else if (widget.language == "Bengali") {

      if (widget.difficulty == "Easy") {
        questions = List.from(bengaliEasy);
      } else if (widget.difficulty == "Medium") {
        questions = List.from(bengaliMedium);
      } else {
        questions = List.from(bengaliHard);
      }

    }
    else if (widget.language == "Marathi") {

      if (widget.difficulty == "Easy") {
        questions = List.from(marathiEasy);
      } else if (widget.difficulty == "Medium") {
        questions = List.from(marathiMedium);
      } else {
        questions = List.from(marathiHard);
      }

    }
    else if (widget.language == "Gujarati") {

      if (widget.difficulty == "Easy") {
        questions = List.from(gujaratiEasy);
      } else if (widget.difficulty == "Medium") {
        questions = List.from(gujaratiMedium);
      } else {
        questions = List.from(gujaratiHard);
      }

    }
    else if (widget.language == "Telugu") {

      if (widget.difficulty == "Easy") {
        questions = List.from(teluguEasy);
      } else if (widget.difficulty == "Medium") {
        questions = List.from(teluguMedium);
      } else {
        questions = List.from(teluguHard);
      }

    }

    totalQuestions = widget.quizLength;

    if (totalQuestions > questions.length) {
      totalQuestions = questions.length;
    }
    questions = shuffleOptions(questions);
    questions.shuffle();

    // 🔥 delay timer start
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        startTimer();
      }
    });
  }

  /// 🔊 LANGUAGE VOICE
  String getTtsLanguage(String language) {
    switch (language) {
      case "Hindi":
        return "hi-IN";
      case "Bengali":
        return "bn-IN";
      case "Gujarati":
        return "gu-IN";
      case "Marathi":
        return "mr-IN";
      case "Telugu":
        return "te-IN";
      default:
        return "en-US";
    }
  }
  Future speakWord() async {

    await tts.setLanguage(getTtsLanguage(widget.language));

    String correctWord = questions[currentQuestion]["answer"];

    await tts.speak(correctWord);
  }

  /// ⏱️ TIMER LOGIC
  void startTimer() {
    timeLeft = 20;

    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();

        setState(() {
          backgroundColor = Colors.grey; // ⏱️ TIME UP
        });

        Future.delayed(Duration(seconds: 1), () {
          nextQuestion();
        });
      }
    });
  }

  void nextQuestion() async {
    if (currentQuestion < totalQuestions - 1) {
      setState(() {
        currentQuestion++;
        selectedIndex = null;
        backgroundColor = const Color(0xFFF9C55E); // 🔥 reset to yellow
      });

      startTimer();
      speakWord();
    } else {
      await saveUserProgress();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            score,
            totalQuestions,
            widget.isScoreMode,
            correctAnswers,// 🔥 PASS MODE
          ),
        ),
      );
    }
  }

  Future saveUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final docRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        "totalPlayed": FieldValue.increment(1),
        "totalCorrect": FieldValue.increment(correctAnswers),
        "lastScore": score,

        /// 🎯 MODE BASED
        widget.isScoreMode
            ? "scoreModePlayed"
            : "practiceModePlayed": FieldValue.increment(1),

        widget.isScoreMode
            ? "scoreModeCorrect"
            : "practiceModeCorrect": FieldValue.increment(correctAnswers),

        "history": FieldValue.arrayUnion([
          {
            "score": widget.isScoreMode ? score : correctAnswers,
            "total": totalQuestions,
            "maxScore": totalQuestions * 5,
            "date": DateTime.now().toString(),
            "mode": widget.isScoreMode ? "score" : "practice",
            "language": widget.language,
          }
        ])
      });
    } else {
      await docRef.set({
        "totalPlayed": 1,
        "totalCorrect": correctAnswers,
        "lastScore": score,

        "scoreModePlayed": widget.isScoreMode ? 1 : 0,
        "scoreModeCorrect": widget.isScoreMode ? correctAnswers : 0,

        "practiceModePlayed": widget.isScoreMode ? 0 : 1,
        "practiceModeCorrect": widget.isScoreMode ? 0 : correctAnswers,

        "history": [
          {
            "score": widget.isScoreMode ? score : correctAnswers,
            "total": totalQuestions,
            "maxScore": totalQuestions * 5,
            "date": DateTime.now().toString(),
            "mode": widget.isScoreMode ? "score" : "practice",
            "language": widget.language,
          }
        ]
      });
    }
  }

  void checkAnswer(int index) async {
    if (selectedIndex != null) return;

    timer?.cancel();

    setState(() {
      selectedIndex = index;
    });

    var question = questions[currentQuestion];

    String selected = question["options"][index];
    String correct = question["answer"];
    if (selected == correct) {

      correctAnswers++; // 🧠 ALWAYS increase correct count

      if (widget.isScoreMode) {

        if (timeLeft > 15) {
          score += 5;
        } else if (timeLeft > 5) {
          score += 3;
        } else {
          score += 1;
        }

      }

      setState(() {
        backgroundColor = Colors.green;
      });

    } else {

      setState(() {
        backgroundColor = Colors.red;
      });

    }

    await Future.delayed(Duration(seconds: 1));

    nextQuestion();
  }

  Color getTimerColor() {
    if (timeLeft > 15) return Colors.green;
    if (timeLeft > 5) return Colors.orange;
    return Colors.red;
  }

  Color getOptionColor(int index) {
    if (selectedIndex == null) return Colors.white;

    var question = questions[currentQuestion];

    String option = question["options"][index];
    String correct = question["answer"];

    if (option == correct) return Colors.green;
    if (index == selectedIndex) return Colors.red;

    return Colors.white;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var question = questions[currentQuestion];

    List options = question["options"];

    return WillPopScope(
      onWillPop: () async {

        timer?.cancel(); // 🛑 STOP TIMER when back is pressed

        bool shouldExit = await showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                backgroundColor: const Color(0xFF190483),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  "Quit",
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  "Are you sure you want to quit?",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),

                ],
              ),
        );

        return shouldExit ?? false;
      },

      child: Scaffold(

        // 🔥 CHANGED THIS LINE
        backgroundColor: backgroundColor,

        appBar: AppBar(
          backgroundColor: const Color(0xFF190483),
          iconTheme: IconThemeData(
            color: Color(0xFFF9C55E), // 👈 yellow back arrow
          ),
          title: const Text("Quiz",
            style: TextStyle(
              color: Color(0xFFF9C55E), // yellow color
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              const SizedBox(height: 20),

              /// ⏱️ TIMER UI
              Text(
                "Time Left: $timeLeft sec",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: getTimerColor(),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Question ${currentQuestion + 1} / $totalQuestions",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text("Play Word"),
                onPressed: speakWord,
              ),

              const SizedBox(height: 40),

              ...List.generate(
                options.length,
                    (index) {
                  return Padding(

                    padding: const EdgeInsets.symmetric(vertical: 8),

                    child: GestureDetector(

                      onTap: () => checkAnswer(index),

                      child: Container(

                        height: 55,

                        decoration: BoxDecoration(
                          color: getOptionColor(index),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            )
                          ],
                        ),

                        child: Center(
                          child: Text(
                            options[index],
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: "JosefinSans",
                            ),
                          ),
                        ),

                      ),

                    ),

                  );
                },
              )

            ],

          ),
        ),
      ),
    );
  }
}