import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select.dart';

class VarnamalaPage extends StatefulWidget {
  final String language;

  const VarnamalaPage({super.key, required this.language});

  @override
  State<VarnamalaPage> createState() => _VarnamalaPageState();
}
// ================= DATA =================

Map<String, List<Map<String, String>>> allVarnamala = {
  // 🇮🇳 Hindi
  "Hindi": [
    {"letter": "अ", "sound": "a"}, {"letter": "आ", "sound": "aa"},
    {"letter": "इ", "sound": "i"}, {"letter": "ई", "sound": "ee"},
    {"letter": "उ", "sound": "u"}, {"letter": "ऊ", "sound": "oo"},
    {"letter": "ऋ", "sound": "ri"}, {"letter": "ए", "sound": "e"},
    {"letter": "ऐ", "sound": "ai"}, {"letter": "ओ", "sound": "o"},
    {"letter": "औ", "sound": "au"}, {"letter": "अं", "sound": "am"},
    {"letter": "अः", "sound": "aha"},

    {"letter": "क", "sound": "ka"}, {"letter": "ख", "sound": "kha"},
    {"letter": "ग", "sound": "ga"}, {"letter": "घ", "sound": "gha"},
    {"letter": "ङ", "sound": "nga"},

    {"letter": "च", "sound": "cha"}, {"letter": "छ", "sound": "chha"},
    {"letter": "ज", "sound": "ja"}, {"letter": "झ", "sound": "jha"},
    {"letter": "ञ", "sound": "nya"},

    {"letter": "ट", "sound": "ta (hard)"}, {"letter": "ठ", "sound": "tha (hard)"},
    {"letter": "ड", "sound": "da (hard)"}, {"letter": "ढ", "sound": "dha (hard)"},
    {"letter": "ण", "sound": "na (hard)"},

    {"letter": "त", "sound": "ta"}, {"letter": "थ", "sound": "tha"},
    {"letter": "द", "sound": "da"}, {"letter": "ध", "sound": "dha"},
    {"letter": "न", "sound": "na"},

    {"letter": "प", "sound": "pa"}, {"letter": "फ", "sound": "pha"},
    {"letter": "ब", "sound": "ba"}, {"letter": "भ", "sound": "bha"},
    {"letter": "म", "sound": "ma"},

    {"letter": "य", "sound": "ya"}, {"letter": "र", "sound": "ra"},
    {"letter": "ल", "sound": "la"}, {"letter": "व", "sound": "va"},

    {"letter": "श", "sound": "sha"}, {"letter": "ष", "sound": "sha (hard)"},
    {"letter": "स", "sound": "sa"}, {"letter": "ह", "sound": "ha"},

    {"letter": "क्ष", "sound": "ksha"},
    {"letter": "त्र", "sound": "tra"},
    {"letter": "ज्ञ", "sound": "gya"},
  ],

  // 🇮🇳 Marathi (same script as Hindi with few additions)
  "Marathi": [

    // Vowels (Swar)
    {"letter": "अ", "sound": "a"}, {"letter": "आ", "sound": "aa"},
    {"letter": "इ", "sound": "i"}, {"letter": "ई", "sound": "ee"},
    {"letter": "उ", "sound": "u"}, {"letter": "ऊ", "sound": "oo"},
    {"letter": "ऋ", "sound": "ri"}, {"letter": "ॠ", "sound": "rri"},
    {"letter": "ए", "sound": "e"}, {"letter": "ऐ", "sound": "ai"},
    {"letter": "ओ", "sound": "o"}, {"letter": "औ", "sound": "au"},
    {"letter": "अं", "sound": "am"}, {"letter": "अः", "sound": "aha"},

    // Consonants (Vyanjan)

    // Ka Varg
    {"letter": "क", "sound": "ka"}, {"letter": "ख", "sound": "kha"},
    {"letter": "ग", "sound": "ga"}, {"letter": "घ", "sound": "gha"},
    {"letter": "ङ", "sound": "nga"},

    // Cha Varg
    {"letter": "च", "sound": "cha"}, {"letter": "छ", "sound": "chha"},
    {"letter": "ज", "sound": "ja"}, {"letter": "झ", "sound": "jha"},
    {"letter": "ञ", "sound": "nya"},

    // Ta Varg (Retroflex)
    {"letter": "ट", "sound": "ta"}, {"letter": "ठ", "sound": "tha"},
    {"letter": "ड", "sound": "da"}, {"letter": "ढ", "sound": "dha"},
    {"letter": "ण", "sound": "na"},

    // Ta Varg (Dental)
    {"letter": "त", "sound": "ta"}, {"letter": "थ", "sound": "tha"},
    {"letter": "द", "sound": "da"}, {"letter": "ध", "sound": "dha"},
    {"letter": "न", "sound": "na"},

    // Pa Varg
    {"letter": "प", "sound": "pa"}, {"letter": "फ", "sound": "pha"},
    {"letter": "ब", "sound": "ba"}, {"letter": "भ", "sound": "bha"},
    {"letter": "म", "sound": "ma"},

    // Antastha (Semi-vowels)
    {"letter": "य", "sound": "ya"}, {"letter": "र", "sound": "ra"},
    {"letter": "ल", "sound": "la"}, {"letter": "व", "sound": "va"},

    // Ushma (Sibilants + Aspirate)
    {"letter": "श", "sound": "sha"}, {"letter": "ष", "sound": "sha"},
    {"letter": "स", "sound": "sa"}, {"letter": "ह", "sound": "ha"},

    // Additional Marathi letters
    {"letter": "ळ", "sound": "la (retroflex)"},
    {"letter": "क्ष", "sound": "ksha"},
    {"letter": "ज्ञ", "sound": "gya"}
  ],

  // 🇮🇳 Telugu
  "Telugu": [

    // Vowels (Achulu)
    {"letter": "అ", "sound": "a"}, {"letter": "ఆ", "sound": "aa"},
    {"letter": "ఇ", "sound": "i"}, {"letter": "ఈ", "sound": "ee"},
    {"letter": "ఉ", "sound": "u"}, {"letter": "ఊ", "sound": "oo"},
    {"letter": "ఋ", "sound": "ru"}, {"letter": "ౠ", "sound": "roo"},
    {"letter": "ఎ", "sound": "e"}, {"letter": "ఏ", "sound": "ee"},
    {"letter": "ఐ", "sound": "ai"}, {"letter": "ఒ", "sound": "o"},
    {"letter": "ఓ", "sound": "oo"}, {"letter": "ఔ", "sound": "au"},
    {"letter": "అం", "sound": "am"}, {"letter": "అః", "sound": "aha"},

    // Consonants (Hallulu)

    // Ka Vargam
    {"letter": "క", "sound": "ka"}, {"letter": "ఖ", "sound": "kha"},
    {"letter": "గ", "sound": "ga"}, {"letter": "ఘ", "sound": "gha"},
    {"letter": "ఙ", "sound": "nga"},

    // Cha Vargam
    {"letter": "చ", "sound": "cha"}, {"letter": "ఛ", "sound": "chha"},
    {"letter": "జ", "sound": "ja"}, {"letter": "ఝ", "sound": "jha"},
    {"letter": "ఞ", "sound": "nya"},

    // Ta Vargam (Retroflex)
    {"letter": "ట", "sound": "ta"}, {"letter": "ఠ", "sound": "tha"},
    {"letter": "డ", "sound": "da"}, {"letter": "ఢ", "sound": "dha"},
    {"letter": "ణ", "sound": "na"},

    // Ta Vargam (Dental)
    {"letter": "త", "sound": "ta"}, {"letter": "థ", "sound": "tha"},
    {"letter": "ద", "sound": "da"}, {"letter": "ధ", "sound": "dha"},
    {"letter": "న", "sound": "na"},

    // Pa Vargam
    {"letter": "ప", "sound": "pa"}, {"letter": "ఫ", "sound": "pha"},
    {"letter": "బ", "sound": "ba"}, {"letter": "భ", "sound": "bha"},
    {"letter": "మ", "sound": "ma"},

    // Antastha (Semi-vowels)
    {"letter": "య", "sound": "ya"}, {"letter": "ర", "sound": "ra"},
    {"letter": "ల", "sound": "la"}, {"letter": "వ", "sound": "va"},

    // Ushmana (Sibilants + Aspirate)
    {"letter": "శ", "sound": "sha"}, {"letter": "ష", "sound": "sha"},
    {"letter": "స", "sound": "sa"}, {"letter": "హ", "sound": "ha"},

    // Additional letters (Modern usage)
    {"letter": "ళ", "sound": "la"}, {"letter": "క్ష", "sound": "ksha"},
    {"letter": "ఱ", "sound": "ra"}
  ],
  // 🇮🇳 Gujarati
  "Gujarati": [

    // Vowels (Swar)
    {"letter": "અ", "sound": "a"}, {"letter": "આ", "sound": "aa"},
    {"letter": "ઇ", "sound": "i"}, {"letter": "ઈ", "sound": "ee"},
    {"letter": "ઉ", "sound": "u"}, {"letter": "ઊ", "sound": "oo"},
    {"letter": "ઋ", "sound": "ri"}, {"letter": "ૠ", "sound": "rri"},
    {"letter": "એ", "sound": "e"}, {"letter": "ઐ", "sound": "ai"},
    {"letter": "ઓ", "sound": "o"}, {"letter": "ઔ", "sound": "au"},
    {"letter": "અં", "sound": "am"}, {"letter": "અઃ", "sound": "aha"},

    // Consonants (Vyanjan)

    // Ka Varg
    {"letter": "ક", "sound": "ka"}, {"letter": "ખ", "sound": "kha"},
    {"letter": "ગ", "sound": "ga"}, {"letter": "ઘ", "sound": "gha"},
    {"letter": "ઙ", "sound": "nga"},

    // Cha Varg
    {"letter": "ચ", "sound": "cha"}, {"letter": "છ", "sound": "chha"},
    {"letter": "જ", "sound": "ja"}, {"letter": "ઝ", "sound": "jha"},
    {"letter": "ઞ", "sound": "nya"},

    // Ta Varg (Retroflex)
    {"letter": "ટ", "sound": "ta"}, {"letter": "ઠ", "sound": "tha"},
    {"letter": "ડ", "sound": "da"}, {"letter": "ઢ", "sound": "dha"},
    {"letter": "ણ", "sound": "na"},

    // Ta Varg (Dental)
    {"letter": "ત", "sound": "ta"}, {"letter": "થ", "sound": "tha"},
    {"letter": "દ", "sound": "da"}, {"letter": "ધ", "sound": "dha"},
    {"letter": "ન", "sound": "na"},

    // Pa Varg
    {"letter": "પ", "sound": "pa"}, {"letter": "ફ", "sound": "pha"},
    {"letter": "બ", "sound": "ba"}, {"letter": "ભ", "sound": "bha"},
    {"letter": "મ", "sound": "ma"},

    // Antastha (Semi-vowels)
    {"letter": "ય", "sound": "ya"}, {"letter": "ર", "sound": "ra"},
    {"letter": "લ", "sound": "la"}, {"letter": "વ", "sound": "va"},

    // Ushma (Sibilants + Aspirate)
    {"letter": "શ", "sound": "sha"}, {"letter": "ષ", "sound": "sha"},
    {"letter": "સ", "sound": "sa"}, {"letter": "હ", "sound": "ha"},

    // Additional letters
    {"letter": "ળ", "sound": "la"}, {"letter": "ક્ષ", "sound": "ksha"},
    {"letter": "જ્ઞ", "sound": "gna"}
  ],

  // 🇮🇳 Bengali
  "Bengali": [

    // Vowels (Swar)
    {"letter": "অ", "sound": "o"}, {"letter": "আ", "sound": "aa"},
    {"letter": "ই", "sound": "i"}, {"letter": "ঈ", "sound": "ee"},
    {"letter": "উ", "sound": "u"}, {"letter": "ঊ", "sound": "oo"},
    {"letter": "ঋ", "sound": "ri"}, {"letter": "ৠ", "sound": "rri"},
    {"letter": "এ", "sound": "e"}, {"letter": "ঐ", "sound": "oi"},
    {"letter": "ও", "sound": "o"}, {"letter": "ঔ", "sound": "ou"},
    {"letter": "ং", "sound": "ng"}, {"letter": "ঃ", "sound": "aha"},
    {"letter": "ঁ", "sound": "n"},

    // Consonants (Byanjan)

    // Ka Varg
    {"letter": "ক", "sound": "ka"}, {"letter": "খ", "sound": "kha"},
    {"letter": "গ", "sound": "ga"}, {"letter": "ঘ", "sound": "gha"},
    {"letter": "ঙ", "sound": "nga"},

    // Cha Varg
    {"letter": "চ", "sound": "cha"}, {"letter": "ছ", "sound": "chha"},
    {"letter": "জ", "sound": "ja"}, {"letter": "ঝ", "sound": "jha"},
    {"letter": "ঞ", "sound": "nya"},

    // Ta Varg (Retroflex)
    {"letter": "ট", "sound": "ta"}, {"letter": "ঠ", "sound": "tha"},
    {"letter": "ড", "sound": "da"}, {"letter": "ঢ", "sound": "dha"},
    {"letter": "ণ", "sound": "na"},

    // Ta Varg (Dental)
    {"letter": "ত", "sound": "ta"}, {"letter": "থ", "sound": "tha"},
    {"letter": "দ", "sound": "da"}, {"letter": "ধ", "sound": "dha"},
    {"letter": "ন", "sound": "na"},

    // Pa Varg
    {"letter": "প", "sound": "pa"}, {"letter": "ফ", "sound": "pha"},
    {"letter": "ব", "sound": "ba"}, {"letter": "ভ", "sound": "bha"},
    {"letter": "ম", "sound": "ma"},

    // Antastha (Semi-vowels)
    {"letter": "য", "sound": "ya"}, {"letter": "র", "sound": "ra"},
    {"letter": "ল", "sound": "la"}, {"letter": "ৱ", "sound": "wa"},

    // Ushma (Sibilants + Aspirate)
    {"letter": "শ", "sound": "sha"}, {"letter": "ষ", "sound": "sha"},
    {"letter": "স", "sound": "sa"}, {"letter": "হ", "sound": "ha"},

    // Additional letters
    {"letter": "ড়", "sound": "ra"}, {"letter": "ঢ়", "sound": "rha"},
    {"letter": "য়", "sound": "ya"},
    {"letter": "ক্ষ", "sound": "ksha"}, {"letter": "জ্ঞ", "sound": "gya"}
  ],
};

