import 'package:flutter/material.dart';

class SmartWordSearch extends StatefulWidget {
  final List<Map<String, String>> words;
  final Function(Map<String, String>) onWordTap;

  const SmartWordSearch({
    super.key,
    required this.words,
    required this.onWordTap,
  });

  @override
  State<SmartWordSearch> createState() => _SmartWordSearchState();
}

class _SmartWordSearchState extends State<SmartWordSearch> {
  String _query = '';

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.words.where((w) {
      if (_query.isEmpty) return true;
      final qNorm = _normalize(_query);
      final gNorm = _normalize(w['german'] ?? '');
      final arabic = (w['arabic'] ?? '').toLowerCase();
      return gNorm.contains(qNorm) || arabic.contains(_query.trim());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث بالألمانية أو العربية...',
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('لا توجد نتائج مطابقة للبحث'))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final item = filtered[i];
                return ListTile(
                  leading: const Icon(Icons.search_rounded, color: Colors.blueAccent),
                  title: Text(item['german'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['arabic'] ?? ''),
                  onTap: () => widget.onWordTap(item),
                );
              },
            ),
    );
  }
}
