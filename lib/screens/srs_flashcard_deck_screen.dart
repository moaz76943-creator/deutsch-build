import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class SrsFlashcardDeckScreen extends StatefulWidget {
  const SrsFlashcardDeckScreen({super.key});

  @override
  State<SrsFlashcardDeckScreen> createState() => _SrsFlashcardDeckScreenState();
}

class _SrsFlashcardDeckScreenState extends State<SrsFlashcardDeckScreen> {
  bool _showAnswer = false;
  int _currentIndex = 0;

  final List<Map<String, String>> _cards = [
    {"word": "die Entwicklung", "meaning": "التطور / النشوء"},
    {"word": "erfolgreich", "meaning": "ناجح / موفق"},
    {"word": "die Erfahrung", "meaning": "الخبرة / التجربة"},
  ];

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('مراجعة التكرار المتباعد (${_currentIndex + 1}/${_cards.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAnswer = !_showAnswer;
                      });
                    },
                    child: AppBaseGlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('اضغط على البطاقة لعكسها ورؤية المعنى', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 20),
                          Text(
                            _showAnswer ? currentCard['meaning']! : currentCard['word']!,
                            style: TextStyle(
                              color: _showAnswer ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.2),
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _showAnswer = false;
                            _currentIndex = (_currentIndex + 1) % _cards.length;
                          });
                        },
                        child: const Text('صعب / نسيتها', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34D399).withValues(alpha: 0.2),
                          foregroundColor: const Color(0xFF34D399),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _showAnswer = false;
                            _currentIndex = (_currentIndex + 1) % _cards.length;
                          });
                        },
                        child: const Text('أتقنتها جيداً', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
