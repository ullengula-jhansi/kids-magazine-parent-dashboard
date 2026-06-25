import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kids_magazine/transliterate.dart';
import 'package:kids_magazine/custom_transliterate.dart';

/// HighlightedText widget
/// - Highlights the word currently being spoken by FlutterTTS
/// - Allows tapping a word to view transliteration
/// - Works for Bengali, Hindi, Telugu, Marathi, Gujarati
class HighlightedText extends StatefulWidget {
  final String text;
  final FlutterTts flutterTts;
  final String language;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.flutterTts,
    required this.language,
  }) : super(key: key);

  @override
  _HighlightedTextState createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<HighlightedText> {
  int start = 0;
  int end = 0;
  int? tappedIndex;

  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    _initializeTtsHandlers();
  }

  /// Initialize FlutterTTS handlers
  void _initializeTtsHandlers() {
    widget.flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    widget.flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.stopped;
        start = 0;
        end = 0;
      });
    });

    widget.flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.stopped;
        start = 0;
        end = 0;
      });
    });

    widget.flutterTts.setPauseHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    widget.flutterTts.setContinueHandler(() {
      if (!mounted) return;
      setState(() {
        ttsState = TtsState.continued;
      });
    });

    /// Progress handler for live word highlighting
    widget.flutterTts.setProgressHandler(
          (String spokenText, int startOffset, int endOffset, String currentWord) {
        _updateHighlightedRange(startOffset, endOffset, spokenText);
      },
    );
  }

  /// Update highlighted text indices
  void _updateHighlightedRange(
      int startOffset, int endOffset, String remainingText) {
    if (!mounted) return;

    int alreadySpoken = widget.text.length - remainingText.length;

    setState(() {
      start = alreadySpoken + startOffset;
      end = alreadySpoken + endOffset;

      if (start < 0) start = 0;
      if (end < start) end = start;
      if (end > widget.text.length) end = widget.text.length;
    });
  }

  /// Get transliterated pronunciation for tapped word
  String _getPronunciation(String word) {
    switch (widget.language) {
      case 'Telugu':
        return transliterateTelugu(word);
      case 'Bengali':
        return transliterateBengali(word);
      case 'Gujarati':
        return transliterateGujarati(word);
      case 'Marathi':
        return transliterateMarathi(word);
      case 'Hindi':
        return transliterateHindi(word);
      default:
        return word;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle normalStyle = const TextStyle(
      fontSize: 18,
      color: Color(0xFF181621),
    );

    TextStyle ttsHighlightStyle = const TextStyle(
      fontSize: 18,
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );

    TextStyle tapHighlightStyle = const TextStyle(
      fontSize: 18,
      color: Colors.white,
      backgroundColor: Colors.blue,
      fontWeight: FontWeight.bold,
    );

    List<String> words = widget.text.split(" ");
    int charIndex = 0;

    return Wrap(
      children: List.generate(words.length, (index) {
        String word = words[index];

        int wordStart = charIndex;
        int wordEnd = charIndex + word.length;

        bool isHighlighted = wordStart >= start && wordEnd <= end;
        bool isTapped = tappedIndex == index;

        charIndex = wordEnd + 1;

        TextStyle currentStyle = normalStyle;

        if (isTapped) {
          currentStyle = tapHighlightStyle;
        } else if (isHighlighted) {
          currentStyle = ttsHighlightStyle;
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              tappedIndex = index;
            });

            String pronunciation = _getPronunciation(word);

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(word),
                content: Text(
                  pronunciation,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).then((_) {
              if (!mounted) return;
              setState(() {
                tappedIndex = null;
              });
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              "$word ",
              style: currentStyle,
            ),
          ),
        );
      }),
    );
  }
}

/// TTS state enum
enum TtsState {
  playing,
  stopped,
  paused,
  continued,
}