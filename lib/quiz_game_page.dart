import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_magazine/quiz_level_page.dart';
import 'quiz_level_page.dart';
import 'quiz_data.dart';
import 'QuizStartPage.dart';
import 'dart:math';
import 'quiz_language_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String userId = FirebaseAuth.instance.currentUser!.uid;

class QuizGamePage extends StatefulWidget {
  final String language;
  final int level;

  const QuizGamePage({
    Key? key,
    required this.language,
    required this.level,
  }) : super(key: key);

  @override
  _QuizGamePageState createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  int score = 0;
  int currentIndex = 0;
  int? selectedIndex;
  bool answered = false;

  int bestScore = 0;
  bool isNewRecord = false;



  @override
  void initState() {
    super.initState();
    loadQuestions();
    loadBestScore();
  }

  String getScoreKey() {
    return "best_${widget.language}_${widget.level}";
  }

  Future<void> loadBestScore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bestScores')
        .doc("${widget.language}_${widget.level}")
        .get();

    if (doc.exists) {
      setState(() {
        bestScore = doc.data()?['score'] ?? 0;
      });
    } else {
      setState(() {
        bestScore = 0; // ✅ user never played
      });
    }
  }

  Future<void> saveBestScore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    var ref = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bestScores')
        .doc("${widget.language}_${widget.level}");

    var doc = await ref.get();

    int previousBest = 0;

    if (doc.exists) {
      previousBest = doc.data()?['score'] ?? 0;
    }

    if (score > previousBest) {
      await ref.set({
        'score': score,
        'language': widget.language,
        'level': widget.level,
      });

      bestScore = score;
      isNewRecord = true;
    } else {
      bestScore = previousBest;
    }
  }

  void loadQuestions() {
    String lang = widget.language.toLowerCase().trim();

    // ✅ SAFE access (prevents crash if language not found)
    List<Map<String, dynamic>> allQuestions =
        quizData[lang] ?? [];

    // ❗ If no questions
    if (allQuestions.isEmpty) {
      setState(() {
        questions = [];
      });
      return;
    }

    // 🔥 OPTIONAL: shuffle (comment if you want fixed order)
    // allQuestions.shuffle();

    // 🔥 BEST: stable shuffle (same questions per level)
    // import 'dart:math';
    // allQuestions.shuffle(Random(widget.level));

    // 🔥 LEVEL LOGIC
    int start = (widget.level - 1) * 10;
    int end = start + 10;

    // ❗ Prevent overflow
    if (start >= allQuestions.length) {
      setState(() {
        questions = [];
      });
      return;
    }

    setState(() {
      questions = allQuestions.sublist(
        start,
        end > allQuestions.length ? allQuestions.length : end,
      );
    });
    for (var q in questions) {
      List options = q["options"];
      options.shuffle(); // ✅ shuffle options
    }
  }

  Future<void> updateUserStatsFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    // 🔹 Update global stats
    await userRef.update({
      'totalScore': FieldValue.increment(score),
      'totalQuizzes': FieldValue.increment(1),
    });

    // 🔹 Update language stats
    String lang = widget.language.toLowerCase();

    await userRef.update({
      'languages.$lang.score': FieldValue.increment(score),
      'languages.$lang.quizzes': FieldValue.increment(1),
    });

    // 🔹 Save attempt (VERY IMPORTANT)
    await userRef.collection('attempts').add({
      'language': widget.language,
      'level': widget.level,
      'score': score,
      'total': questions.length,
      'accuracy': (score / questions.length) * 100,
      'date': FieldValue.serverTimestamp(),
    });
  }
  void goToResultPage() async {
    final prefs = await SharedPreferences.getInstance();

    String key = "${widget.language}_${widget.level}_attempted";
    await prefs.setBool(key, true);

    // ✅ ADD THIS
    double accuracy = (score / questions.length) * 100;
    String accKey = "${widget.language}_${widget.level}";
    await prefs.setDouble(accKey, accuracy);

    await saveBestScore();
    await updateUserStatsFirestore();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          score: score,
          total: questions.length,
          bestScore: bestScore,
          isNewRecord: isNewRecord,
          language: widget.language,
          level: widget.level, // ✅ added
        ),
      ),
    );
  }

  void checkAnswer(String selected) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedIndex =
          questions[currentIndex]["options"].indexOf(selected);

      if (selected == questions[currentIndex]["answer"]) {
        score++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Select Language",
              style: TextStyle(
                  color: Color(0xFFFFC857),
                  fontWeight: FontWeight.bold,
                  fontSize: 50)),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 25, 4, 131),
          iconTheme: IconThemeData(
            color: Color(0xFFFFC857),
          ),
        ),
        body: const Center(
          child: Text(
            "No Questions Found ❌",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }



    var q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(

        title: Text("Level ${widget.level}",
            style: TextStyle(
                color: Color(0xFFFFC857),
                fontWeight: FontWeight.bold,
                fontSize: 25)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 25, 4, 131),
        iconTheme: IconThemeData(
          color: Color(0xFFFFC857),
        ),
      ),
      body: Container(
        color: Color(0xFFFFC857),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 QUESTION COUNT
              Text("Score: $score", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                "Question ${currentIndex + 1} / ${questions.length}",
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 10),

              // 🔹 QUESTION
              Text(
                q["question"],
                style: const TextStyle(fontSize: 50),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 🔹 OPTIONS
              ...List<String>.from(q["options"]).asMap().entries.map((entry) {
                int index = entry.key;
                String opt = entry.value;

                Color color = Color.fromARGB(255, 244, 235, 216);

                if (answered) {
                  if (opt == q["answer"]) {
                    color = Colors.green; // ✅ correct
                  } else if (index == selectedIndex) {
                    color = Colors.red; // ❌ wrong selected
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () => checkAnswer(opt),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: Text(opt,style: TextStyle(fontSize: 25),),
                  ),
                );
              }).toList(),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentIndex > 0
                        ? () {
                      setState(() {
                        currentIndex--;
                        answered = false;
                        selectedIndex = null;
                      });
                    }
                        : null,
                    child: const Text("⬅ Previous"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentIndex < questions.length - 1) {
                        setState(() {
                          currentIndex++;
                          answered = false;
                          selectedIndex = null;
                        });
                      } else {
                        // 🔥 LAST QUESTION → GO RESULT PAGE
                        goToResultPage();
                      }
                    },
                    child: const Text("Next ➡"
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class BlinkingCongrats extends StatefulWidget {
  const BlinkingCongrats({super.key});

  @override
  _BlinkingCongratsState createState() => _BlinkingCongratsState();
}

class _BlinkingCongratsState extends State<BlinkingCongrats>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    opacity = Tween<double>(begin: 0.3, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Column(
        children: const [
          Text(
            "🎉 CONGRATULATIONS 🎉",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "🏆 New High Score!",
            style: TextStyle(
              fontSize: 22,
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final int bestScore;
  final bool isNewRecord;
  final String language;
  final int level;

  const ResultPage({
    Key? key,
    required this.score,
    required this.total,
    required this.bestScore,
    required this.isNewRecord,
    required this.language,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int finalBestScore = isNewRecord ? score : bestScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Result",
          style: TextStyle(
            color: Color(0xFFFFC857),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 25, 4, 131),
        iconTheme: const IconThemeData(
          color: Color(0xFFFFC857),
        ),
      ),

      body: Container(
        color: const Color(0xFFFFC857), // 🔥 SAME BACKGROUND
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🎯 SCORE
              Text(
                "Your Score: $score / $total",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 25, 4, 131),
                ),
              ),

              const SizedBox(height: 15),

              // 🏆 BEST SCORE
              Text(
                "Best Score: $finalBestScore",
                style: const TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 25, 4, 131),
                ),
              ),

              const SizedBox(height: 25),

              // 🎉 NEW RECORD
              if (isNewRecord) const BlinkingCongrats(),

              const SizedBox(height: 40),

              // 🔁 BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizStartPage(
                        language: language,
                      ), // 🔥 your language page
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 25, 4, 131),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  "Play Again",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFFFC857),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}