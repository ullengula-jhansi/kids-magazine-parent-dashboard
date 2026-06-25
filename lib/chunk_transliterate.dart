import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Transliteratei extends StatefulWidget {
  final String storyID;
  final String text;
  final FlutterTts flutterTts;

  const Transliteratei(this.storyID, this.flutterTts, this.text);

  @override
  _TransliterateiState createState() => _TransliterateiState();
}

enum TtsState { playing, stopped }

class _TransliterateiState extends State<Transliteratei> {
  CollectionReference stories = FirebaseFirestore.instance.collection('stories');

  String? language;
  bool shouldStop = false;

  double volume = 0.7;
  double pitch = 1.0;
  double rate = 0.45;

  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();

    widget.flutterTts.setStartHandler(() {
      setState(() => ttsState = TtsState.playing);
    });

    widget.flutterTts.setCompletionHandler(() {
      setState(() => ttsState = TtsState.stopped);
    });

    widget.flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      setState(() => ttsState = TtsState.stopped);
    });
  }

  Future<void> _configureTts() async {
    await widget.flutterTts.setVolume(volume);
    await widget.flutterTts.setSpeechRate(rate);
    await widget.flutterTts.setPitch(pitch);
    await widget.flutterTts.awaitSpeakCompletion(true);

    // Language mapping
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
  }

  Future<void> speak() async {
    if (widget.text.isEmpty) return;

    await _configureTts();
    shouldStop = false;

    const int maxChunk = 3500;
    int length = widget.text.length;
    int loops = (length / maxChunk).ceil();

    for (int i = 0; i < loops; i++) {
      if (shouldStop) break;

      int start = i * maxChunk;
      int end = (i + 1) * maxChunk;
      if (end > length) end = length;

      String chunk = widget.text.substring(start, end);

      bool chunkDone = false;

      widget.flutterTts.setCompletionHandler(() {
        chunkDone = true;
      });

      await widget.flutterTts.speak(chunk);

      // Wait until this chunk finishes
      while (!chunkDone && !shouldStop) {
        await Future.delayed(Duration(milliseconds: 120));
      }

      if (shouldStop) break;
    }

    await widget.flutterTts.stop();
    setState(() => ttsState = TtsState.stopped);
  }

  Future<void> stopSpeaking() async {
    shouldStop = true;
    await widget.flutterTts.stop();
    setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: stories.doc(widget.storyID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        language = snapshot.data!['language'];

        return Column(
          children: [
            // 🔊 Sliders (same UI)
            const Text("Volume 🔊"),
            Slider(
              value: volume,
              onChanged: (v) => setState(() => volume = v),
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: Color(0xFF181621),
            ),

            const Text("Pitch 〰️"),
            Slider(
              value: pitch,
              onChanged: (v) => setState(() => pitch = v),
              min: 0.5,
              max: 2.0,
              divisions: 10,
              activeColor: Color(0xFF181621),
            ),

            const Text("Speed 🚄"),
            Slider(
              value: rate,
              onChanged: (v) => setState(() => rate = v),
              min: 0,
              max: 1.5,
              divisions: 10,
              activeColor: Color(0xFF181621),
            ),

            const SizedBox(height: 10),

            // 🔵 Buttons (same UI)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "play_chunk",
                  onPressed: speak,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.play_arrow),
                ),
                FloatingActionButton(
                  heroTag: "stop_chunk",
                  onPressed: stopSpeaking,
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