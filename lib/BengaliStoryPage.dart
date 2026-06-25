import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'custom_transliterate.dart';
import 'highlighting.dart';
import 'select.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'story.dart';
import 'AudioGenerateScreen.dart';
import 'forverylong.dart';

bool isSwitched2 = false;
bool isSwitched3 = true;

class BengaliStory extends StatefulWidget {
  final String storyID;

  BengaliStory(this.storyID, {Key? key}) : super(key: key);

  @override
  _BengaliStoryState createState() => _BengaliStoryState();
}

class _BengaliStoryState extends State<BengaliStory> {
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey transliterateKey = GlobalKey();
  GlobalKey audioKey = GlobalKey();

  bool isLoggedIn = false;
  CollectionReference stry = FirebaseFirestore.instance.collection('stories');
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    isLoggedIn = FirebaseAuth.instance.currentUser != null;

    Future.delayed(Duration(milliseconds: 600), () {
      _showTutorialCoachmark();
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _showTutorialCoachmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = prefs.getBool('tutorialShown2') ?? false;

    if (!shown) {
      _initTarget();
      tutorialCoachMark = TutorialCoachMark(targets: targets);
      tutorialCoachMark!.show(context: context);
      prefs.setBool('tutorialShown2', true);
    }
  }

  void _initTarget() {
    targets = [
      TargetFocus(identify: "audio", keyTarget: audioKey, contents: [
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
      ]),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: stry.doc(widget.storyID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var data = snapshot.data!;
        String o_text = data['original_text'] ?? "";
        String t_text = data['transliterated_text'] ?? "";
        String lang = data['language'] ?? "";

        return Scaffold(
          backgroundColor: Color.fromARGB(255, 242, 193, 96),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 25, 4, 131),
            iconTheme: const IconThemeData(
              color: Colors.white, // makes back arrow white
            ),
            title: Text(
              data['title'] ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Container(
            color: Color.fromARGB(255, 242, 193, 96),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15),
                  _buildHeader(context, o_text),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _buildStoryBody(o_text, t_text, lang),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String o_text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text("Audio"),
            IconButton(
              key: audioKey,
              icon: Icon(Icons.volume_up),
              onPressed: () => _showAudioOptions(context, o_text),
            ),
          ],
        ),
        SizedBox(width: 30),
        Column(
          children: [
            Text("Original"),
            Switch(
              value: isSwitched3,
              onChanged: (v) => setState(() => isSwitched3 = v),
            ),
          ],
        ),
        SizedBox(width: 30),
        Column(
          children: [
            Text("Transliteration"),
            Switch(
              key: transliterateKey,
              value: isSwitched2,
              onChanged: (v) => setState(() => isSwitched2 = v),
            ),
          ],
        ),
      ],
    );
  }

  void _showAudioOptions(BuildContext context, String text) async {
    DocumentSnapshot storyDoc =
    await FirebaseFirestore.instance.collection('stories').doc(widget.storyID).get();

    String? language = storyDoc['language'];
    String? originalText = storyDoc['original_text'];

    print("==== DEBUG START ====");
    print("StoryID: ${widget.storyID}");
    print("LANGUAGE: '$language'");
    print("TEXT: '$originalText'");
    print("LANGUAGE EMPTY: ${language?.trim().isEmpty}");
    print("TEXT EMPTY: ${originalText?.trim().isEmpty}");
    print("=====================");

    bool gttsAvailable =
        language != null &&
            originalText != null &&
            language.toString().trim().isNotEmpty &&
            originalText.toString().trim().isNotEmpty;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Choose Audio Option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Audio + Highlighting"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Story(widget.storyID)),
              ),
            ),
            if (gttsAvailable)
              ListTile(
                title: Text("gTTS Audio + Transliteration"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AudioGenerateScreen(storyID: widget.storyID),
                  ),
                ),
              )
            else
              ListTile(
                title: Text("gTTS not available"),
                enabled: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryBody(String o_text, String t_text, String lang) {
    if (isSwitched3 && !isSwitched2) {
      return HighlightedText(
        text: o_text,
        flutterTts: flutterTts,
        language: lang,
      );
    }

    if (!isSwitched3 && isSwitched2) {
      return Text(t_text);
    }

    if (isSwitched3 && isSwitched2) {
      return Column(
        children: [
          HighlightedText(
            text: o_text,
            flutterTts: flutterTts,
            language: lang,
          ),
          Divider(),
          Text(t_text),
        ],
      );
    }

    return Text(o_text);
  }
}