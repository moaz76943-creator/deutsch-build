import 'package:flutter/material.dart';
import 'wave_02_models.dart';

class Wave02HubScreen extends StatefulWidget {
  const Wave02HubScreen({super.key});

  @override
  State<Wave02HubScreen> createState() => _Wave02HubScreenState();
}

class _Wave02HubScreenState extends State<Wave02HubScreen> {
  // Late Verb state
  String? _selectedVerb;
  bool _verbFeedbackGiven = false;

  // Compound puzzle state
  final List<String> _assembledParts = [];

  final _verbExercise = const LateVerbExercise(
    promptClause: 'Ich bleibe heute zu Hause, weil ich krank ...',
    verbOptions: ['bin', 'ist', 'habe', 'werde'],
    correctVerb: 'bin',
    explanation: 'في جملة (weil) يذهب الفعل المصرف إلى نهاية الجملة مباشرة.',
  );

  final _puzzle = const CompoundWordPuzzle(
    parts: ['Kranken', 'Haus'],
    combinedWord: 'Krankenhaus',
    gender: 'das',
    arabicMeaning: 'مستشفى (دار المرضى)',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEUTSCH بالعربي — الدفعة الثانية'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. مسرح الفعل المعلق
          _buildCard(
            title: '1. ترقب الفعل المعلق (INNOV-W02-01)',
            subtitle: 'توقع الفعل الناقص في نهاية الجملة الثانوية',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _verbExercise.promptClause,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _verbExercise.verbOptions.map((verb) {
                    return ChoiceChip(
                      label: Text(verb),
                      selected: _selectedVerb == verb,
                      onSelected: (selected) {
                        setState(() {
                          _selectedVerb = selected ? verb : null;
                          _verbFeedbackGiven = true;
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_verbFeedbackGiven && _selectedVerb != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedVerb == _verbExercise.correctVerb
                        ? 'إجابة صحيحة! ${_verbExercise.explanation}'
                        : 'إجابة غير دقيقة، حاول مجدداً.',
                    style: TextStyle(
                      color: _selectedVerb == _verbExercise.correctVerb
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. مختبر النحت الاشتقاقي
          _buildCard(
            title: '2. مختبر الكلمات المركبة (INNOV-W02-02)',
            subtitle: 'ركّب الكلمة واكتشف قاعدة أداة التعريف التلقائية',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: _puzzle.parts.map((part) {
                    final isUsed = _assembledParts.contains(part);
                    return ActionChip(
                      label: Text(part),
                      onPressed: isUsed
                          ? null
                          : () {
                              setState(() {
                                _assembledParts.add(part);
                              });
                            },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('التركيب: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      _assembledParts.join(''),
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    const Spacer(),
                    if (_assembledParts.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () =>
                            setState(() => _assembledParts.clear()),
                      ),
                  ],
                ),
                if (_assembledParts.join('') == _puzzle.combinedWord) ...[
                  const SizedBox(height: 6),
                  Text(
                    'النتيجة: ${_puzzle.gender} ${_puzzle.combinedWord} — ${_puzzle.arabicMeaning}',
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'قاعدة: الأداة تأخذ جنس الكلمة الأخيرة دائماً (das Haus -> das Krankenhaus).',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          // 3. محاكي النماذج الرسمية
          _buildCard(
            title: '3. محاكي الأوراق والبيروقراطية (INNOV-W02-06)',
            subtitle: 'استمارة تسجيل السكن الميدانية (Anmeldung)',
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Familienname (اسم العائلة)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Vorname (الاسم الشخصي)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Geburtsdatum (تاريخ الميلاد)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
