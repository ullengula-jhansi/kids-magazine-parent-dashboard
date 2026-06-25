import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'highlighting.dart';
import 'transliterate.dart';
import 'select.dart';
import 'custom_transliterate.dart';
import 'reading_tracker.dart';

bool isSwitched1 = false;
bool isSwitched2 = false;
bool isSwitched3 = true;

class Story extends StatefulWidget {
  final String storyID;
  Story(this.storyID);

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey transliterateKey = GlobalKey();
  GlobalKey audioKey = GlobalKey();

  CollectionReference stories =
  FirebaseFirestore.instance.collection('stories');

  FlutterTts flutterTts = FlutterTts();
  bool isLoggedIn = false;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();

    isLoggedIn = FirebaseAuth.instance.currentUser != null;

    _showTutorialIfNeeded();
    _configureTTS();
  }

  @override
  void dispose() {
    flutterTts.stop();
    ReadingSessionTracker.endSession();
    super.dispose();
  }

  void _configureTTS() {
    flutterTts.setStartHandler(() {});
    flutterTts.setCompletionHandler(() {});
    flutterTts.setCancelHandler(() {});
    flutterTts.setPauseHandler(() {});
    flutterTts.setContinueHandler(() {});
    flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
    });
  }

  Future<void> setTtsLanguage(String lang) async {
    switch (lang) {
      case "Gujarati":
        await flutterTts.setLanguage("gu-IN");
        break;
      case "Bengali":
        await flutterTts.setLanguage("bn-IN");
        break;
      case "Telugu":
        await flutterTts.setLanguage("te-IN");
        break;
      case "Marathi":
        await flutterTts.setLanguage("mr-IN");
        break;
      case "Hindi":
        await flutterTts.setLanguage("hi-IN");
        break;
      default:
        await flutterTts.setLanguage("en-US");
    }
  }

  void _showTutorialIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = prefs.getBool('tutorialShown2') ?? false;

    if (!shown && !isLoggedIn) {
      await Future.delayed(const Duration(milliseconds: 900));
      _initTutorialTargets();
      tutorialCoachMark = TutorialCoachMark(targets: targets);
      tutorialCoachMark!.show(context: context);

      prefs.setBool('tutorialShown2', true);
    }
  }

  void _initTutorialTargets() {
    targets = [
      TargetFocus(
        identify: "transliterate",
        keyTarget: transliterateKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Click this to see transliterated text.",
                onNext: controller.next,
                onSkip: controller.skip,
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "audio",
        keyTarget: audioKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Click here for audio options",
                onNext: controller.next,
                onSkip: controller.skip,
              );
            },
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: stories.doc(widget.storyID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text("Story not found"));
        }

        final data = snapshot.data!;
        String oText = data['original_text'];
        String tText = data['transliterated_text'];
        String language = data['language'];

        if (!_sessionStarted) {
          ReadingSessionTracker.startSession(
            storyId: widget.storyID,
            title: data['title'],
            language: language,
          );
          _sessionStarted = true;
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_sharp,
                color: Color(0xFFFFC857),
                size: 25,
              ),
              onPressed: () {
                flutterTts.stop();
                Navigator.pop(context);
              },
            ),
            backgroundColor: Color(0xFF00073e),
            title: Text(
              data['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFC857),
              ),
            ),
          ),
          body: Container(
            color: Color(0xFFFFC857),
            child: RawScrollbar(
              thumbColor: Colors.white70,
              thickness: 4,
              child: ListView(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 15),
                      _buildTopBar(context, oText, tText, language),
                      SizedBox(height: 10),
                      _buildStoryContent(oText, tText, language),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(
      BuildContext context, String oText, String tText, String language) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              FittedBox(
                key: audioKey,
                child: Text(
                  "Audio",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Amaranth',
                    color: Color(0xFF181621),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.volume_up,
                    size: 28, color: Color(0xFF181621)),
                onPressed: () {
                  flutterTts.stop();
                  _openAudioDialog(oText);
                },
              ),
            ],
          ),
          SizedBox(width: 25),
          Column(
            children: [
              Text(
                "Original",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Amaranth',
                  color: Color(0xFF181621),
                ),
              ),
              Switch(
                value: isSwitched3,
                onChanged: (v) => setState(() => isSwitched3 = v),
                activeTrackColor: Color(0xFF181621),
                activeColor: Colors.blue,
              ),
            ],
          ),
          SizedBox(width: 25),
          Column(
            children: [
              FittedBox(
                key: transliterateKey,
                child: Text(
                  "Transliteration",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Amaranth',
                    color: Color(0xFF181621),
                  ),
                ),
              ),
              Switch(
                value: isSwitched2,
                onChanged: (v) {
                  setState(() => isSwitched2 = v);

                  if (v) {
                    _updateTransliteration(language, oText);
                  }
                },
                activeTrackColor: Color(0xFF181621),
                activeColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateTransliteration(String lang, String original) {
    String newText = original;

    switch (lang) {
      case 'Telugu':
        newText = transliterateTelugu(original);
        break;
      case 'Bengali':
        newText = transliterateBengali(original);
        break;
      case 'Gujarati':
        newText = transliterateGujarati(original);
        break;
      case 'Marathi':
        newText = transliterateMarathi(original);
        break;
      case 'Hindi':
        newText = transliterateHindi(original);
        break;
    }

    FirebaseFirestore.instance
        .collection('stories')
        .doc(widget.storyID)
        .update({'transliterated_text': newText});
  }

  void _openAudioDialog(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              color: Color(0xFFFFC857),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Transliterate(widget.storyID, flutterTts, text),
          ),
        );
      },
    );
  }

  Widget _buildStoryContent(String oText, String tText, String language) {
    if (!isSwitched2 && isSwitched3) {
      return _buildOriginal(oText, language);
    } else if (!isSwitched2 && !isSwitched3) {
      return _buildOriginal(oText, language);
    } else if (isSwitched2 && !isSwitched3) {
      return _buildTransliterated(tText);
    } else {
      return _buildHighlighted(oText, tText, language);
    }
  }

  Widget _buildOriginal(String text, String language) {
    return _styledContainer(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: HighlightedText(
          text: text,
          flutterTts: flutterTts,
          language: language,
        ),
      ),
    );
  }

  Widget _buildTransliterated(String text) {
    return _styledContainer(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontFamily: 'JosefinSans'),
        ),
      ),
    );
  }

  Widget _buildHighlighted(String oText, String tText, String language) {
    return Column(
      children: [
        _styledContainer(
          heightFactor: 0.35,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: HighlightedText(
              text: oText,
              flutterTts: flutterTts,
              language: language,
            ),
          ),
        ),
        SizedBox(height: 15),
        _styledContainer(
          heightFactor: 0.35,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              tText,
              style: TextStyle(fontSize: 18, fontFamily: 'JosefinSans'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _styledContainer({
    required Widget child,
    double heightFactor = 0.74,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 238, 222, 187),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, -2),
            blurRadius: 15,
          ),
        ],
      ),
      child: RawScrollbar(
        thumbColor: Colors.black26,
        thickness: 4,
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}