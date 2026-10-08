import '../design_system/design_system.dart';
import 'word_deep_dive_sheet.dart';
import 'articles_matrix_screen.dart';
import 'verb_conjugation_screen.dart';

class OfflineDictionaryScreen extends StatefulWidget {
  const OfflineDictionaryScreen({super.key});

  @override
  State<OfflineDictionaryScreen> createState() => _OfflineDictionaryScreenState();
}

class _OfflineDictionaryScreenState extends State<OfflineDictionaryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<Map<String, String>> _words = const [
    {
      'article': 'der',
      'word': 'Tisch',
      'plural': 'die Tische',
      'meaning': 'الطاولة',
      'example': 'Der Tisch ist aus Holz.',
      'level': 'A1',
    },
    {
      'article': 'die',
      'word': 'Stadt',
      'plural': 'die Städte',
      'meaning': 'المدينة',
      'example': 'Berlin ist eine schöne Stadt.',
      'level': 'A1',
    },
    {
      'article': 'das',
      'word': 'Auto',
      'plural': 'die Autos',
      'meaning': 'السيارة',
      'example': 'Das Auto fährt sehr schnell.',
      'level': 'A1',
    },
    {
      'article': 'der',
      'word': 'Beruf',
      'plural': 'die Berufe',
      'meaning': 'المهنة / العمل',
      'example': 'Was ist dein Beruf?',
      'level': 'A2',
    },
    {
      'article': 'die',
      'word': 'Wohnung',
      'plural': 'die Wohnungen',
      'meaning': 'الشقة',
      'example': 'Die Wohnung hat drei Zimmer.',
      'level': 'A2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredWords = _words.where((w) {
      final matchesSearch = w['word']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w['meaning']!.contains(_searchQuery);
      if (_selectedFilter == 'الكل') return matchesSearch;
      if (['der', 'die', 'das'].contains(_selectedFilter)) {
        return matchesSearch && w['article'] == _selectedFilter;
      }
      return matchesSearch && w['level'] == _selectedFilter;
    }).toList();

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'المعجم الألماني الفوري',
                        style: AppTypography.display.copyWith(color: Colors.white, fontSize: 22),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.table_chart_rounded, color: Color(0xFF38BDF8)),
                        tooltip: 'مصفوفة الأدوات',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ArticlesMatrixScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_book_rounded, color: Color(0xFFF39C6B)),
                        tooltip: 'القواعد والأفعال',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VerbConjugationScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن كلمة ألمانية أو عربية...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['الكل', 'der', 'die', 'das', 'A1', 'A2'].map((f) {
                        final isSel = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: isSel,
                            onSelected: (_) => setState(() => _selectedFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: filteredWords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final item = filteredWords[idx];
                  return AppBaseGlassCard(
                    onTap: () {
                      WordDeepDiveSheet.show(
                        context,
                        article: item['article']!,
                        word: item['word']!,
                        plural: item['plural']!,
                        meaning: item['meaning']!,
                        example: item['example']!,
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        ArticleBadge(article: item['article']!, label: item['article']!),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item['word']!,
                                style: AppTypography.title.copyWith(color: Colors.white, fontSize: 17),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['meaning']!,
                                style: AppTypography.body.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['level']!,
                            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
