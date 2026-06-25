import 'package:flutter/material.dart';
import 'quiz_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'progress_page.dart';
import 'quiz_length_select.dart';
import 'Quiz_type.dart';
class QuizLengthSelect extends StatefulWidget {
  @override
  State<QuizLengthSelect> createState() => _QuizLengthSelectState();
}

class _QuizLengthSelectState extends State<QuizLengthSelect> {

  String selectedLanguage = "Hindi";
  int selectedLength = 5;
  String selectedDifficulty = "Easy";
  bool isScoreMode = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Color(0xFFF9C55E),

      appBar: AppBar(
        backgroundColor: Color(0xFF190483),
        iconTheme: IconThemeData(
          color: Color(0xFFF9C55E), // 👈 yellow back arrow
        ),
        title: Text("Vocabulary Quiz",
          style: TextStyle(
            color: Color(0xFFF9C55E), // yellow color
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🌍 LANGUAGE
            Text(
              "Language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  )
                ],
              ),
              child: DropdownButton<String>(
                value: selectedLanguage,
                isExpanded: true,
                underline: SizedBox(),
                items: ["Hindi","Bengali","Gujarati","Marathi","Telugu"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
                    .toList(),
                onChanged: (value){
                  setState(() {
                    selectedLanguage = value!;
                  });
                },
              ),
            ),

            SizedBox(height: 25),

            /// 🔢 NUMBER OF QUESTIONS
            Text(
              "Number of Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  )
                ],
              ),
              child: DropdownButton<int>(
                value: selectedLength,
                isExpanded: true,
                underline: SizedBox(),
                items: [5,10,15].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text("$e Questions"),
                  );
                }).toList(),
                onChanged: (value){
                  setState(() {
                    selectedLength = value!;
                  });
                },
              ),
            ),

            SizedBox(height: 25),

            /// 🎯 DIFFICULTY
            Text(
              "Difficulty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  )
                ],
              ),
              child: DropdownButton<String>(
                value: selectedDifficulty,
                isExpanded: true,
                underline: SizedBox(),
                items: ["Easy","Medium","Hard"].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value){
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
              ),
            ),

            SizedBox(height: 25),

            /// 🎮 MODE
            Text(
              "Mode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            SwitchListTile(
              title: Text(isScoreMode ? "Quiz Mode " : "Practice Mode "),
              value: isScoreMode,
              onChanged: (value){
                setState(() {
                  isScoreMode = value;
                });
              },
            ),

            SizedBox(height: 40),

            /// ▶️ START BUTTON
            Center(
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF190483),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),

                onPressed: () {

                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {

                    /// ❌ NOT LOGGED IN
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Login Required"),
                        content: Text("Please login to play quiz"),
                        actions: [

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("OK"),
                          ),

                        ],
                      ),
                    );

                    return;
                  }

                  /// ✅ LOGGED IN → START QUIZ
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizPage(
                        selectedLanguage,
                        selectedLength,
                        isScoreMode,
                        selectedDifficulty,
                      ),
                    ),
                  );

                },

                child: Text(
                  "Start",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}