import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Storyi extends StatefulWidget {
  final String storyID;
  final String storyText;
  final String language;
  final FlutterTts flutterTts;

  Storyi({
    required this.storyID,
    required this.storyText,
    required this.language,
    required this.flutterTts,
  });

  @override
  _StoryiState createState() => _StoryiState();
}

class _StoryiState extends State<Storyi> {
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;

  bool isPlaying = false;
  bool shouldStop = false;

  List<String> chunks = [];

  @override
  void initState() {
    super.initState();
    _prepareChunks();
    _configureHandlers();
  }

  @override
  void dispose() {
    widget.flutterTts.stop();
    super.dispose();
  }

  /// -----------------------------
  /// 1. SPLIT STORY INTO CHUNKS
  /// -----------------------------
  void _prepareChunks() {
    const int max = 3500; // safe limit for FlutterTTS

    String text = widget.storyText;
    chunks.clear();

    for (int i = 0; i < text.length; i += max) {
      int end = (i + max < text.length) ? i + max : text.length;
      chunks.add(text.substring(i, end));
    }
  }

  /// -----------------------------
  /// 2. CONFIGURE TTS HANDLERS
  /// -----------------------------
  void _configureHandlers() {
    widget.flutterTts.setStartHandler(() {
      setState(() => isPlaying = true);
    });

    widget.flutterTts.setCompletionHandler(() {
      setState(() => isPlaying = false);
    });

    widget.flutterTts.setCancelHandler(() {
      setState(() => isPlaying = false);
    });

    widget.flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      setState(() => isPlaying = false);
    });
  }

  /// -----------------------------
  /// 3. SET LANGUAGE CODE
  /// -----------------------------
  Future<void> _setLanguage() async {
    switch (widget.language) {
      case "Bengali":
        await widget.flutterTts.setLanguage("bn-IN");
        break;
      case "Hindi":
        await widget.flutterTts.setLanguage("hi-IN");
        break;
      case "Gujarati":
        await widget.flutterTts.setLanguage("gu-IN");
        break;
      case "Marathi":
        await widget.flutterTts.setLanguage("mr-IN");
        break;
      case "Telugu":
        await widget.flutterTts.setLanguage("te-IN");
        break;
      default:
        await widget.flutterTts.setLanguage("en-US");
    }
  }

  /// -----------------------------
  /// 4. START SPEAKING ALL CHUNKS
  /// -----------------------------
  Future<void> speak() async {
    await _setLanguage();

    await widget.flutterTts.setVolume(volume);
    await widget.flutterTts.setSpeechRate(rate);
    await widget.flutterTts.setPitch(pitch);

    shouldStop = false;

    for (String chunk in chunks) {
      if (shouldStop) break;

      bool completed = false;

      widget.flutterTts.setCompletionHandler(() {
        completed = true;
      });

      await widget.flutterTts.speak(chunk);

      while (!completed && !shouldStop) {
        await Future.delayed(Duration(milliseconds: 120));
      }
    }

    setState(() => isPlaying = false);
  }

  /// -----------------------------
  /// 5. STOP SPEAKING
  /// -----------------------------
  Future<void> stop() async {
    shouldStop = true;
    await widget.flutterTts.stop();
    setState(() => isPlaying = false);
  }

  /// -----------------------------
  /// 6. UI — KEEP SAME VISUAL DESIGN
  /// -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Story", style: TextStyle(color: Color(0xFFFFC857))),
        backgroundColor: Color(0xFF00073e),
        iconTheme: IconThemeData(color: Color(0xFFFFC857)),
      ),
      body: Container(
        color: Color(0xFFFFC857),
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildSlider("Volume", volume, (v) => setState(() => volume = v)),
            _buildSlider("Pitch", pitch, (v) => setState(() => pitch = v),
                min: 0.5, max: 2.0),
            _buildSlider("Speed", rate, (v) => setState(() => rate = v),
                min: 0.0, max: 1.0),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: isPlaying ? null : speak,
                  heroTag: "play_long",
                  backgroundColor: Colors.green,
                  child: Icon(Icons.play_arrow),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: stop,
                  heroTag: "stop_long",
                  backgroundColor: Colors.red,
                  child: Icon(Icons.stop),
                ),
              ],
            ),

            SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.storyText,
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.4,
                      color: Color(0xFF181621),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, Function(double) onChanged,
      {double min = 0.0, double max = 1.0}) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181621))),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          divisions: 10,
          activeColor: Color(0xFF181621),
        ),
      ],
    );
  }
}