import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../repositories/vocabulary_repository.dart';

class VocabularyJournalScreen extends StatefulWidget {
  const VocabularyJournalScreen({super.key});

  @override
  State<VocabularyJournalScreen> createState() => _VocabularyJournalScreenState();
}

class _VocabularyJournalScreenState extends State<VocabularyJournalScreen> {
  final TextEditingController _wordController = TextEditingController();
  final VocabularyRepository _repository = VocabularyRepository();
  List<Map<String, String>> _journalItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await _repository.getVocabularyList();
    setState(() {
      _journalItems = items;
      _isLoading = false;
    });
  }

  Future<void> _addItem() async {
    if (_wordController.text.trim().isNotEmpty) {
      setState(() {
        _journalItems.insert(0, {
          "word": _wordController.text.trim(),
          "meaning": "معنى مُضاف ومحفوظ عبر Repository",
          "example": "مثال توضيحي آمن ومنظم معمارياً."
        });
      });
      
      final success = await _repository.saveVocabularyList(_journalItems);
      _wordController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم الحفظ المعماري الآمن بنجاح!' : 'حدث خطأ أثناء الحفظ'),
            backgroundColor: success ? const Color(0xFF34D399) : const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفكرة (معمارية المستودع الآمن)'),
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
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('إضافة كلمة جديدة عبر المعمارية النظيفة:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _wordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'اكتب الكلمة هنا...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _addItem,
                        child: const Text('حفظ عبر Repository', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('سجل الكلمات المسترجع هندسياً:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : ListView.builder(
                          itemCount: _journalItems.length,
                          itemBuilder: (context, index) {
                            final item = _journalItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: AppBaseGlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(item['word']!, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('المعنى: ${item['meaning']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text('مثال: ${item['example']}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          },
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
