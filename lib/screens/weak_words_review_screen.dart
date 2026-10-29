import '../design_system/design_system.dart';

class WeakWordsReviewScreen extends StatelessWidget {
  const WeakWordsReviewScreen({super.key});

  final List<Map<String, String>> _weakWords = const [
    {'word': 'der Schlüssel', 'meaning': 'المفتاح', 'accuracy': '40%'},
    {'word': 'das Mädchen', 'meaning': 'الفتاة', 'accuracy': '50%'},
    {'word': 'die Zeitung', 'meaning': 'الجريدة', 'accuracy': '30%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تثبيت المفردات الضعيفة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            itemCount: _weakWords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _weakWords[index];
              return AppBaseGlassCard(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.replay_circle_filled_rounded, color: Color(0xFFEF4444)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item['word']!, style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
                          Text(item['meaning']!, style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item['accuracy']!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
