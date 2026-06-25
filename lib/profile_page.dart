import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz1_stats_page.dart';
import 'progress_page.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// ✅ LANGUAGE SCORE FUNCTION (NO CHANGE)
Future<Map<String, Map<String, int>>> getLanguageStats() async {
  final prefs = await SharedPreferences.getInstance();

  List<String> languages = [
    "hindi",
    "bengali",
    "gujarati",
    "telugu",
    "marathi"
  ];

  Map<String, Map<String, int>> stats = {};

  for (String lang in languages) {
    stats[lang] = {
      "score": prefs.getInt("${lang}_score") ?? 0,
      "quizzes": prefs.getInt("${lang}_quizzes") ?? 0,
    };
  }

  return stats;
}

class _ProfilePageState extends State<ProfilePage> {
  int totalQuizzes = 0;
  int totalScore = 0;
  double average = 0;

  // 🔹 OLD FUNCTION (unchanged)
  Widget statBox(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFFFC857),
          ),
        ),
      ],
    );
  }

  // ✅ NEW FUNCTION (UBHARA HUA CARD)
  Widget statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String userName = "";
  int userAge = 0;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    int quizzes = prefs.getInt('total_quizzes') ?? 0;
    int score = prefs.getInt('total_score') ?? 0;

    String name = prefs.getString('user_name') ?? "Guest";
    int age = prefs.getInt('user_age') ?? 0;

    setState(() {
      totalQuizzes = quizzes;
      totalScore = score;
      average = quizzes == 0 ? 0.0 : (score / quizzes);

      userName = name;
      userAge = age;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFFFFC857),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 4, 131),
        iconTheme: const IconThemeData(
          color: Color(0xFFFFC857),
        ),
      ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity, // ✅ FULL HEIGHT FIX
          child: Container(
            color: const Color(0xFFFFC857),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ VERY IMPORTANT
            children: [

              const SizedBox(height: 20),

              // 👤 PROFILE HEADER CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 25, 4, 131),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? "Guest User",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFC857),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? "No Email",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
// 📊 QUIZ OPTIONS CARD
              // 📊 QUIZ OPTIONS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 25, 4, 131),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    const Text(
                      "Quiz Statistics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFC857),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ✅ QUIZ 1 (OLD)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Quiz1StatsPage(),
                          ),
                        );
                      },
                      child: const Text("Pronunciation Quiz Stats"),
                    ),

                    const SizedBox(height: 15),

                    /// ✅ QUIZ 2 (NEW FIREBASE)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProgressPage(),
                          ),
                        );
                      },
                      child: const Text("Vocabulary Quiz Stats"),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 20),






              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 25, 4, 131),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFC857),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
    );
  }
}