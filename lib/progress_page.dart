import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String _monthName(int month) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month];
  }
  bool isScoreModeSelected = true;
  String selectedLanguage = "all";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9C55E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF190483),
        iconTheme: IconThemeData(
          color: Color(0xFFF9C55E), // 👈 yellow back arrow
        ),
        title: const Text("Stats",
          style: TextStyle(
            color: Color(0xFFF9C55E), // yellow color
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          int scorePlayed = data["scoreModePlayed"] ?? 0;
          int practicePlayed = data["practiceModePlayed"] ?? 0;

          List history = data["history"] ?? [];

          String selectedMode = isScoreModeSelected ? "score" : "practice";

          int todayCount = history.where((quiz) {
            if (quiz["mode"] != selectedMode) return false;

            DateTime dt =
                DateTime.tryParse(quiz["date"] ?? "") ?? DateTime(2000);

            final now = DateTime.now();

            return dt.year == now.year &&
                dt.month == now.month &&
                dt.day == now.day;
          }).length;

          Set<String> languages = {
            "Hindi",
            "Bengali",
            "Gujarati",
            "Marathi",
            "Telugu",
          };

          /// FILTER HISTORY
          List filteredHistory = history.where((quiz) {
            final matchesMode = quiz["mode"] == selectedMode;

            if (selectedLanguage == "all") return matchesMode;

            return matchesMode &&
                quiz["language"] == selectedLanguage;
          }).toList();

          filteredHistory = filteredHistory.reversed.toList();
          List recentHistory = filteredHistory.take(10).toList();

          /// AVG SCORE
          double avgScore = 0;
          if (filteredHistory.isNotEmpty) {
            double total = 0;
            for (var quiz in filteredHistory) {
              total += (quiz["score"] ?? 0);
            }
            avgScore = total / filteredHistory.length;
          }

          /// BEST SESSION
          Map<String, dynamic>? bestQuiz;

          for (var quiz in history.where((q) => q["mode"] == selectedMode)) {
            if (bestQuiz == null) {
              bestQuiz = quiz;
            } else {
              int currentScore = quiz["score"] ?? 0;
              int bestScore = bestQuiz["score"] ?? 0;

              int currentMax =
                  quiz["maxScore"] ?? ((quiz["total"] ?? 0) * 5);
              int bestMax =
                  bestQuiz["maxScore"] ?? ((bestQuiz["total"] ?? 0) * 5);

              double currentPercent =
              currentMax != 0 ? currentScore / currentMax : 0;

              double bestPercent =
              bestMax != 0 ? bestScore / bestMax : 0;

              if (currentPercent > bestPercent) {
                bestQuiz = quiz;
              } else if (currentPercent == bestPercent) {
                if (currentScore > bestScore) {
                  bestQuiz = quiz;
                } else if (currentScore == bestScore) {
                  DateTime currentDate =
                      DateTime.tryParse(quiz["date"] ?? "") ??
                          DateTime(2000);
                  DateTime bestDate =
                      DateTime.tryParse(bestQuiz["date"] ?? "") ??
                          DateTime(2000);

                  if (currentDate.isAfter(bestDate)) {
                    bestQuiz = quiz;
                  }
                }
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                /// MODE TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isScoreModeSelected
                            ? const Color(0xFF190483)
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isScoreModeSelected = true;
                        });
                      },
                      child: const Text("Quiz Mode"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isScoreModeSelected
                            ? const Color(0xFF190483)
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isScoreModeSelected = false;
                        });
                      },
                      child: const Text("Practice Mode"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// PRACTICE MODE
                if (!isScoreModeSelected) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF190483),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        /// HEADER (centered + emoji)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("📊 ", style: TextStyle(fontSize: 16)),
                            Text(
                              "Sessions Played",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// SPLIT ROW
                        Row(
                          children: [

                            /// LEFT (Total)
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    practicePlayed.toString(),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// DIVIDER
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),

                            /// RIGHT (Today)
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    todayCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Today",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (bestQuiz != null)
                    _buildBestCard(bestQuiz, false)
                  else
                    _buildCard("Best Session", "No data"),
                ],

                /// SCORE MODE
                if (isScoreModeSelected) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF190483),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        /// HEADER (centered + emoji)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("📊 ", style: TextStyle(fontSize: 16)),
                            Text(
                              "Quizzes Played",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// SPLIT ROW
                        Row(
                          children: [

                            /// LEFT (Total)
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    scorePlayed.toString(),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// DIVIDER
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),

                            /// RIGHT (Today)
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    todayCount.toString(),
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Today",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (bestQuiz != null)
                    _buildBestCard(bestQuiz, true)
                  else
                    _buildCard("Best Score", "No data"),
                ],

                const SizedBox(height: 30),

                Text(
                  isScoreModeSelected ? "Recent Quizzes" : "Recent Sessions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),

                const SizedBox(height: 10),

                /// LANGUAGE FILTER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(
                        value: "all",
                        child: Text("All Languages"),
                      ),
                      ...languages.map((lang) =>
                          DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                if (recentHistory.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "No quizzes for this language",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),

                ...recentHistory.map((quiz) {
                  DateTime? dt =
                  DateTime.tryParse(quiz["date"] ?? "");

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF190483).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              isScoreModeSelected
                                  ? "Correct: ${(quiz["score"] ?? 0) ~/ 5} / ${quiz["total"]}"
                                  : "${quiz["score"]} / ${quiz["total"]}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF190483),
                              ),
                            ),
                            Text(
                              isScoreModeSelected
                                  ? "Score: ${quiz["score"]} / ${quiz["maxScore"] ?? ((quiz["total"] ?? 0) * 5)} pts"
                                  : (quiz["total"] != 0
                                  ? "Accuracy: ${((quiz["score"] / quiz["total"]) * 100).toStringAsFixed(1)}%"
                                  : "Accuracy: 0%"),
                            ),
                          ],
                        ),
                        Text(
                          dt != null
                              ? "${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}"
                              : "No date",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF190483),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestCard(Map<String, dynamic> quiz, bool isScore) {
    DateTime dt =
        DateTime.tryParse(quiz["date"] ?? "") ?? DateTime(2000);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF190483),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 HEADER (title + date + language)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isScore ? "🏆 Best Score" : "🔥 Best Session",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${dt.day} ${_monthName(dt.month)}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "${quiz["language"] ?? ""}",
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔵 SCORE MODE
          if (isScore) ...[
            Text(
              "${quiz["score"]} / ${quiz["maxScore"] ?? ((quiz["total"] ?? 0) * 5)} pts",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              "Correct: ${(quiz["score"] ?? 0) ~/ 5} / ${quiz["total"]}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 3),

            Text(
              "Score: ${(((quiz["score"] ?? 0) /
                  ((quiz["maxScore"] ?? ((quiz["total"] ?? 0) * 5)) == 0
                      ? 1
                      : (quiz["maxScore"] ?? ((quiz["total"] ?? 0) * 5)))) *
                  100).toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],

          /// 🟢 PRACTICE MODE
          if (!isScore) ...[
            Text(
              "Correct: ${quiz["score"]} / ${quiz["total"]}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              "Accuracy: ${((quiz["total"] != 0
                  ? ((quiz["score"] ?? 0) / quiz["total"])
                  : 0) *
                  100).toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }
}