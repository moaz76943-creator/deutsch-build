import 'package:flutter/material.dart';

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
  String _selectedLevel = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final matchesLevel = _selectedLevel == 'ALL' || item['cefr_level'] == _selectedLevel;
      final matchesSearch = _searchQuery.isEmpty ||
          item['term'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['meaning_ar'].toString().contains(_searchQuery);
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
            Text('مفردات ${widget.languageName}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${filtered.length} مفردة متاحة', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة أو المعنى بالعربية...',
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
            child: filtered.isEmpty
                ? const Center(child: Text('لا توجد مفردات مطابقة للبحث', style: TextStyle(color: Color(0xFF64748B))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length > 300 ? 300 : filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item['cefr_level'] ?? 'A1',
                                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item['category_name_ar'] ?? 'عام',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB), size: 22),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['term'] ?? '',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['meaning_ar'] ?? '',
                              style: const TextStyle(fontSize: 15, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                            ),
                            const Divider(height: 20),
                            Text(
                              item['example'] ?? '',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['example_ar'] ?? '',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
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
