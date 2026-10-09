import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../repositories/vocabulary_repository.dart';

class VocabularyJournalScreen extends StatefulWidget {
  const VocabularyJournalScreen({super.key});

  @override
  State<VocabularyJournalScreen> createState() => _VocabularyJournalScreenState();
}

class _VocabularyJournalScreenState extends State<VocabularyJournalScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  String _selectedArticle = 'der'; // الجنس الأكاديمي للكلمات الألمانية
  
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
      HapticFeedback.mediumImpact();

      final fullWord = '$_selectedArticle ${_wordController.text.trim()}';

      setState(() {
        _journalItems.insert(0, {
          "word": fullWord,
          "meaning": _meaningController.text.trim().isNotEmpty ? _meaningController.text.trim() : "معنى أكاديمي مضاف",
          "example": "سياق جملة تعليمي آمن."
        });
      });
      
      final success = await _repository.saveVocabularyList(_journalItems);
      _wordController.clear();
      _meaningController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم حفظ الكلمة بجنسها الأكاديمي بنجاح!' : 'حدث خطأ أثناء الحفظ'),
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
        title: const Text('المفكرة الأكاديمية (بالجنس اللغوي)'),
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
                      const Text('إضافة كلمة جديدة مع الأداة الأكاديمية:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      
                      // اختيار الجنس الأكاديمي Der / Die / Das
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['der', 'die', 'das'].map((article) {
                          final isSelected = _selectedArticle == article;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ChoiceChip(
                              label: Text(article),
                              selected: isSelected,
                              selectedColor: const Color(0xFF38BDF8),
                              backgroundColor: Colors.white12,
                              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedArticle = article;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _wordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'الكلمة الألمانية (بدون أداة)...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _meaningController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'المعنى بالعربي...',
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
                        child: const Text('حفظ في المفكرة الأكاديمية', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('سجل المفردات المحفوظة:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : _journalItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.school_rounded, size: 48, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text('ابدأ رحلتك بإضافة أول كلمة ألمانية بجنسها الصحيح!', 
                                    style: TextStyle(color: Colors.white60, fontSize: 14), 
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
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
