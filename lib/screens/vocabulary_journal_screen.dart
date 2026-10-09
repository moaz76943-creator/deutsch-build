import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final TextEditingController _collocationController = TextEditingController();
  final TextEditingController _wordFamilyController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  String _selectedArticle = 'der';
  double _currentDifficulty = 1.0;
  
  final VocabularyRepository _repository = VocabularyRepository();
  final FlutterTts _flutterTts = FlutterTts();
  List<VocabularyItem> _journalItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("de-DE");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakWord(String textToSpeak) async {
    HapticFeedback.lightImpact();
    await _flutterTts.stop();
    await _flutterTts.speak(textToSpeak);
  }

  Future<void> _loadData() async {
    final rawList = await _repository.getVocabularyList();
    if (mounted) {
      setState(() {
        _journalItems = rawList.map((e) => VocabularyItem.fromJson(e)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _addItem() async {
    if (_wordController.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();

      final newItem = VocabularyItem(
        word: _wordController.text.trim(),
        article: _selectedArticle,
        plural: _pluralController.text.trim(),
        preposition: _prepositionController.text.trim(),
        collocation: _collocationController.text.trim(),
        wordFamily: _wordFamilyController.text.trim(),
        difficultyScore: _currentDifficulty,
        meaning: _meaningController.text.trim().isNotEmpty ? _meaningController.text.trim() : "معنى أكاديمي",
        example: "عائلة لغوية وتقييم نفسي مرن للذاكرة.",
      );

      setState(() {
        _journalItems.insert(0, newItem);
      });
      
      final rawList = _journalItems.map((e) => e.toJson()).toList();
      await _repository.saveVocabularyList(rawList);
      
      _wordController.clear();
      _pluralController.clear();
      _prepositionController.clear();
      _collocationController.clear();
      _wordFamilyController.clear();
      _meaningController.clear();
      setState(() {
        _currentDifficulty = 1.0;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌱 تمت الإضافة بنجاح مع العائلة اللغوية والتقييم الهادئ!'),
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

  String _getDifficultyLabel(double score) {
    if (score <= 1.5) return '😌 محفوظ ومستقر';
    if (score <= 2.5) return '🤔 بحاجة لمراجعة خفيفة';
    return '🔥 جديد وبحاجة لتثبيت';
  }

  @override
  void dispose() {
    _wordController.dispose();
    _pluralController.dispose();
    _prepositionController.dispose();
    _collocationController.dispose();
    _wordFamilyController.dispose();
    _meaningController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفكرة المتقدمة (العائلات اللغوية والتقييم)'),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Text(
                    '🧠 مساحة تعلّم واعية: اربط المفردة بعائلتها الجذرية وحدد مقياس رسوخها الذهني بهدوء ودون ضغط.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('إضافة مفردة متقدمة مع العائلة اللغوية:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
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
                        controller: _collocationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'المتلازمة اللفظية...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _wordFamilyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'عائلة الكلمة (Wortfamilie)...',
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
                      const SizedBox(height: 14),
                      Text('مقياس الاستقرار الذهني: ${_getDifficultyLabel(_currentDifficulty)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Slider(
                        value: _currentDifficulty,
                        min: 1.0,
                        max: 3.0,
                        divisions: 2,
                        activeColor: const Color(0xFF38BDF8),
                        inactiveColor: Colors.white24,
                        onChanged: (val) {
                          setState(() {
                            _currentDifficulty = val;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _addItem,
                        child: const Text('حفظ في المفكرة مع التقييم والعائلة اللغوية', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('السجل الأكاديمي المطور:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : _journalItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.hub_rounded, size: 48, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text('المفكرة هادئة ومنظمة.\nأضف أول عائلة لغوية للبدء!', 
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
                                final fullTextToSpeak = '${item.article} ${item.word}';
                                
                                return Dismissible(
                                  key: Key('${item.word}_$index'),
                                  direction: DismissDirection.horizontal,
                                  onDismissed: (direction) {
                                    _deleteItem(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تمت إزالة المفردة بهدوء.')),
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
                                            height: 65,
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
                                                Wrap(
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  children: <Widget>[
                                                    Text('${item.article} ${item.word}', style: TextStyle(color: articleColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                                    if (item.plural.isNotEmpty)
                                                      Text(' (Pl: ${item.plural})', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text('المعنى: ${item.meaning}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                                if (item.wordFamily.isNotEmpty)
                                                  Text('العائلة اللغوية: ${item.wordFamily}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                                                Text('الحالة: ${_getDifficultyLabel(item.difficultyScore)}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
                                            onPressed: () => _speakWord(fullTextToSpeak),
                                            tooltip: 'استمع للنطق الألماني',
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
