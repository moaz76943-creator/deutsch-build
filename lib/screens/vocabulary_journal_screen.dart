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
  
  String _userEnergyState = 'منعش ومستعد (جلسة كاملة)';
  int _consecutiveHardCount = 0; // حارس الوتيرة النفسية لتتبع التعثر
  
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

  // فحص حارس الوتيرة النفسية عند التعثر المتكرر
  void _checkFrustrationGuardian(int quality) {
    if (quality <= 1) {
      _consecutiveHardCount++;
      if (_consecutiveHardCount >= 2) {
        _consecutiveHardCount = 0;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🧠 ملاحظة ودية: لاحظت بعض التحدي اليوم. خذ نفساً عميقاً، الدماغ ينمو أكثر مع الهدوء والاسترخاء.'),
              backgroundColor: Color(0xFF38BDF8),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      _consecutiveHardCount = 0; // إعادة ضبط عند التذكر الناجح
    }
  }

  Future<void> _addItem() async {
    if (_wordController.text.trim().isNotEmpty) {
      HapticFeedback.heavyImpact();

      final newItem = VocabularyItem(
        word: _wordController.text.trim(),
        article: _selectedArticle,
        plural: _pluralController.text.trim(),
        preposition: _prepositionController.text.trim(),
        collocation: _collocationController.text.trim(),
        wordFamily: _wordFamilyController.text.trim(),
        difficultyScore: _currentDifficulty,
        meaning: _meaningController.text.trim().isNotEmpty ? _meaningController.text.trim() : "معنى أكاديمي",
        example: "مفردة مهيكلة بـ SM-2 ومدمجة بقوس الجملة.",
        interval: 0,
        repetitions: 0,
        easeFactor: 2.5,
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
            content: Text('🌿 تمت الإضافة وتفعيل تحليل قوس الجملة النحوي.'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    }
  }

  Future<void> _reviewItemSm2(int index, int quality) async {
    HapticFeedback.mediumImpact();
    _checkFrustrationGuardian(quality);

    setState(() {
      _journalItems[index] = _journalItems[index].calculateSm2(quality);
    });
    final rawList = _journalItems.map((e) => e.toJson()).toList();
    await _repository.saveVocabularyList(rawList);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏱️ المراجعة القادمة بعد ${_journalItems[index].interval} أيام.'),
          backgroundColor: const Color(0xFF38BDF8),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
        return Colors.white70;
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
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int displayLimit = _userEnergyState.contains('خفيفة') ? 5 : _journalItems.length;
    final visibleItems = _journalItems.take(displayLimit).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفكرة (حارس الوتيرة وقوس الجملة)'),
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
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('✨ حصادك المعرفي الهادئ', style: TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${_journalItems.length} مفردة مدعومة بالحماية النفسية', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      DropdownButton<String>(
                        value: _userEnergyState,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
                        underline: const SizedBox(),
                        items: ['منعش ومستعد (جلسة كاملة)', 'متعب (جلسة خفيفة سريعة)']
                            .map((energy) => DropdownMenuItem(value: energy, child: Text(energy)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _userEnergyState = val;
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
                      const Text('إضافة مفردة جديدة:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
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
                          hintText: 'حرف الجر...',
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
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _addItem,
                        child: const Text('حفظ بجدولة SM-2 الذكية', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('السجل المعرفي المحمي (${visibleItems.length} عنصر):', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                      : visibleItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.psychology_rounded, size: 48, color: Colors.white38),
                                  SizedBox(height: 12),
                                  Text('المفكرة هادئة ومحمية.\nأضف مفردة لنبدأ التدريب!', 
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
                                final fullTextToSpeak = '${item.article} ${item.word}';
                                final cardBorderColor = item.isReviewDue 
                                    ? const Color(0xFF38BDF8).withValues(alpha: 0.8) 
                                    : Colors.white10;

                                return Dismissible(
                                  key: Key('${item.word}_$index'),
                                  direction: DismissDirection.horizontal,
                                  onDismissed: (direction) {
                                    _deleteItem(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم إزالة المفردة بهدوء تام.')),
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
                                                    const SizedBox(height: 2),
                                                    Text(item.satzklammerVisualization, style: const TextStyle(color: Color(0xFF34D399), fontSize: 11)),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8)),
                                                onPressed: () => _speakWord(fullTextToSpeak),
                                                tooltip: 'استمع للنطق',
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
