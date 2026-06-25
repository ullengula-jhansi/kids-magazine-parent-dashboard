import 'package:flutter/material.dart';
import 'package:kids_magazine/select.dart';
import 'package:kids_magazine/quiz_length_select.dart';

class QuizResultPage extends StatelessWidget {

  final int score;
  final int total;
  final bool isScoreMode;
  final int correctAnswers;

  const QuizResultPage(
      this.score,
      this.total,
      this.isScoreMode,
      this.correctAnswers,
      {super.key}
      );

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF9C55E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF190483),
        title: const Text(
          "Quiz Result",
          style: TextStyle(
            fontFamily: 'Amaranth',
            color: Color(0xFFF9D07D),
          ),
        ),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.black,
            ),

            const SizedBox(height: 20),

            const Text(
              "Result",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 RESULT DISPLAY
            Column(
              children: [

                /// 🧠 Practice Mode
                if (!isScoreMode)
                  Text(
                    "Correct Answers: $correctAnswers / $total",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                /// 🎮 Score Mode
                if (isScoreMode) ...[
                  Text(
                    "Correct Answers: $correctAnswers / $total",
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Total Points: $score",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

              ],
            ),

            const SizedBox(height: 50),

            /// TAKE ANOTHER QUIZ
            SizedBox(
              width: 230,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizLengthSelect(),
                    ),
                  );
                },

                child: const Text(
                  "Take Another Quiz",
                  style: TextStyle(fontSize: 18),
                ),

              ),
            ),

            const SizedBox(height: 20),

            /// BACK TO HOME
            SizedBox(
              width: 230,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF190483),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: () {

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectLanguage(),
                    ),
                        (route) => false,
                  );

                },

                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 18),
                ),

              ),
            ),

          ],

        ),

      ),

    );

  }

}