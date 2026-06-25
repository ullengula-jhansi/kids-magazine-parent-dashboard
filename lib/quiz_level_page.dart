import 'package:flutter/material.dart';
import 'quiz_game_page.dart';
import 'quiz_data.dart';


class QuizLevelPage extends StatelessWidget {
  final String language;

  const QuizLevelPage({
    Key? key,
    required this.language,
  }) : super(key: key);

  // 🚀 Navigate to Quiz Page
  void goToQuiz(BuildContext context, int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizGamePage(
          language: language,
          level: level, // ✅ int now
        ),
      ),
    );
  }


  Widget buildButton(BuildContext context, int level) {
    return GestureDetector(
      onTap: () => goToQuiz(context, level),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        width: 250,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 25, 4, 131),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Center(
          child: Text(
            "Level $level",
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 TEMP: assume 10 levels (you can make dynamic later)
    int totalQuestions = quizData[language.toLowerCase()]?.length ?? 0;
    int totalLevels = (totalQuestions / 10).ceil();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Level",
          style: TextStyle(
            color: Color.fromARGB(255, 242, 193, 96),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 4, 131),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 242, 193, 96),
        ),
      ),

      // ✅ SIMPLE CLEAN BODY
      body: Container(
        color: const Color(0xFFFFC857),
        child: ListView.builder(
          itemCount: totalLevels,
          itemBuilder: (context, index) {
            return buildButton(context, index + 1);
          },
        ),
      ),
    );
  }
}