Map<String, int> vowelCountMap = {
  "Hindi": 13,
  "Marathi": 14,
  "Telugu": 16,
  "Gujarati": 14,
  "Bengali": 15,
};
class _VarnamalaPageState extends State<VarnamalaPage> {

  final FlutterTts tts = FlutterTts();
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey pronunciationKey = GlobalKey();

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

  Future speak(String text) async {
    await tts.speak(text);
  }

  void _showTutorial() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShownVarnamala') ?? false;

    if (!tutorialShown) {

      _initTargets();

      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
      );

      tutorialCoachMark!.show(context: context);

      prefs.setBool('tutorialShownVarnamala', true);
    }
  }

  void _initTargets() {

    targets = [

      TargetFocus(
        identify: "pronunciation",
        keyTarget: pronunciationKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Tap any letter to hear its pronunciation",
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          )
        ],
      )

    ];
  }

  @override
  Widget build(BuildContext context) {

    final data = allVarnamala[widget.language] ?? [];
    final vowelCount = vowelCountMap[widget.language] ?? 13;

    final vowels = data.sublist(0, vowelCount);
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
        backgroundColor: Color.fromARGB(255, 25, 4, 131),

        iconTheme: const IconThemeData(
          color: Colors.white, // makes back arrow white
        ),

        title: Text(
          "${widget.language} Varnamala",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Center(
                child: Text(
                  "Varnamala",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height:20),

              // VOWELS HEADING
              const Text(
                "Vowels",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height:10),

              // VOWELS BOX
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFE9DDC7),
                  borderRadius: BorderRadius.circular(25),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0,6),
                    )
                  ],
                ),

                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: vowels.asMap().entries.map((entry) {

                    int index = entry.key;
                    var item = entry.value;

                    return GestureDetector(

                      key: index == 0 ? pronunciationKey : null,

                      onTap: () {
                        speak(item["letter"]!);
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
                          const SizedBox(height:5),
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
              ),

              const SizedBox(height:30),

              // CONSONANTS HEADING
              const Text(
                "Consonants",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height:10),

              // CONSONANTS BOX
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFE9DDC7),
                  borderRadius: BorderRadius.circular(25),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0,6),
                    )
                  ],
                ),

                child: Column(
                  children: rows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: row.map((item) {
                          return GestureDetector(
                            onTap: () {
                              speak(item["letter"]!);
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
                                const SizedBox(height:5),
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
}
