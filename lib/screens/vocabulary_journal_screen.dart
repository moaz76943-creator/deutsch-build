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
  final TextEditingController _etymologyController = TextEditingController();
  
  String _selectedLanguage = 'de';
  String _selectedArticle = 'der';
  String _selectedSemanticField = 'حياة يومية';
  double _currentDifficulty = 1.0;
  
  String _userEnergyState = 'منعش ومستعد (جلسة كاملة)';
  int _consecutiveHardCount = 0; // لمراقبة الحمل المعرفي
  
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
      await _updateTtsLanguage(_selectedLanguage);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _updateTtsLanguage(String langCode) async {
    String ttsLang = "de-DE";
    if (langCode == 'en') ttsLang = "en-US";
    else if (langCode == 'fr') ttsLang = "fr-FR";
    else if (langCode == 'es') ttsLang = "es-ES";
    await _flutterTts.setLanguage(ttsLang);
  }

  Future<void> _speakWord(String textToSpeak, String langCode) async {
    HapticFeedback.lightImpact();
    await _updateTtsLanguage(langCode);
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

  // موازن الحمل المعرفي التلقائي (Cognitive Load Auto-Balancing)
  void _checkCognitiveLoad(int quality) {
    if (quality <= 1) {
      _consecutiveHardCount++;
      if (_consecutiveHardCount >= 2) {
        _consecutiveHardCount = 0;
        if (mounted) {
          setState(() {
            _userEnergyState = 'متعب (جلسة خفيفة سريعة)';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚖️ موازن الحمل المعرفي: تم تقليص حجم الجلسة تلقائياً لراحتك العصبية.'),
              backgroundColor: Color(0xFF38BDF8),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      _consecutiveHardCount = 0;
    }
  }

  Future<void> _addItem() async {
    if (_wordController.text.trim().isNotEmpty) {
      HapticFeedback.heavyImpact();

      final newItem = VocabularyItem(
        word: _wordController.text.trim(),
        article: _selectedLanguage == 'de' ? _selectedArticle : '',
        plural: _pluralController.text.trim(),
        preposition: _prepositionController.text.trim(),
        collocation: _collocationController.text.trim(),
        wordFamily: _wordFamilyController.text.trim(),
        difficultyScore: _currentDifficulty,
        meaning: _meaningController.text.trim().isNotEmpty ? _meaningController.text.trim() : "معنى دلالي",
        example: "مفردة مصنفة ضمن الحقل الدلالي.",
        interval: 0,
        repetitions: 0,
        easeFactor: 2.5,
        languageCode: _selectedLanguage,
        etymologyRoot: _etymologyController.text.trim(),
        semanticField: _selectedSemanticField,
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
      _etymologyController.clear();
      setState(() {
        _currentDifficulty = 1.0;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌿 تمت إضافة المفردة وتصنيفها في الحقل المعرفي بنجاح.'),
          backgroundColor: Color(0xFF34D399),
        ),
      );
    }
  }

  Future<void> _reviewItemSm2(int index, int quality) async {
    HapticFeedback.mediumImpact();
    _checkCognitiveLoad(quality);

    setState(() {
      _journalItems[index] = _journalItems[index].calculateSm2(quality);
    });
    final rawList = _journalItems.map((e) => e.toJson()).toList();
    await _repository.saveVocabularyList(rawList);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏱️ المراجعة القادمة بعد ${_journalItems[index].interval} أيام.'),
        backgroundColor: const Color(0xFF38BDF8),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deleteItem(int index) async {
    HapticFeedback.selectionClick();
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
        return const Color(0xFF34D399);
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _pluralController.dispose();
    _prepositionController.dispose();
    _collocationController.dispose();
    _wordFamilyController.dispose();
    _meaningController.dispose();
    _etymologyController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int displayLimit = _userEnergyState.contains('خفيفة') ? 5 : _journalItems.length;
    final visibleItems = _journalItems.take(displayLimit).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفكرة (الحقول المعرفية وموازن الحمل)'),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('🌐 لغة التعلم النشطة:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        dropdownColor: const Color(0xFF0F172A),
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'de', child: Text('🇩🇪 الألمانية (Deutsch)')),
                          DropdownMenuItem(value: 'en', child: Text('🇬🇧 الإنجليزية (English)')),
                          DropdownMenuItem(value: 'fr', child: Text('🇫🇷 الفرنسية (Français)')),
                          DropdownMenuItem(value: 'es', child: Text('🇪🇸 الإسبانية (Español)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedLanguage = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('إضافة مفردة لـ (${_selectedLanguage.toUpperCase()}):', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      
                      if (_selectedLanguage == 'de') ...[
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
                      ],

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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('الحقل المعرفي:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedSemanticField,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold),
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'حياة يومية', child: Text('حياة يومية')),
                                DropdownMenuItem(value: 'طبي وصيدلاني', child: Text('طبي وصيدلاني')),
                                DropdownMenuItem(value: 'أكاديمي وعلمي', child: Text('أكاديمي وعلمي')),
                                DropdownMenuItem(value: 'بيئة وعمل', child: Text('بيئة وعمل')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedSemanticField = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
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
                        child: const Text('حفظ بالحقل المعرفي', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('السجل المعرفي (${visibleItems.length} عنصر):', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : visibleItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.folder_special_rounded, size: 48, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text('المفكرة هادئة.\nأضف أول مفردة بحقلها المعرفي!', 
                                    style: TextStyle(color: Colors.white60, fontSize: 14), 
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: visibleItems.length,
                              itemBuilder: (context, index) {
                                final item = visibleItems[index];
                                final articleColor = _getArticleColor(item.article);
                                final fullTextToSpeak = item.languageCode == 'de' ? '${item.article} ${item.word}' : item.word;
                                final cardBorderColor = item.isReviewDue 
                                    ? const Color(0xFF38BDF8).withValues(alpha: 0.8) 
                                    : Colors.white10;

                                return Dismissible(
                                  key: Key('${item.word}_$index'),
                                  direction: DismissDirection.horizontal,
                                  onDismissed: (direction) {
                                    _deleteItem(index);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم إزالة المفردة بهدوء.')),
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
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: cardBorderColor, width: item.isReviewDue ? 1.5 : 1),
                                    ),
                                    child: AppBaseGlassCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: 4,
                                                height: 55,
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
                                                        Text(
                                                          item.languageCode == 'de' ? '${item.article} ${item.word}' : item.word,
                                                          style: TextStyle(color: articleColor, fontSize: 18, fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withValues(alpha: 0.1),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(item.semanticField, style: const TextStyle(color: Color(0xFF34D399), fontSize: 9)),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text('المعنى: ${item.meaning}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
                                                onPressed: () => _speakWord(fullTextToSpeak, item.languageCode),
                                                tooltip: 'نطق صوتي',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              const Text('تقييم التذكر:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                onPressed: () => _reviewItemSm2(index, 1),
                                                child: const Text('صعب', style: TextStyle(fontSize: 12)),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF38BDF8), padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                onPressed: () => _reviewItemSm2(index, 4),
                                                child: const Text('جيد', style: TextStyle(fontSize: 12)),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF34D399), padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                onPressed: () => _reviewItemSm2(index, 5),
                                                child: const Text('سهل جداً', style: TextStyle(fontSize: 12)),
                                              ),
                                            ],
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
