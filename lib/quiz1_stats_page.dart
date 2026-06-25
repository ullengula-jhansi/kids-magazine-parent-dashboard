import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz1StatsPage extends StatefulWidget {
  const Quiz1StatsPage({super.key});

  @override
  State<Quiz1StatsPage> createState() => _Quiz1StatsPageState();
}

class _Quiz1StatsPageState extends State<Quiz1StatsPage> {
  int totalQuizzes = 0;
  int totalScore = 0;
  double average = 0;

  Map<String, Map<String, int>> languageStats = {};

  @override
  void initState() {
    super.initState();
    loadStatsFromFirestore();
  }

  Future<void> loadStatsFromFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    var data = doc.data();

    if (data == null) return;

    // 🔹 overall
    int quizzes = data['totalQuizzes'] ?? 0;
    int score = data['totalScore'] ?? 0;

    // 🔹 language stats
    Map<String, dynamic> langs = data['languages'] ?? {};

    Map<String, Map<String, int>> tempStats = {};

    langs.forEach((key, value) {
      tempStats[key] = {
        "score": value['score'] ?? 0,
        "quizzes": value['quizzes'] ?? 0,
      };
    });

    setState(() {
      totalQuizzes = quizzes;
      totalScore = score;
      average = quizzes == 0 ? 0 : score / quizzes;
      languageStats = tempStats;
    });
  }

  Widget statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC857),

      appBar: AppBar(
        backgroundColor: const Color(0xFF190483),
        title: const Text(
          "Quiz Stats",
          style: TextStyle(color: Color(0xFFFFC857)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFC857)),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),

            /// 🔵 OVERALL STATS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF190483),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  const Text(
                    "Overall Stats",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC857),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      statCard("Quizzes", totalQuizzes.toString()),
                      statCard("Score", totalScore.toString()),
                      statCard("Avg", average.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🌍 LANGUAGE STATS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF190483),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  const Text(
                    "Language Stats",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC857),
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (languageStats.isEmpty)
                    const CircularProgressIndicator(
                      color: Color(0xFFFFC857),
                    )
                  else
                    Column(
                      children: languageStats.entries.map((entry) {
                        String lang = entry.key.toUpperCase();
                        int score = entry.value["score"]!;
                        int quizzes = entry.value["quizzes"]!;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFFFC857),
                                ),
                              ),
                              Text(
                                "Score: $score | Q: $quizzes",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}