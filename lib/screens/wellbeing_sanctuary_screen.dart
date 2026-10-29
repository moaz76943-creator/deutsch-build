import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../repositories/vocabulary_repository.dart';

class WellbeingSanctuaryScreen extends StatefulWidget {
  const WellbeingSanctuaryScreen({super.key});

  @override
  State<WellbeingSanctuaryScreen> createState() => _WellbeingSanctuaryScreenState();
}

class _WellbeingSanctuaryScreenState extends State<WellbeingSanctuaryScreen> {
  final VocabularyRepository _repository = VocabularyRepository();
  int _totalItems = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final items = await _repository.getVocabularyList();
    if (mounted) {
      setState(() {
        _totalItems = items.length;
        _isLoading = false;
      });
    }
  }

  void _showAnxietyDissolverDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.5))),
        title: const Text('🛡️ درع تبديد قلق الأداء الطولي', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'تذكر دائماً: تعلم اللغات ليس سباقاً رقمياً ولا اختباراً نهائياً، بل هو نمو بيولوجي وعصبي هادئ.\n\n'
          'حتى لو تذبذب إيقاعك أو نسيت بعض الكلمات أحياناً، فدماغك يبني المسارات الخلفية بثبات. تنفس بعمق، وأنت تسير في الطريق الصحيح تماماً.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('اطمأن قلبي، شكراً', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مملكة الرفاهية والسكينة العصبية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_rounded, color: Color(0xFF38BDF8)),
            onPressed: _showAnxietyDissolverDialog,
            tooltip: 'درع تبديد قلق الأداء',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppBaseGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.spa_rounded, color: Color(0xFF34D399), size: 28),
                                SizedBox(width: 12),
                                Text('مؤشر الرضا المعرفي الكلي', style: TextStyle(color: Color(0xFF34D399), fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'لا توجد لوحات صدارة ولا مقارنات رقمية. يقاس نجاحك هنا بمدى شعورك بالهدوء والعمق الإدراكي بعد كل جلسة استيعاب.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppBaseGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨ حالة الوعي والاتزان العصبي', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('حجم الغلال المعرفي المستقر: $_totalItems وحدة', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 8),
                            const Text('مستوى الاستقرار والهدوء العصبي: عالٍ ومستدام', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 8),
                            const Text('درع تبديد القلق: مفعل ومحمٍ بالكامل', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
