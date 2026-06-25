import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_magazine/home.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class SelectLanguage extends StatefulWidget {
  @override
  _SelectLanguageState createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
  GlobalKey selectBengaliKey = GlobalKey();
  GlobalKey selectGujaratiKey = GlobalKey();
  GlobalKey selectTeluguKey = GlobalKey();
  GlobalKey selectMarathiKey = GlobalKey();
  GlobalKey selectHindiKey = GlobalKey();
  bool isLoggedIn = false;
  bool isTutorialShown = false;

  @override
  void initState() {
    super.initState();
    isLoggedIn = FirebaseAuth.instance.currentUser != null;

    _loadTutorialStatus(); // Load tutorial status when the app starts

    if (!isLoggedIn && !isTutorialShown) {
      Future.delayed(const Duration(seconds: 1), () {
        _showTutorialCoachmark();
      });
    }
  }

  void _loadTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTutorialShown = prefs.getBool('isTutorialShown') ?? false;
    });
  }

  void _showTutorialCoachmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShown1') ?? false;

    if (!tutorialShown) {
      _initTarget();
      tutorialCoachMark = TutorialCoachMark(targets: targets);
      tutorialCoachMark!.show(context: context);

      // Save in SharedPreferences that tutorial has been shown
      prefs.setBool('tutorialShown1', true);
    }
  }

  void _setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isTutorialShown = true;
    });
    prefs.setBool('isTutorialShown', true);
  }

  void _initTarget() {
    targets = [
      TargetFocus(identify: "select", keyTarget: selectBengaliKey, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Select a Language",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            })
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFC857),
      child: Column(
        children: [
          SizedBox(height: 110.0),
          Text(
            "Select your Language",
            style: TextStyle(
              fontSize: 32.0,
              fontFamily: 'JosefinSans',
              decoration: TextDecoration.none,
              color: Color(0xFF181621),
            ),
          ),
          SizedBox(
            height: 65.0,
          ),
          ElevatedButton(
            key: selectBengaliKey,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              padding: EdgeInsets.fromLTRB(45.0, 12.0, 45.0, 9.0),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              foregroundColor: Color(0xFF181621),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomePage("Bengali")), //only part i have to change
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Bengali",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: 'Amaranth',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            key: selectGujaratiKey,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              padding: EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 9.0),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              foregroundColor: Color(0xFF181621),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage("Gujarati")),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Gujarati",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: 'Amaranth',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            key: selectTeluguKey,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              padding: EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 9.0),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              foregroundColor: Color(0xFF181621),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage("Telugu")),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Telugu",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: 'Amaranth',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            key: selectMarathiKey,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              padding: EdgeInsets.fromLTRB(45.0, 12.0, 45.0, 9.0),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              foregroundColor: Color(0xFF181621),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage("Marathi")),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Marathi",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: 'Amaranth',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            key: selectHindiKey,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              padding: EdgeInsets.fromLTRB(45.0, 12.0, 45.0, 9.0),
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              foregroundColor: Color(0xFF181621),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage("Hindi")),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Hindi",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: 'Amaranth',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoachmarkDesc extends StatefulWidget {
  const CoachmarkDesc({
    super.key,
    required this.text,
    this.skip = "Skip",
    this.next = "Next",
    this.onSkip,
    this.onNext,
  });

  final String text;
  final String skip;
  final next;
  final void Function()? onSkip;
  final void Function()? onNext;
  @override
  State<CoachmarkDesc> createState() => _CoachmarkDescState();
}

class _CoachmarkDescState extends State<CoachmarkDesc> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF181621),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              color: Color(0xFFFFC857), // Text color
              fontSize: 16, // Adjust as needed
            ),
            // style:Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // TextButton(
              //   onPressed: widget.onSkip,
              //   child: Text(widget.skip,
              //     style: TextStyle(
              //       color: Color(0xFFFFC857),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: widget.onNext,
                child: Text(
                  widget.next,
                  style: TextStyle(
                    color: Color(0xFF181621),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFC857),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
