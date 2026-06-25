import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ReadingSessionTracker {
  static DateTime? sessionStart;
  static String? _storyId;
  static String? _title;
  static String? _language;

  static void startSession({
    required String storyId,
    required String title,
    required String language,
  }) {
    sessionStart = DateTime.now(); // ✅ FIXED
    _storyId = storyId;
    _title = title;
    _language = language;
  }

  static Future<void> endSession({bool skipWrite = false}) async {
    if (sessionStart == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final duration =
        DateTime.now().difference(sessionStart!).inMinutes;

    if (!skipWrite) {
      await FirebaseFirestore.instance
          .collection('reading_sessions')
          .add({
        'uid': user.uid,
        'story_id': _storyId,
        'story_title': _title,
        'language': _language?.toString().trim(),
        'duration_minutes': duration,
        'timestamp': Timestamp.now(),
        'is_live': false,
      });
    }

    sessionStart = null;
  }
}