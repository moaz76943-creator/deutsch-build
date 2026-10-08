import '../design_system/design_system.dart';

class WordDeepDiveSheet extends StatelessWidget {
  const WordDeepDiveSheet({
    required this.article,
    required this.word,
    required this.plural,
    required this.meaning,
    required this.example,
    super.key,
  });

  final String article;
  final String word;
  final String plural;
  final String meaning;
  final String example;

  static void show(
    BuildContext context, {
    required String article,
    required String word,
    required String plural,
    required String meaning,
    required String example,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WordDeepDiveSheet(
        article: article,
        word: word,
        plural: plural,
        meaning: meaning,
        example: example,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppGradients.darkScaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              ArticleBadge(article: article, label: article),
              const SizedBox(width: 12),
              Text(
                word,
                style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'المعنى: $meaning',
            style: AppTypography.title.copyWith(color: const Color(0xFFF39C6B), fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'صيغة الجمع: $plural',
            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 20),
          AppBaseGlassCard(
            gradient: AppGradients.blueCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('مثال في جملة مفيدة:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  example,
                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
