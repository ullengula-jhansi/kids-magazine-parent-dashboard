import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'Varnamala.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select.dart';

class VowelConsonantPage extends StatefulWidget {

  final String language;

  const VowelConsonantPage({super.key, required this.language});

  @override
  State<VowelConsonantPage> createState() => _VowelConsonantPageState();
}

class _VowelConsonantPageState extends State<VowelConsonantPage> {

  final FlutterTts tts = FlutterTts();

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey consonantKey = GlobalKey();
  GlobalKey combinationKey = GlobalKey();

  Map<String,String> languageCodes = {
    "Hindi": "hi-IN",
    "Marathi": "mr-IN",
    "Telugu": "te-IN",
    "Gujarati": "gu-IN",
    "Bengali": "bn-IN",
  };

  @override
  void initState() {
    super.initState();

    tts.setLanguage(languageCodes[widget.language]!);
    tts.setPitch(1.0);
    tts.setSpeechRate(0.4);

    Future.delayed(const Duration(milliseconds: 500), () {
      _showTutorial();
    });
  }

  void _showTutorial() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShownVowelConsonant') ?? false;

    if (!tutorialShown) {

      _initTargets();

      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        colorShadow: Colors.black87,
        pulseEnable: true,
      );

      tutorialCoachMark!.show(context: context);

