import 'package:flutter/material.dart';
import 'repositories/vocabulary_repository.dart';
import 'services/language_pack_manager.dart';
import 'modules/contextual_scenarios/scenario_synthesizer.dart';
import 'core/app_master_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeutschBiLarabiApp());
}

class DeutschBiLarabiApp extends StatelessWidget {
  const DeutschBiLarabiApp({Key? key}) : super(key: key);

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
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
              showDialog(
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
                          final word = item['word'] ?? '';
                          final article = item['article'] ?? '';
                          final meaning = item['meaning'] ?? '';
                          final field = item['semanticField'] ?? 'صيدلة وطب';

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
                                    backgroundColor: Colors.indigo.withOpacity(0.08),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.indigo),
                                onPressed: () {
                                  // استدعاء محرك السيناريوهات الحية لهذه الكلمة
                                  final scenario = ContextualScenarioSynthesizer.generateMicroScenario(word, field);
                                  final sDetails = scenario['scenario'] as Map<String, dynamic>;
                                  
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (_) => Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('سيناريو حي: $word', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                          const SizedBox(height: 10),
                                          Text('الموقف: ${sDetails['setting']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 8),
                                          Text('• ${sDetails['lineA']}'),
                                          const SizedBox(height: 4),
                                          Text('• ${sDetails['lineB']}'),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                            child: Text('قاعدة نحوية: ${sDetails['grammarFocus']}', style: const TextStyle(fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
