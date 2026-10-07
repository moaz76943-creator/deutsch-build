import 'package:flutter/material.dart';

class VerbsScreen extends StatefulWidget {
  final String languageName;
  final List<dynamic> verbs;

  const VerbsScreen({
    Key? key,
    required this.languageName,
    required this.verbs,
  }) : super(key: key);

  @override
  State<VerbsScreen> createState() => _VerbsScreenState();
}

class _VerbsScreenState extends State<VerbsScreen> {
  String _selectedLevel = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredVerbs = widget.verbs.where((v) {
      final matchesLevel = _selectedLevel == 'ALL' || v['cefr_level'] == _selectedLevel;
      final matchesSearch = _searchQuery.isEmpty ||
          v['verb'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (v['meaning_ar'] != null && v['meaning_ar'].toString().contains(_searchQuery));
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
            Text('أفعال وتصريفات ${widget.languageName}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${filteredVerbs.length} فعل متاح', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
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
                hintText: 'ابحث عن فعل أو معناه...',
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
                    itemCount: filteredVerbs.length > 200 ? 200 : filteredVerbs.length,
                    itemBuilder: (context, index) {
                      final item = filteredVerbs[index];
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
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['cefr_level'] ?? 'A1',
                                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981), size: 22),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['verb'] ?? '',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            if (item['meaning_ar'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item['meaning_ar'],
                                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildTenseColumn('الحاضر (Präsens)', item['present'] ?? '-'),
                                  Container(height: 28, width: 1, color: const Color(0xFFCBD5E1)),
                                  _buildTenseColumn('الماضي (Past)', item['past'] ?? '-'),
                                ],
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

  Widget _buildTenseColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }
}
