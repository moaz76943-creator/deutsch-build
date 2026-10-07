import 'package:flutter/material.dart';

class GrammarScreen extends StatefulWidget {
  final String languageName;
  final List<dynamic> rules;

  const GrammarScreen({
    Key? key,
    required this.languageName,
    required this.rules,
  }) : super(key: key);

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  String _selectedLevel = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRules = widget.rules.where((r) {
      final matchesLevel = _selectedLevel == 'ALL' || r['cefr_level'] == _selectedLevel;
      final matchesSearch = _searchQuery.isEmpty ||
          r['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r['rule'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
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
            Text('قواعد ${widget.languageName}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${filteredRules.length} قاعدة وهيكل نحوي', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
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
                hintText: 'ابحث عن قاعدة أو عنوان نحوي...',
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
                    selectedColor: const Color(0xFFF59E0B),
                    labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 12),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSel ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1))),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredRules.isEmpty
                ? const Center(child: Text('لا توجد قواعد مطابقة للبحث', style: TextStyle(color: Color(0xFF64748B))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredRules.length > 150 ? 150 : filteredRules.length,
                    itemBuilder: (context, index) {
                      final item = filteredRules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['cefr_level'] ?? 'A1',
                                    style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                const Icon(Icons.bookmark_border_rounded, color: Color(0xFF94A3B8), size: 22),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'] ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                item['rule'] ?? '',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
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
    );
  }
}
