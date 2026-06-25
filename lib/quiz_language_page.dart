import 'package:flutter/material.dart';
import 'quiz_level_page.dart';
import 'profile_page.dart';
class QuizLanguagePage extends StatelessWidget {
  const QuizLanguagePage({super.key});

  void goToLevel(BuildContext context, String language) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizLevelPage(language: language),
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Color color) {
    return GestureDetector(
      onTap: () => goToLevel(context, text),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(18),
        width: 260,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: const Color.fromARGB(255, 6, 0, 0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Language",
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildButton(
                  context, "Bengali", Color.fromARGB(255, 244, 235, 216)),
              buildButton(
                  context, "Gujarati", Color.fromARGB(255, 244, 235, 216)),
              buildButton(
                  context, "Telugu", Color.fromARGB(255, 244, 235, 216)),
              buildButton(
                  context, "Marathi", Color.fromARGB(255, 244, 235, 216)),
              buildButton(context, "Hindi", Color.fromARGB(255, 244, 235, 216)),
            ],
          ),
        ),
      ),
    );
  }
}
