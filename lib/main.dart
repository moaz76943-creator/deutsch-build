import 'package:flutter_tts/flutter_tts.dart';
import 'services/language_pack_manager.dart';
import 'core/srs_engine.dart';
import 'flashcards_screen.dart';
import 'package:flutter/material.dart';
import 'repositories/vocabulary_repository.dart';
import 'core/app_master_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeutschBiLarabiApp());
}

class DeutschBiLarabiApp extends StatelessWidget {
  const DeutschBiLarabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch بالعربي - Polyglot Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const FlashcardsScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _dueTodayCount = 0;

  Future<void> _speakExample(String text, String langCode) async {
    final tts = FlutterTts();
    final locale = LanguagePackManager.getTtsLocale(langCode);
    await tts.setLanguage(locale);
    await tts.setSpeechRate(0.42);
    await tts.speak(text);
  }

  void _showContextDialog(Map<String, dynamic> item) {
    final word = item['word']?.toString() ?? '';
    final meaning = item['meaning']?.toString() ?? '';
    final example = item['example']?.toString() ?? 'لا يتوفر مثال مسجل حالياً.';
    final exampleMeaning = item['exampleMeaning']?.toString() ?? '';
    final langName = LanguagePackManager.getLanguageName(_selectedLang);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            meaning,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.indigo, size: 30),
                      onPressed: () => _speakExample(word, _selectedLang),
                    ),
                  ],
                ),
                const Divider(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سياق الاستخدام في جملة ($langName):',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              example,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.volume_down_rounded, color: Colors.indigoAccent, size: 22),
                            onPressed: () => _speakExample(example, _selectedLang),
                          ),
                        ],
                      ),
                      if (exampleMeaning.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          exampleMeaning,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _calculateDueStats(List<Map<String, dynamic>> items) async {
    int due = 0;
    final now = DateTime.now();
    for (final item in items) {
      final word = item['word']?.toString() ?? '';
      if (word.isNotEmpty) {
        final state = await SrsEngine.getItemState(word);
        if (state.nextReviewDate.isBefore(now) || state.repetitions == 0) {
          due++;
        }
      }
    }
    if (mounted) {
      setState(() => _dueTodayCount = due);
    }
  }
  final VocabularyRepository _vocabRepo = VocabularyRepository();
  List<Map<String, dynamic>> _vocabularyList = [];
  String _selectedLang = 'de';
  bool _isLoading = true;
  final Map<String, dynamic> _auditReport = AppMasterEngine.runCriticalAudit();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // تحميل الكلمات الأساسية أو الحزمة اللغوية المحددة
    List<Map<String, dynamic>> items = await _vocabRepo.getVocabularyList();
    _calculateDueStats(items);
    if (items.isEmpty && _selectedLang != 'de') {
      items = await LanguagePackManager.loadPack(_selectedLang);
    }
    setState(() {
      _vocabularyList = items;
      _isLoading = false;
    });
  }

  Future<void> _switchLanguage(String langCode) async {
    setState(() {
      _selectedLang = langCode;
      _isLoading = true;
    });
    List<Map<String, dynamic>> packItems = await LanguagePackManager.loadPack(langCode);
    setState(() {
      _vocabularyList = packItems.isNotEmpty ? packItems : _vocabularyList;
      _isLoading = false;
    });
    _calculateDueStats(_vocabularyList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deutsch بالعربي - المنصة الكونية'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تقرير الحوكمة والأداء الشامل'),
                  content: Text(
                    'حالة النظام: ${_auditReport['systemStatus']}\n'
                    'فحص التدقيق: ${_auditReport['criticalEyeCheck']}\n'
                    'جاهزية الـ 100 لغة: ${_auditReport['polyglotReadiness']}'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('حسناً'),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // شريط اختيار اللغات السريع (Polyglot Bar)
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E293B),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['de', 'en', 'fr', 'es', 'it', 'ar', 'zh'].map((lang) {
                  bool isSelected = _selectedLang == lang;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(lang.toUpperCase()),
                      selected: isSelected,
                      selectedColor: Colors.indigoAccent,
                      backgroundColor: Colors.white24,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                      onSelected: (_) => _switchLanguage(lang),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // المحتوى الرئيسي للقائمة والمعرفات
            // بطاقة مؤشرات المراجعة الذكية (SRS Smart Banner)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_dueTodayCount كلمة بانتظار المراجعة اليوم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إجمالي الرصيد: ${_vocabularyList.length} مفردة',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => FlashcardsScreen(langCode: _selectedLang, initialVocab: _vocabularyList),
                        ),
                      ).then((_) => _loadData());
                    },
                    icon: const Icon(Icons.style_rounded, size: 18),
                    label: const Text('بدء الحفظ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vocabularyList.isEmpty
                    ? const Center(child: Text('لا توجد بيانات متاحة لهذه الحزمة حالياً.'))
                    : ListView.builder(
                        itemCount: _vocabularyList.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final item = _vocabularyList[index];
                          final String word = item['word']?.toString() ?? '';
                          final String article = item['article']?.toString() ?? '';
                          final String meaning = item['meaning']?.toString() ?? '';
                          final String field = item['semanticField']?.toString() ?? '';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Row(
                                children: [
                                  if (article.isNotEmpty)
                                    Text('$article ', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                  Text(word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text('المعنى: $meaning', style: const TextStyle(fontSize: 16, color: Color(0xFF334155))),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(field, style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                                    backgroundColor: Colors.indigo.withValues(alpha: 0.08),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.indigo),
                    onPressed: () => _showContextDialog(item),
                  ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
