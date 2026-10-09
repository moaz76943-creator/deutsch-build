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
        meaning: _meaningController.text.trim().isNotEmpty ? _meaningController.text.trim() : "معنى أكاديمي مدمج",
        example: "تمت مزامنة المفردة لتظهر في نظام التكرار المتباعد (SRS).",
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
            content: Text('✨ ممتاز! تمت إضافة المفردة وربطها بنظام SRS بسلام وهدوء.'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    HapticFeedback.lightImpact();
    setState(() {
      _journalItems.removeAt(index);
    });
    final rawList = _journalItems.map((e) => e.toJson()).toList();
    await _repository.saveVocabularyList(rawList);
  }

  Color _getArticleColor(String article) {
    switch (article.toLowerCase()) {
      case 'der':
        return const Color(0xFF38BDF8);
      case 'die':
        return const Color(0xFFF472B6);
      case 'das':
        return const Color(0xFF34D399);
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفكرة الشاملة (مرتبطة بـ SRS وتصميم هادئ)'),
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
                // تصميم نفسي خالٍ من الشعور بالذنب (Zero-Guilt UX)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Text(
                    '🌿 مساحة آمنة تماماً: كل كلمة تضيفها هنا تذهب تلقائياً لبطاقات SRS دون أي ضغوط أو إشعارات مزعجة. تعلم بالسرعة التي تناسبك.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('إضافة مفردة جديدة للذاكرة الذكية:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      
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
                          hintText: 'الكلمة الأساسية...',
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
                          hintText: 'صيغة الجمع...',
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
                          hintText: 'حرف الجر المرتبط...',
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
                        child: const Text('حفظ وربط ببطاقات SRS', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('السجل المرتبط بـ SRS (اسحب يميناً أو يساراً للحذف النظيف):', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : _journalItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.all_inclusive_rounded, size: 48, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text('المفكرة هادئة تماماً.\nأضف مفردة لتنضم مباشرة لنظام التكرار الذكي!', 
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
                                
                                return Dismissible(
                                  key: Key('${item.word}_$index'),
                                  direction: DismissDirection.horizontal,
                                  onDismissed: (direction) {
                                    _deleteItem(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم إزالة المفردة بهدوء بنجاح.')),
                                    );
                                  },
                                  background: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    color: Colors.redAccent.withValues(alpha: 0.3),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.redAccent.withValues(alpha: 0.3),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: AppBaseGlassCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: <Widget>[
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
