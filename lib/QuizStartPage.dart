import 'package:flutter/material.dart';
import 'quiz_game_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class QuizStartPage extends StatefulWidget {
  final String language;

  const QuizStartPage({super.key, required this.language});

  @override
  State<QuizStartPage> createState() => _QuizStartPageState();
}

class _QuizStartPageState extends State<QuizStartPage> {
  String? selectedLanguage;
  TextEditingController levelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.language;
  }

  final List<String> languages = [
    "Hindi",
    "Bengali",
    "Gujarati",
    "Telugu",
    "Marathi"
  ];

  // ✅ FIRESTORE CHECK (CORRECT)
  Future<bool> checkIfDoneFirestore() async {
    if (selectedLanguage == null || levelController.text.isEmpty) {
      return false;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    int level = int.tryParse(levelController.text) ?? 1;

    var query = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attempts')
        .where('language', isEqualTo: selectedLanguage)
        .where('level', isEqualTo: level)
        .get();

    return query.docs.isNotEmpty;
  }

  void startQuiz() async {
    if (selectedLanguage == null || levelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select language & level")),
      );
      return;
    }

    int level = int.tryParse(levelController.text) ?? 1;

    bool alreadyDone = await checkIfDoneFirestore();

    if (alreadyDone) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Already Attempted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlinkingText("Already Attempted!"),
              const SizedBox(height: 10),
              const Text(
                "You have already completed this quiz.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizGamePage(
                      language: selectedLanguage!,
                      level: level,
                    ),
                  ),
                );
              },
              child: const Text("Improve"),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizGamePage(
            language: selectedLanguage!,
            level: level,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Start Quiz",
          style: TextStyle(color: Color(0xFFFFC857)),
        ),
        backgroundColor: Color(0xFF190483),
        iconTheme: const IconThemeData(color: Color(0xFFFFC857)),
      ),
      body: Container(
        color: const Color(0xFFFFC857),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedLanguage,
              items: languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value;
                });
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Enter Level (1 - 100)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: levelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter level number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            FutureBuilder<bool>(
              future: checkIfDoneFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                if (snapshot.data == true) {
                  return const Text(
                    "✅ Already Attempted",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  );
                }

                return const SizedBox();
              },
            ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF190483),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "PLAY",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  const BlinkingText(this.text, {super.key});

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
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
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}