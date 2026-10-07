import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VerbConjugatorScreen extends StatefulWidget {
  const VerbConjugatorScreen({super.key});

  @override
  State<VerbConjugatorScreen> createState() => _VerbConjugatorScreenState();
}

class _VerbConjugatorScreenState extends State<VerbConjugatorScreen> {
  final FlutterTts _tts = FlutterTts();
  String _searchQuery = '';

  // قاعدة بيانات محلية لأهم الأفعال وتصريفاتها
  final List<Map<String, dynamic>> _verbs = [
    {
      'infinitive': 'sein',
      'meaning': 'يكون',
      'present': {
        'ich': 'bin',
        'du': 'bist',
        'er/sie/es': 'ist',
        'wir': 'sind',
        'ihr': 'seid',
        'sie/Sie': 'sind',
      },
      'perfekt': 'ist gewesen',
    },
    {
      'infinitive': 'haben',
      'meaning': 'يملك / لديه',
      'present': {
        'ich': 'habe',
        'du': 'hast',
        'er/sie/es': 'hat',
        'wir': 'haben',
        'ihr': 'habt',
        'sie/Sie': 'haben',
      },
      'perfekt': 'hat gehabt',
    },
    {
      'infinitive': 'gehen',
      'meaning': 'يذهب / يمشي',
      'present': {
        'ich': 'gehe',
        'du': 'gehst',
        'er/sie/es': 'geht',
        'wir': 'gehen',
        'ihr': 'geht',
        'sie/Sie': 'gehen',
      },
      'perfekt': 'ist gegangen',
    },
    {
      'infinitive': 'lernen',
      'meaning': 'يتعلم',
      'present': {
        'ich': 'lerne',
        'du': 'lernst',
        'er/sie/es': 'lernt',
        'wir': 'lernen',
        'ihr': 'lernt',
        'sie/Sie': 'lernen',
      },
      'perfekt': 'hat gelernt',
    },
    {
      'infinitive': 'sprechen',
      'meaning': 'يتكلم / يتحدث',
      'present': {
        'ich': 'spreche',
        'du': 'sprichst',
        'er/sie/es': 'spricht',
        'wir': 'sprechen',
        'ihr': 'sprecht',
        'sie/Sie': 'sprechen',
      },
      'perfekt': 'hat gesprochen',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(0.45);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _verbs.where((v) {
      final q = _searchQuery.toLowerCase().trim();
      return (v['infinitive'] as String).toLowerCase().contains(q) ||
          (v['meaning'] as String).contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول تصريف الأفعال (Konjugation)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن فعل (sein, haben, يتكلم...)...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('لم يتم العثور على أفعال مطابقة'))
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final presentMap = item['present'] as Map<String, String>;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: ExpansionTile(
                          shape: const Border(),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.bolt_rounded, color: Colors.orange),
                          ),
                          title: Text(
                            item['infinitive'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('المعنى: ${item['meaning']} | التام: ${item['perfekt']}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: presentMap.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            entry.key,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          entry.value,
                                          style: const TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.volume_up_rounded, size: 20),
                                          onPressed: () => _tts.speak('${entry.key} ${entry.value}'),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
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
