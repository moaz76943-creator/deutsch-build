import 'package:flutter/material.dart';
import '../services/multilingual_service.dart';
import '../services/progress_storage_service.dart';
import 'vocabulary_detail_screen.dart';
import 'articles_quiz_screen.dart';
import 'verbs_screen.dart';
import 'grammar_screen.dart';
import 'analytics_screen.dart';
import 'conversation_screen.dart';
import 'lessons_path_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final MultilingualService _service = MultilingualService();

  final List<Map<String, String>> _languages = [
    {'code': 'de', 'name': 'Deutsch', 'sub': 'الألمانية'},
    {'code': 'en', 'name': 'English', 'sub': 'الإنجليزية'},
    {'code': 'fr', 'name': 'Français', 'sub': 'الفرنسية'},
    {'code': 'es', 'name': 'Español', 'sub': 'الإسبانية'},
    {'code': 'it', 'name': 'Italiano', 'sub': 'الإيطالية'},
    {'code': 'tr', 'name': 'Türkçe', 'sub': 'التركية'},
    {'code': 'ru', 'name': 'Русский', 'sub': 'الروسية'},
    {'code': 'nl', 'name': 'Nederlands', 'sub': 'الهولندية'},
    {'code': 'pt', 'name': 'Português', 'sub': 'البرتغالية'},
    {'code': 'sv', 'name': 'Svenska', 'sub': 'السويدية'},
    {'code': 'pl', 'name': 'Polski', 'sub': 'البولندية'},
    {'code': 'da', 'name': 'Dansk', 'sub': 'الدانماركية'},
    {'code': 'fi', 'name': 'Suomi', 'sub': 'الفنلندية'},
    {'code': 'el', 'name': 'Ελληνικά', 'sub': 'اليونانية'},
    {'code': 'ja', 'name': '日本語', 'sub': 'اليابانية'},
    {'code': 'ko', 'name': '한국어', 'sub': 'الكورية'},
    {'code': 'zh', 'name': '中文', 'sub': 'الصينية'},
    {'code': 'hi', 'name': 'हिन्दी', 'sub': 'الهندية'},
    {'code': 'fa', 'name': 'فارسی', 'sub': 'الفارسية'},
    {'code': 'ar', 'name': 'العربية', 'sub': 'العربية'},
  ];

  String _currentLangCode = 'de';
  String _currentLangName = 'Deutsch (الألمانية)';
  Map<String, dynamic>? _currentData;
  bool _isLoading = false;
  int _navIndex = 0;

  int _streak = 14;
  int _points = 1450;
  int _accuracy = 98;

  @override
  void initState() {
    super.initState();
    _loadUserProgressAndLanguage();
  }

  void _loadUserProgressAndLanguage() async {
    final stats = await ProgressStorageService.getUserStats();
    final savedCode = stats['langCode'] as String;
    final match = _languages.firstWhere(
      (l) => l['code'] == savedCode,
      orElse: () => _languages[0],
    );

    setState(() {
      _streak = stats['streak'] as int;
      _points = stats['points'] as int;
      _accuracy = stats['accuracy'] as int;
    });

    _loadData(match['code']!, '${match['name']} (${match['sub']})');
  }

  void _loadData(String code, String name) async {
    setState(() => _isLoading = true);
    await ProgressStorageService.saveSelectedLanguage(code);
    final data = await _service.loadLanguagePack(code);
    setState(() {
      _currentData = data;
      _currentLangCode = code;
      _currentLangName = name;
      _isLoading = false;
    });
  }

  void _openVocabularyScreen() {
    final items = (_currentData?['contentItems'] as List?) ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyDetailScreen(
          languageCode: _currentLangCode,
          languageName: _currentLangName,
          items: items,
        ),
      ),
    );
  }

  void _openVerbsScreen() {
    final verbs = (_currentData?['verbConjugations'] as List?) ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerbsScreen(
          languageName: _currentLangName,
          languageCode: _currentLangCode,
          verbs: verbs,
        ),
      ),
    );
  }

  void _openGrammarScreen() {
    final rules = (_currentData?['grammarRules'] as List?) ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrammarScreen(
          languageName: _currentLangName,
          rules: rules,
        ),
      ),
    );
  }

  void _openConversationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          languageName: _currentLangName,
          languageCode: _currentLangCode,
        ),
      ),
    );
  }

  void _openLessonsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonsPathScreen(languageName: _currentLangName),
      ),
    );
  }

  void _openArticlesQuizScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArticlesQuizScreen(),
      ),
    );
    final stats = await ProgressStorageService.getUserStats();
    setState(() {
      _points = stats['points'] as int;
    });
  }

  void _openNotificationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      _openLessonsScreen();
    } else if (index == 2) {
      _openConversationScreen();
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
      );
    } else {
      setState(() => _navIndex = index);
    }
  }

  List<Map<String, dynamic>> _getArticlesForLang(String code) {
    switch (code) {
      case 'de':
        return [
          {'article': 'der', 'label': 'Masculine / مذكر', 'color': const Color(0xFF2563EB)},
          {'article': 'die', 'label': 'Feminine / مؤنث', 'color': const Color(0xFFEC4899)},
          {'article': 'das', 'label': 'Neutral / محايد', 'color': const Color(0xFF10B981)},
        ];
      case 'en':
        return [
          {'article': 'the', 'label': 'Definite / معرفة', 'color': const Color(0xFF2563EB)},
          {'article': 'a', 'label': 'Indefinite / نكرة', 'color': const Color(0xFF10B981)},
          {'article': 'an', 'label': 'Vowel / علة', 'color': const Color(0xFFF59E0B)},
        ];
      case 'fr':
        return [
          {'article': 'le', 'label': 'Masculin / مذكر', 'color': const Color(0xFF2563EB)},
          {'article': 'la', 'label': 'Féminin / مؤنث', 'color': const Color(0xFFEC4899)},
          {'article': 'les', 'label': 'Pluriel / جمع', 'color': const Color(0xFF8B5CF6)},
        ];
      case 'es':
        return [
          {'article': 'el', 'label': 'Masculino / مذكر', 'color': const Color(0xFF2563EB)},
          {'article': 'la', 'label': 'Femenino / مؤنث', 'color': const Color(0xFFEC4899)},
          {'article': 'los', 'label': 'Plural / جمع', 'color': const Color(0xFF10B981)},
        ];
      case 'it':
        return [
          {'article': 'il / lo', 'label': 'Maschile / مذكر', 'color': const Color(0xFF2563EB)},
          {'article': 'la', 'label': 'Femminile / مؤنث', 'color': const Color(0xFFEC4899)},
          {'article': 'i / gli', 'label': 'Plurale / جمع', 'color': const Color(0xFF10B981)},
        ];
      case 'tr':
        return [
          {'article': '-i', 'label': 'Belirtme / مفعول', 'color': const Color(0xFF2563EB)},
          {'article': '-e', 'label': 'Yönelme / إلى', 'color': const Color(0xFF10B981)},
          {'article': '-de', 'label': 'Bulunma / في', 'color': const Color(0xFFF59E0B)},
        ];
      default:
        return [
          {'article': 'Definite', 'label': 'أداة تعريف', 'color': const Color(0xFF2563EB)},
          {'article': 'Indefinite', 'label': 'أداة نكرة', 'color': const Color(0xFF10B981)},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentArticles = _getArticlesForLang(_currentLangCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Deutsch بالعربي', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                Text('20 Languages Suite • إتقان اللغات', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF334155)),
            onPressed: _openNotificationsScreen,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF334155)),
            onPressed: _openSettingsScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _languages.length,
                        itemBuilder: (context, i) {
                          final l = _languages[i];
                          final isSelected = l['code'] == _currentLangCode;
                          return GestureDetector(
                            onTap: () => _loadData(l['code']!, '${l['name']} (${l['sub']})'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  l['name']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Color(0x332563EB), blurRadius: 16, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Welcome Back! مرحباً بك', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  'Track: $_currentLangName',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E3A8A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                                  label: const Text('Continue / متابعة', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: _openVocabularyScreen,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Column(
                              children: [
                                Text('A2', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                Text('Level', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildStatBox(Icons.local_fire_department_rounded, Colors.orange, '$_streak', 'Day Streak / أيام'),
                        const SizedBox(width: 12),
                        _buildStatBox(Icons.star_rounded, Colors.amber, '$_points', 'Points / نقاط'),
                        const SizedBox(width: 12),
                        _buildStatBox(Icons.verified_rounded, Colors.green, '$_accuracy%', 'Accuracy / دقة'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Learning Modules / أدوات التعلم الذكي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        InkWell(
                          onTap: _openVocabularyScreen,
                          borderRadius: BorderRadius.circular(16),
                          child: _buildFeatureCard(Icons.library_books_rounded, 'Vocabulary / المفردات', '300,000 Terms', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                        ),
                        InkWell(
                          onTap: _openVerbsScreen,
                          borderRadius: BorderRadius.circular(16),
                          child: _buildFeatureCard(Icons.transform_rounded, 'Verbs / الأفعال', '60,000 Forms', const Color(0xFF10B981), const Color(0xFFECFDF5)),
                        ),
                        InkWell(
                          onTap: _openGrammarScreen,
                          borderRadius: BorderRadius.circular(16),
                          child: _buildFeatureCard(Icons.menu_book_outlined, 'Grammar / القواعد', '14,000 Rules', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                        ),
                        InkWell(
                          onTap: _openConversationScreen,
                          borderRadius: BorderRadius.circular(16),
                          child: _buildFeatureCard(Icons.record_voice_over_rounded, 'Dialogue / المحادثة', 'AI Smart Practice', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Core Language Markers / أدوات اللغة (${_currentLangName.split(' ')[0]})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    Row(
                      children: currentArticles.map((art) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: _openArticlesQuizScreen,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: (art['color'] as Color).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: (art['color'] as Color).withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  children: [
                                    Text(art['article'] as String, style: TextStyle(color: art['color'] as Color, fontSize: 19, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(
                                      art['label'] as String,
                                      style: TextStyle(color: (art['color'] as Color).withValues(alpha: 0.8), fontSize: 11),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        currentIndex: _navIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'Lessons'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Dialogue'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, Color iconColor, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
