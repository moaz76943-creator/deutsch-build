import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/progress_storage_service.dart';
import 'favorites_screen.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final List<dynamic> items;

  const VocabularyDetailScreen({
    Key? key,
    required this.languageCode,
    required this.languageName,
    required this.items,
  }) : super(key: key);

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  final TtsService _tts = TtsService();
  String _selectedLevel = 'ALL';
  String _searchQuery = '';
  Set<String> _favTerms = {};

  @override
  void initState() {
    super.initState();
    _loadFavs();
  }

  void _loadFavs() async {
    final list = await ProgressStorageService.getFavorites();
    final terms = <String>{};
    for (var s in list) {
      try {
        final decoded = json.decode(s);
        if (decoded['term'] != null) terms.add(decoded['term'].toString());
      } catch (_) {}
    }
    setState(() => _favTerms = terms);
  }

  void _toggleFav(Map<String, dynamic> item) async {
    final payload = {
      'term': item['term'] ?? item['word'] ?? '',
      'meaning': item['translation'] ?? item['meaning'] ?? '',
      'lang': widget.languageCode,
    };
    final isAdded = await ProgressStorageService.toggleFavorite(json.encode(payload));
    setState(() {
      final t = payload['term'].toString();
      if (isAdded) {
        _favTerms.add(t);
      } else {
        _favTerms.remove(t);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdded ? 'تمت إضافة الكلمة إلى المفضلة 🔖' : 'تمت الإزالة من المفضلة'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((it) {
      final lvl = it['cefr_level'] ?? 'A1';
      final matchesLevel = _selectedLevel == 'ALL' || lvl == _selectedLevel;
      final term = (it['term'] ?? it['word'] ?? '').toString().toLowerCase();
      final trans = (it['translation'] ?? it['meaning'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || term.contains(q) || trans.contains(q);
      return matchesLevel && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vocabulary / مفردات ${widget.languageName}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${filteredItems.length} كلمة متاحة', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, color: Color(0xFF2563EB)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
              _loadFavs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث عن أي كلمة أو معنى...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['ALL', 'A1', 'A2', 'B1', 'B2'].map((lvl) {
                final isSel = _selectedLevel == lvl;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(lvl == 'ALL' ? 'الكل' : lvl),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedLevel = lvl),
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 12),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSel ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1))),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('لا توجد كلمات مطابقة', style: TextStyle(color: Color(0xFF64748B))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredItems.length > 200 ? 200 : filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final term = (item['term'] ?? item['word'] ?? '').toString();
                      final translation = (item['translation'] ?? item['meaning'] ?? '').toString();
                      final example = (item['example'] ?? '').toString();
                      final level = (item['cefr_level'] ?? 'A1').toString();
                      final isFav = _favTerms.contains(term);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(level, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(term, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB)),
                                  onPressed: () => _tts.speak(term, langCode: widget.languageCode),
                                ),
                                IconButton(
                                  icon: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isFav ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                  onPressed: () => _toggleFav(Map<String, dynamic>.from(item)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(translation, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                            if (example.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(example, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.volume_down_rounded, size: 18, color: Color(0xFF64748B)),
                                      onPressed: () => _tts.speak(example, langCode: widget.languageCode),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
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
