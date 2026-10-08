import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/progress_storage_service.dart';
import 'favorites_screen.dart';

class VerbsScreen extends StatefulWidget {
  final String languageName;
  final String languageCode;
  final List<dynamic> verbs;

  const VerbsScreen({
    Key? key,
    required this.languageName,
    this.languageCode = 'de',
    required this.verbs,
  }) : super(key: key);

  @override
  State<VerbsScreen> createState() => _VerbsScreenState();
}

class _VerbsScreenState extends State<VerbsScreen> {
  final TtsService _tts = TtsService();
  String _selectedLevel = 'ALL';
  String _searchQuery = '';
  Set<String> _favVerbs = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final list = await ProgressStorageService.getFavorites();
    final verbsSet = <String>{};
    for (var s in list) {
      try {
        final decoded = json.decode(s);
        if (decoded['term'] != null) verbsSet.add(decoded['term'].toString());
      } catch (_) {}
    }
    setState(() => _favVerbs = verbsSet);
  }

  void _toggleFav(Map<String, dynamic> v) async {
    final infinitive = (v['infinitive'] ?? v['verb'] ?? v['term'] ?? '').toString();
    final meaning = (v['meaning'] ?? v['translation'] ?? '').toString();
    final payload = {
      'term': infinitive,
      'meaning': meaning,
      'type': 'verb',
      'lang': widget.languageCode,
    };

    final isAdded = await ProgressStorageService.toggleFavorite(json.encode(payload));
    setState(() {
      if (isAdded) {
        _favVerbs.add(infinitive);
      } else {
        _favVerbs.remove(infinitive);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdded ? 'تمت إضافة الفعل إلى المفضلة 🔖' : 'تمت الإزالة من المفضلة'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVerbs = widget.verbs.where((v) {
      final lvl = v['cefr_level'] ?? 'A1';
      final matchesLevel = _selectedLevel == 'ALL' || lvl == _selectedLevel;
      final infinitive = (v['infinitive'] ?? v['verb'] ?? v['term'] ?? '').toString().toLowerCase();
      final meaning = (v['meaning'] ?? v['translation'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || infinitive.contains(q) || meaning.contains(q);
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
            Text('Verbs / أفعال ${widget.languageName}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${filteredVerbs.length} أفعال وتصريفات', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, color: Color(0xFF10B981)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
              _loadFavorites();
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
                hintText: 'ابحث عن أي فعل أو تصريف...',
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
                    selectedColor: const Color(0xFF10B981),
                    labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 12),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSel ? const Color(0xFF10B981) : const Color(0xFFCBD5E1))),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredVerbs.isEmpty
                ? const Center(child: Text('لا توجد أفعال مطابقة للبحث', style: TextStyle(color: Color(0xFF64748B))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredVerbs.length > 150 ? 150 : filteredVerbs.length,
                    itemBuilder: (context, index) {
                      final v = filteredVerbs[index];
                      final infinitive = (v['infinitive'] ?? v['verb'] ?? v['term'] ?? '').toString();
                      final meaning = (v['meaning'] ?? v['translation'] ?? '').toString();
                      final level = (v['cefr_level'] ?? 'A1').toString();
                      final isFav = _favVerbs.contains(infinitive);

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
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(level, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(infinitive, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981)),
                                  onPressed: () => _tts.speak(infinitive, langCode: widget.languageCode),
                                ),
                                IconButton(
                                  icon: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isFav ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                                  onPressed: () => _toggleFav(Map<String, dynamic>.from(v)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(meaning, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                            if (v['present'] != null || v['past'] != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    if (v['present'] != null)
                                      Text('المضارع: ${v['present']}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                    if (v['past'] != null)
                                      Text('الماضي: ${v['past']}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
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
