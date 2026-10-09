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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مملكة الرفاهية والاحتفاء الذاتي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      // مساحة اللاتنافسية المطلقة
                      AppBaseGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.spa_rounded, color: Color(0xFF34D399), size: 28),
                                SizedBox(width: 12),
                                Text('مساحة اللاتنافسية المطلقة', style: TextStyle(color: Color(0xFF34D399), fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'لا توجد لوحات صدارة، ولا مقارنات رقمية مع الآخرين. رحلتك اللغوية هي حوار داخلي نقي بينك وبين استيعابك الخاص، محمية بالكامل من أي ضغوط خارجية.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // نظام الاحتفاء بالقدرة الذاتية
                      AppBaseGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨ مؤشرات التطور والقدرة الذاتية', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('إجمالي الغلال المعرفي المستقر: $_totalItems وحدة لغوية', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 8),
                            const Text('استقرار الذاكرة طويلة المدى: ممتاز وثابت', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 8),
                            const Text('سرعة استدعاء المعاني: في تصاعد عضوي مستمر', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
