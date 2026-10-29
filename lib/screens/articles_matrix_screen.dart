import '../design_system/design_system.dart';

class ArticlesMatrixScreen extends StatelessWidget {
  const ArticlesMatrixScreen({super.key});

  final cases = const [
    {
      'case': 'المبتدأ / الفاعل (Nominativ)',
      'm': 'der',
      'f': 'die',
      'n': 'das',
      'p': 'die',
    },
    {
      'case': 'المفعول به المباشر (Akkusativ)',
      'm': 'den',
      'f': 'die',
      'n': 'das',
      'p': 'die',
    },
    {
      'case': 'المجرور / غير المباشر (Dativ)',
      'm': 'dem',
      'f': 'der',
      'n': 'dem',
      'p': 'den (+n)',
    },
    {
      'case': 'المضاف إليه (Genitiv)',
      'm': 'des (+s)',
      'f': 'der',
      'n': 'des (+s)',
      'p': 'der',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مصفوفة أدوات التعريف والحالات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: cases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final c = cases[idx];
              return AppBaseGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      c['case']!,
                      style: AppTypography.title.copyWith(color: const Color(0xFFF39C6B), fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _cell('مذكر (m)', c['m']!, const Color(0xFF38BDF8)),
                        _cell('مؤنث (f)', c['f']!, const Color(0xFFF43F5E)),
                        _cell('محايد (n)', c['n']!, const Color(0xFF10B981)),
                        _cell('جمع (p)', c['p']!, const Color(0xFFA855F7)),
                      ],
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

  Widget _cell(String label, String value, Color color) {
    return Column(
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
