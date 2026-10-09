import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../repositories/vocabulary_repository.dart';
import '../models/vocabulary_item.dart';

class VocabularyJournalScreen extends StatefulWidget {
  const VocabularyJournalScreen({super.key});

  @override
  State<VocabularyJournalScreen> createState() => _VocabularyJournalScreenState();
}

class _VocabularyJournalScreenState extends State<VocabularyJournalScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _pluralController = TextEditingController();
  final TextEditingController _prepositionController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  String _selectedArticle = 'der';
  
  final VocabularyRepository _repository = VocabularyRepository();
  List<VocabularyItem> _journalItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rawList = await _repository.getVocabularyList();
    setState(() {
      _journalItems = rawList.map((e) => VocabularyItem.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _addItem() async {
    if (_wordController.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();

      final newItem = VocabularyItem(
        word: _wordController.text.trim(),
        article: _selectedArticle,
        plural: _pluralController.text.trim(),
        preposition: _prepositionController.text.trim(),
        meaning: _meaningController.text.trim().isNotEmpty ? _meaningController.text.trim() : "معنى أكاديمي",
        example: "خذ وقتك، كل خطوة صغيرة تثبت معلوماتك بعمق وهدوء.",
      );

      setState(() {
        _journalItems.insert(0, newItem);
      });
      
      final rawList = _journalItems.map((e) => e.toJson()).toList();
      final success = await _repository.saveVocabularyList(rawList);
      
      _wordController.clear();
      _pluralController.clear();
      _prepositionController.clear();
      _meaningController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ ممتاز! تمت إضافة المفردة بنجاح مع الترميز النحوي البصري.'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    }
  }

  // تحديد اللون البصري بناءً على الجنس الأكاديمي (Der / Die / Das)
  Color _getArticleColor(String article) {
    switch (article.toLowerCase()) {
      case 'der':
        return const Color(0xFF38BDF8); // أزرق هادئ
      case 'die':
        return const Color(0xFFF472B6); // وردي ناعم
      case 'das':
        return const Color(0xFF34D399); // أخضر نعناعي
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفكرة الأكاديمية (الترميز البصري والنماذج)'),
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
                // إطار دعم نفسي هادئ
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Text(
                    '🧘 مساحة أمان ذهني: تم ترميز الكلمات لونياً لمساعدة الذاكرة البصرية (أزرق لـ der، وردي لـ die، وأخضر لـ das).',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('إضافة مفردة بالترميز النحوي البصري:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
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
                              selectedColor: _getArticleColor(article),
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
                          hintText: 'الكلمة (مثل: Auto)...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _pluralController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'صيغة الجمع (مثل: Autos)...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _prepositionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'حرف الجر (إن وجد)...',
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
                          hintText: 'المعنى بالعربي (مثل: سيارة)...',
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
                        child: const Text('حفظ بالترميز البصري المتقدم', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('سجل المفردات المرئي:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : _journalItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.palette_rounded, size: 48, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text('المفكرة نظيفة ومريحة.\nأضف أول كلمة لتتمتع بالترميز اللوني!', 
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
                                final articleColor = _getArticleColor(item.article);
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: AppBaseGlassCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: <Widget>[
                                        // شريط لوني جانبي يعبر عن جنس الكلمة النحوي
                                        Container(
                                          width: 4,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: articleColor,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Text('${item.article} ${item.word}', style: TextStyle(color: articleColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                                  if (item.plural.isNotEmpty)
                                                    Text(' (Pl: ${item.plural})', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text('المعنى: ${item.meaning}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                              if (item.preposition.isNotEmpty)
                                                Text('حرف الجر: ${item.preposition}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                                            ],
                                          ),
                                        ),
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
