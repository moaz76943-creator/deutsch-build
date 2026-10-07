import 'package:flutter/material.dart';
import '../services/multilingual_service.dart';
import 'vocabulary_detail_screen.dart';
import 'articles_quiz_screen.dart';

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
    {'code': 'tr', 'name': 'Türkçe', 'sub': 'التركية'},
    {'code': 'es', 'name': 'Español', 'sub': 'الإسبانية'},
  ];

  String _currentLangCode = 'de';
  String _currentLangName = 'Deutsch (الألمانية)';
  Map<String, dynamic>? _currentData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData('de', 'Deutsch (الألمانية)');
  }

  void _loadData(String code, String name) async {
    setState(() => _isLoading = true);
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

  void _openArticlesQuizScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArticlesQuizScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Text('تعلم اللغات بذكاء وتوازن', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ],
        ),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected ? const Color(0x402563EB) : const Color(0x08000000),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
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
                                const Text('مرحباً بك!', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  'أكمل مسار $_currentLangName',
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
                                  label: const Text('متابعة التدريب', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                Text('المستوى', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildStatBox(Icons.local_fire_department_rounded, Colors.orange, '14', 'يوم متتالي'),
                        const SizedBox(width: 12),
                        _buildStatBox(Icons.star_rounded, Colors.amber, '1,450', 'نقطة معرفة'),
                        const SizedBox(width: 12),
                        _buildStatBox(Icons.verified_rounded, Colors.green, '98%', 'دقة الإجابات'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('أدوات التعلم الذكي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                          child: _buildFeatureCard(Icons.library_books_rounded, 'المفردات', '300,000 كلمة', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                        ),
                        _buildFeatureCard(Icons.transform_rounded, 'الأفعال', '60,000 تصريف', const Color(0xFF10B981), const Color(0xFFECFDF5)),
                        _buildFeatureCard(Icons.menu_book_outlined, 'القواعد', '14,000 قاعدة', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                        _buildFeatureCard(Icons.record_voice_over_rounded, 'المحادثة', 'نطق سليم', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('تدريب أدوات التعريف (der / die / das)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildArticleCard('der', 'مذكر', const Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        _buildArticleCard('die', 'مؤنث', const Color(0xFFEC4899)),
                        const SizedBox(width: 8),
                        _buildArticleCard('das', 'محايد', const Color(0xFF10B981)),
                      ],
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
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'الدروس'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'المحادثة'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'الإحصائيات'),
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
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArticleCard(String article, String gender, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: _openArticlesQuizScreen,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(article, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(gender, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
