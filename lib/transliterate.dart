import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Transliterate extends StatefulWidget {
  final String storyID;
  final String text;
  final FlutterTts flutterTts;

  const Transliterate(this.storyID, this.flutterTts, this.text);

  @override
  _TransliterateState createState() => _TransliterateState();
}

enum TtsState { playing, stopped, paused, continued }

class _TransliterateState extends State<Transliterate> {
  CollectionReference stry = FirebaseFirestore.instance.collection('stories');

  String? language;

  double volume = 0.7;
  double pitch = 1.0;
  double rate = 0.45;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;

  @override
  void initState() {
    super.initState();
    _initTtsHandlers();
  }

  void _initTtsHandlers() {
    widget.flutterTts.setStartHandler(() {
      setState(() => ttsState = TtsState.playing);
    });

    widget.flutterTts.setCompletionHandler(() {
      setState(() => ttsState = TtsState.stopped);
    });

    widget.flutterTts.setPauseHandler(() {
      setState(() => ttsState = TtsState.paused);
    });

    widget.flutterTts.setContinueHandler(() {
      setState(() => ttsState = TtsState.continued);
    });

    widget.flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      setState(() => ttsState = TtsState.stopped);
    });
  }

  Future<void> _speak() async {
    if (widget.text.isEmpty) return;

    try {
      // Stop any ongoing speech first
      await widget.flutterTts.stop();

      // Apply TTS settings
      await widget.flutterTts.setVolume(volume);
      await widget.flutterTts.setSpeechRate(rate);
      await widget.flutterTts.setPitch(pitch);
      await widget.flutterTts.awaitSpeakCompletion(true);

      // Language setup
      switch (language) {
        case "Gujarati":
          await widget.flutterTts.setLanguage("gu-IN");
          break;
        case "Bengali":
          await widget.flutterTts.setLanguage("bn-IN");
          break;
        case "Telugu":
          await widget.flutterTts.setLanguage("te-IN");
          break;
        case "Marathi":
          await widget.flutterTts.setLanguage("mr-IN");
          break;
        case "Hindi":
          await widget.flutterTts.setLanguage("hi-IN");
          break;
        default:
          await widget.flutterTts.setLanguage("en-US");
      }

      // Start speaking
      await widget.flutterTts.speak(widget.text);
      setState(() => ttsState = TtsState.playing);
    } catch (e) {
      print("TTS Error: $e");
      setState(() => ttsState = TtsState.stopped);
    }
  }

  Future<void> _stop() async {
    final result = await widget.flutterTts.stop();
    if (result == 1) {
      setState(() => ttsState = TtsState.stopped);
    }
  }

  Future<void> _pause() async {
    final result = await widget.flutterTts.pause();
    if (result == 1) {
      setState(() => ttsState = TtsState.paused);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: stry.doc(widget.storyID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        language = snapshot.data!['language'];

        return Column(
          children: [
            // Volume slider
            Row(
              children: [
                const Text("Volume 🔊"),
                Expanded(
                  child: Slider(
                    value: volume,
                    onChanged: (v) => setState(() => volume = v),
                    min: 0,
                    max: 1,
                    divisions: 10,
                    activeColor: Color(0xFF181621),
                  ),
                ),
              ],
            ),

            // Pitch slider
            Row(
              children: [
                const Text("Pitch 〰️"),
                Expanded(
                  child: Slider(
                    value: pitch,
                    onChanged: (v) => setState(() => pitch = v),
                    min: 0.5,
                    max: 2,
                    divisions: 10,
                    activeColor: Color(0xFF181621),
                  ),
                ),
              ],
            ),

            // Rate slider
            Row(
              children: [
                const Text("Speed 🚄"),
                Expanded(
                  child: Slider(
                    value: rate,
                    onChanged: (v) => setState(() => rate = v),
                    min: 0.0,
                    max: 1.5,
                    divisions: 10,
                    activeColor: Color(0xFF181621),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Audio Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "playBtn",
                  onPressed: _speak,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.play_arrow),
                ),
                FloatingActionButton(
                  heroTag: "pauseBtn",
                  onPressed: _pause,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.pause),
                ),
                FloatingActionButton(
                  heroTag: "stopBtn",
                  onPressed: _stop,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}