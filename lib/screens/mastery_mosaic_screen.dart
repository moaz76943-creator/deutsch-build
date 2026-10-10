import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/repositories/vocabulary_repository.dart';

class MasteryMosaicScreen extends StatefulWidget {
  const MasteryMosaicScreen({super.key});

  @override
  State<MasteryMosaicScreen> createState() => _MasteryMosaicScreenState();
}

class _MasteryMosaicScreenState extends State<MasteryMosaicScreen> {
  final VocabularyRepository _repository = VocabularyRepository();
  int _totalWords = 0;
  Map<String, int> _fieldCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMosaicData();
  }

  Future<void> _loadMosaicData() async {
    final items = await _repository.getVocabularyList();
    Map<String, int> fields = {};
    for (var item in items) {
      String f = item['semanticField'] ?? 'عام';
      fields[f] = (fields[f] ?? 0) + 1;
    }
    if (mounted) {
      setState(() {
        _totalWords = items.length;
        _fieldCounts = fields;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فسيفساء الإنجاز المعرفي (Mastery Mosaic)'),
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
                      const AppBaseGlassCard(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🌸 خريطة اليقين المعرفي (بدون عدادات توتر)', style: TextStyle(color: Color(0xFF34D399), fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                              'هذه الفسيفساء تعكس تراكم وعيك اللغوي بسلام وتوازن. كل مفردة تم حفظها هي بذرة أنبتت في بستان عقلك الباطن بغض النظر عن انقطاع الأيام.',
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
                            Text('إجمالي الغلال المعرفي: $_totalWords مفردة مستقرة', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ...(_fieldCounts.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('حقل: ${entry.key}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34D399).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${entry.value} عناصر', style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            })),
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
