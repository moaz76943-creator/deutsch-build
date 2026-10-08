import '../design_system/design_system.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool _showBack = false;
  int _currentIndex = 0;

  final List<Map<String, String>> _cards = const [
    {
      'article': 'der',
      'german': 'Apfel',
      'plural': 'die Äpfel',
      'arabic': 'التفاحة',
      'example': 'Ich esse einen Apfel.',
    },
    {
      'article': 'die',
      'german': 'Sonne',
      'plural': 'die Sonnen',
      'arabic': 'الشمس',
      'example': 'Die Sonne scheint hell.',
    },
    {
      'article': 'das',
      'german': 'Buch',
      'plural': 'die Bücher',
      'arabic': 'الكتاب',
      'example': 'Das Buch ist sehr interessant.',
    },
  ];

  void _nextCard() {
    setState(() {
      _showBack = false;
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('بطاقات المفردات (SRS)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              children: <Widget>[
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Text(
                  'بطاقة ${_currentIndex + 1} من ${_cards.length}',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showBack = !_showBack),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(32),
                    gradient: AppGradients.blueCard,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (!_showBack) ...<Widget>[
                          ArticleBadge(
                            article: card['article']!,
                            label: card['article']!,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            card['german']!,
                            style: AppTypography.display.copyWith(color: Colors.white, fontSize: 34),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الجمع: ${card['plural']!}',
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'المس للقلب ومعرفة المعنى',
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ] else ...<Widget>[
                          Text(
                            card['arabic']!,
                            style: AppTypography.display.copyWith(color: const Color(0xFF38BDF8), fontSize: 32),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              card['example']!,
                              style: AppTypography.body.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _nextCard,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('صعبة (إعادة قريباً)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('سهلة (حفظ)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