      prefs.setBool('tutorialShownVowelConsonant', true);
    }
  }

  void _initTargets() {

    targets = [

      TargetFocus(
        identify: "consonant",
        keyTarget: consonantKey,
        contents: [

          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {

              return CoachmarkDesc(
                text:
                "Tap any consonant to see vowel + consonant combinations\n(Barakhadi / Guninthaalu)",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );

            },
          )

        ],
      )

    ];
  }

  void _showPopupTutorial() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShownCombination') ?? false;

    if (!tutorialShown) {

      List<TargetFocus> popupTargets = [

        TargetFocus(
          identify: "combination",
          keyTarget: combinationKey,
          contents: [

            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {

                return CoachmarkDesc(
                  text: "Tap any letter to hear its pronunciation",
                  onNext: () {
                    controller.next();
                  },
                  onSkip: () {
                    controller.skip();
                  },
                );

              },
            )

          ],
        )

      ];

      TutorialCoachMark(
        targets: popupTargets,
        colorShadow: Colors.black87,
        pulseEnable: true,
      ).show(context: context);

      prefs.setBool('tutorialShownCombination', true);
    }
  }

  @override
  Widget build(BuildContext context) {

    final data = allVarnamala[widget.language] ?? [];
    final vowelCount = vowelCountMap[widget.language] ?? 13;

    final consonants = data.sublist(vowelCount);

    List<List<Map<String, String>>> rows = [];

    int i = 0;

    for (int k = 0; k < 5; k++) {
      rows.add(consonants.sublist(i, i + 5));
      i += 5;
    }

    rows.add(consonants.sublist(i, i + 4));
    i += 4;

    rows.add(consonants.sublist(i, i + 4));
    i += 4;

    if (i < consonants.length) {
      rows.add(consonants.sublist(i));
    }

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 4, 131),
        iconTheme: const IconThemeData(color: Colors.white),

        title: Text(
          "${widget.language} Consonants",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFC54D),
              Color(0xFFFFB347),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              const Center(
                child: Text(
                  "Consonants",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFE9DDC7),
                  borderRadius: BorderRadius.circular(25),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),

                child: Column(
                  children: rows.asMap().entries.map((entry) {

                    int rowIndex = entry.key;
                    var row = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: row.asMap().entries.map((itemEntry) {

                          int colIndex = itemEntry.key;
                          var item = itemEntry.value;

                          bool isFirstLetter = rowIndex == 0 && colIndex == 0;

                          return GestureDetector(

                            key: isFirstLetter ? consonantKey : null,

                            onTap: () {

                              showConsonantPopup(
                                context,
                                widget.language,
                                item["letter"]!,
                              );

                            },

                            child: Column(
                              children: [

                                Text(
                                  item["letter"]!,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  item["sound"]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),

                              ],
                            ),
                          );

                        }).toList(),
                      ),
                    );

                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // POPUP FUNCTION
  void showConsonantPopup(
      BuildContext context,
      String language,
      String consonant,
      ) {
    Map<String, Map<String, String>> consonantSounds = {

      "Hindi": {
        "क":"k","ख":"kh","ग":"g","घ":"gh","ङ":"ng",
        "च":"ch","छ":"chh","ज":"j","झ":"jh","ञ":"ny",
        "ट":"t","ठ":"th","ड":"d","ढ":"dh","ण":"n",
        "त":"t","थ":"th","द":"d","ध":"dh","न":"n",
        "प":"p","फ":"ph","ब":"b","भ":"bh","म":"m",
        "य":"y","र":"r","ल":"l","व":"v",
        "श":"sh","ष":"sh","स":"s","ह":"h",
        "क्ष":"ksh","त्र":"tr","ज्ञ":"gy"
      },

      "Marathi": {
        "क":"k","ख":"kh","ग":"g","घ":"gh","ङ":"ng",
        "च":"ch","छ":"chh","ज":"j","झ":"jh","ञ":"ny",
        "ट":"t","ठ":"th","ड":"d","ढ":"dh","ण":"n",
        "त":"t","थ":"th","द":"d","ध":"dh","न":"n",
        "प":"p","फ":"ph","ब":"b","भ":"bh","म":"m",
        "य":"y","र":"r","ल":"l","व":"v",
        "श":"sh","ष":"sh","स":"s","ह":"h",
        "ळ":"l","क्ष":"ksh","ज्ञ":"dny"
      },

      "Telugu": {
        "క":"k","ఖ":"kh","గ":"g","ఘ":"gh","ఙ":"ng",
        "చ":"ch","ఛ":"chh","జ":"j","ఝ":"jh","ఞ":"ny",
        "ట":"t","ఠ":"th","డ":"d","ఢ":"dh","ణ":"n",
        "త":"t","థ":"th","ద":"d","ధ":"dh","న":"n",
        "ప":"p","ఫ":"ph","బ":"b","భ":"bh","మ":"m",
        "య":"y","ర":"r","ల":"l","వ":"v",
        "శ":"sh","ష":"sh","స":"s","హ":"h",
        "ళ":"l","క్ష":"ksh","ఱ":"r"
      },

      "Gujarati": {
        "ક":"k","ખ":"kh","ગ":"g","ઘ":"gh","ઙ":"ng",
        "ચ":"ch","છ":"chh","જ":"j","ઝ":"jh","ઞ":"ny",
        "ટ":"t","ઠ":"th","ડ":"d","ઢ":"dh","ણ":"n",
        "ત":"t","થ":"th","દ":"d","ધ":"dh","ન":"n",
        "પ":"p","ફ":"ph","બ":"b","ભ":"bh","મ":"m",
        "ય":"y","ર":"r","લ":"l","વ":"v",
        "શ":"sh","ષ":"sh","સ":"s","હ":"h",
        "ળ":"l","ક્ષ":"ksh","જ્ઞ":"gn"
      },

      "Bengali": {
        "ক":"k","খ":"kh","গ":"g","ঘ":"gh","ঙ":"ng",
        "চ":"ch","ছ":"chh","জ":"j","ঝ":"jh","ঞ":"ny",
        "ট":"t","ঠ":"th","ড":"d","ঢ":"dh","ণ":"n",
        "ত":"t","থ":"th","দ":"d","ধ":"dh","ন":"n",
        "প":"p","ফ":"ph","ব":"b","ভ":"bh","ম":"m",
        "য":"y","র":"r","ল":"l","ৱ":"w",
        "শ":"sh","ষ":"sh","স":"s","হ":"h",
        "ড়":"r","ঢ়":"rh","য়":"y",
        "ক্ষ":"ksh","জ্ঞ":"gy"
      }

    };

    // MATRAS
    List<String> getMatras() {

      switch (widget.language) {

        case "Hindi":
          return ["","ा","ि","ी","ु","ू","ृ","े","ै","ो","ौ","ं","ः"];

        case "Marathi":
          return ["","ा","ि","ी","ु","ू","ृ","ॄ","े","ै","ो","ौ","ं","ः"];

        case "Telugu":
          return ["","ా","ి","ీ","ు","ూ","ృ","ౄ","ె","ే","ై","ొ","ో","ౌ","ం","ః"];

        case "Gujarati":
          return ["","ા","િ","ી","ુ","ૂ","ૃ","ૄ","ે","ૈ","ો","ૌ","ં","ઃ"];

        case "Bengali":
          return ["","া","ি","ী","ু","ূ","ৃ","ৄ","ে","ৈ","ো","ৌ","ং","ঃ","ঁ"];

        default:
          return [];
      }
    }

    // MATRA SOUNDS
    Map<String,String> getMatraSounds() {

      return {

        // default inherent vowel
        "": "a",

        // Hindi / Marathi (Devanagari)
        "ा": "aa",
        "ि": "i",
        "ी": "ee",
        "ु": "u",
        "ू": "oo",
        "ृ": "ri",
        "ॄ": "rri",
        "े": "e",
        "ै": "ai",
        "ो": "o",
        "ौ": "au",
        "ं": "am",
        "ः": "aha",

        // Gujarati
        "ા": "aa",
        "િ": "i",
        "ી": "ee",
        "ુ": "u",
        "ૂ": "oo",
        "ૃ": "ri",
        "ૄ": "rri",
        "ે": "e",
        "ૈ": "ai",
        "ો": "o",
        "ૌ": "au",
        "ં": "am",
        "ઃ": "aha",

        // Telugu
        "ా": "aa",
        "ి": "i",
        "ీ": "ee",
        "ు": "u",
        "ూ": "oo",
        "ృ": "ru",
        "ౄ": "roo",
        "ె": "e",
        "ే": "ee",
        "ై": "ai",
        "ొ": "o",
        "ో": "oo",
        "ౌ": "au",
        "ం": "am",
        "ః": "aha",

        // Bengali
        "া": "aa",
        "ি": "i",
        "ী": "ee",
        "ু": "u",
        "ূ": "oo",
        "ৃ": "ri",
        "ৄ": "rri",
        "ে": "e",
        "ৈ": "oi",
        "ো": "o",
        "ৌ": "ou",
        "ং": "ng",
        "ঃ": "aha",
        "ঁ": "n",
      };
    }
    List<String> matras = getMatras();
    Map<String,String> matraSounds = getMatraSounds();

    String baseSound =
        consonantSounds[language]?[consonant] ?? "";

    List<String> combinations =
    matras.map((m) => consonant + m).toList();

    List<String> transliterations =
    matras.map((m) => baseSound + (matraSounds[m] ?? "")).toList();

    showModalBottomSheet(

      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {

        Future.delayed(
          const Duration(milliseconds: 400),
              () => _showPopupTutorial(),
        );

        return Container(

          height: 420,
          padding: const EdgeInsets.all(16),

          child: GridView.builder(

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),

            itemCount: combinations.length,

            itemBuilder: (context, index) {

              bool isFirstTile = index == 0;

              return GestureDetector(

                key: isFirstTile ? combinationKey : null,
                onTap: () async {
                  await tts.stop();
                  await tts.speak(combinations[index]);
                },

                child: Container(
                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE9DDC7),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        combinations[index],
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        transliterations[index],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                        ),
                      ),

                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}