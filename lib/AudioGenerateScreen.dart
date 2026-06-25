import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'custom_transliterate.dart';

class AudioGenerateScreen extends StatefulWidget {
  final String storyID;

  AudioGenerateScreen({required this.storyID});

  @override
  _AudioGenerateScreenState createState() => _AudioGenerateScreenState();
}

class _AudioGenerateScreenState extends State<AudioGenerateScreen> {
  String? originalText;
  String? language;
  String? transliteratedText;

  bool isLoading = false;
  bool isSwitched2 = false;

  CollectionReference stry = FirebaseFirestore.instance.collection('stories');

  AudioPlayer player = AudioPlayer();
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPlaying = false;

  String? audioPath;

  @override
  void initState() {
    super.initState();
    fetchStory();

    player.onDurationChanged.listen((Duration d) {
      setState(() => totalDuration = d);
    });

    player.onPositionChanged.listen((Duration p) {
      setState(() => currentPosition = p);
    });

    player.onPlayerStateChanged.listen((PlayerState state) {
      setState(() => isPlaying = (state == PlayerState.playing));
    });
  }

  /// ✅ Robust language mapping (FIXED)
  String getLanguageCode(String? language) {
    String lang = (language ?? "").trim().toLowerCase();

    switch (lang) {
      case 'bengali':
        return 'bn';
      case 'hindi':
        return 'hi';
      case 'marathi':
        return 'mr';
      case 'gujarati':
        return 'gu';
      case 'telugu':
        return 'te';
      default:
        return 'en'; // fallback
    }
  }

  /// ✅ Safe Firestore fetch (FIXED)
  Future<void> fetchStory() async {
    try {
      DocumentSnapshot storyDoc = await stry.doc(widget.storyID).get();

      if (storyDoc.exists) {
        setState(() {
          originalText = storyDoc['original_text'] ?? "";
          language = storyDoc['language'] ?? "";
        });

        // 🔍 Debug logs
        print("LANGUAGE: $language");
        print("TEXT: $originalText");
      }
    } catch (e) {
      print("Error fetching story: $e");
    }
  }

  /// ✅ Generate gTTS audio
  Future<void> generateSpeech() async {
    if (originalText == null || originalText!.trim().isEmpty) {
      print("No text available for TTS");
      return;
    }

    setState(() => isLoading = true);

    String languageCode = getLanguageCode(language);

    try {
      var url = Uri.parse(
          "https://flask-tts-backend-1.onrender.com/generate_speech");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": originalText,
          "language": languageCode,
        }),
      );

      if (response.statusCode == 200) {
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/output.mp3';

        File audioFile = File(filePath);
        await audioFile.writeAsBytes(response.bodyBytes);

        setState(() => audioPath = audioFile.path);

        await playAudio();
      } else {
        print("TTS API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error generating speech: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> playAudio() async {
    if (audioPath != null && await File(audioPath!).exists()) {
      await player.play(DeviceFileSource(audioPath!));
    }
  }

  Future<void> pauseAudio() async => await player.pause();

  Future<void> resumeAudio() async => await player.resume();

  Future<void> stopAudio() async {
    await player.stop();
    setState(() => currentPosition = Duration.zero);
  }

  @override
  void dispose() {
    stopAudio();
    player.dispose();
    super.dispose();
  }

  /// ✅ Transliteration logic
  void transliterateText(String selectedLanguage, String o_text) {
    switch (selectedLanguage.toLowerCase().trim()) {
      case 'bengali':
        transliteratedText = transliterateBengali(o_text);
        break;
      case 'hindi':
        transliteratedText = transliterateHindi(o_text);
        break;
      case 'marathi':
        transliteratedText = transliterateMarathi(o_text);
        break;
      case 'gujarati':
        transliteratedText = transliterateGujarati(o_text);
        break;
      case 'telugu':
        transliteratedText = transliterateTelugu(o_text);
        break;
      default:
        transliteratedText = "Language not supported";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
          Icon(Icons.arrow_back_ios_sharp, color: Color(0xFFFFC857)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF00073e),
        title: Text(
          "gTTS Audio",
          style: TextStyle(
            fontSize: 22.0,
            fontFamily: 'JosefinSans',
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFC857),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFFFC857),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🎯 Generate + Toggle
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : generateSpeech,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00073e),
                  ),
                  child: isLoading
                      ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text("Generate & Play Audio"),
                ),
                SizedBox(width: 10),
                Switch(
                  value: isSwitched2,
                  onChanged: (v) {
                    setState(() => isSwitched2 = v);
                    if (v && language != null) {
                      transliterateText(language!, originalText ?? "");
                    }
                  },
                  activeColor: Color(0xFF00073e),
                ),
              ],
            ),

            SizedBox(height: 20),

            /// 🎧 Controls
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isPlaying) {
                      pauseAudio();
                    } else {
                      if (currentPosition == Duration.zero) {
                        playAudio();
                      } else {
                        resumeAudio();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00073e),
                  ),
                  child: Text(isPlaying ? "Pause" : "Play"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: stopAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00073e),
                  ),
                  child: Text("Stop"),
                ),
              ],
            ),

            SizedBox(height: 20),

            /// 📖 Text display
            Expanded(
              child: isSwitched2
                  ? Column(
                children: [
                  Expanded(
                      child:
                      textBox("Original Text", originalText)),
                  Divider(),
                  Expanded(
                      child: textBox(
                          "Transliterated Text",
                          transliteratedText)),
                ],
              )
                  : textBox("Original Text", originalText),
            ),
          ],
        ),
      ),
    );
  }

  Widget textBox(String title, String? text) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFDF8E6),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00073e),
              ),
            ),
            SizedBox(height: 10),
            Text(
              text ?? "Loading...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}