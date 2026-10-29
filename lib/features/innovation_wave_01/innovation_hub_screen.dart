import 'package:flutter/material.dart';

class InnovationHubScreen extends StatefulWidget {
  const InnovationHubScreen({super.key});

  @override
  State<InnovationHubScreen> createState() => _InnovationHubScreenState();
}

class _InnovationHubScreenState extends State<InnovationHubScreen> {
  int _discoveredFacts = 0;
  String _pragmaticFeedback = '';
  String _circumlocutionInput = '';
  String _meaningShiftMode = 'sentence_a';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEUTSCH بالعربي — الابتكارات الشاملة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. محاكي فجوة المعلومات
          _buildCard(
            title: '1. محاكي فجوة المعلومات (INNOV-W01-01)',
            subtitle: 'المهمة: مكتب القطارات - اكتشف التفاصيل عبر السؤال',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المعلومات المكتشفة: $_discoveredFacts / 3',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Wann fährt der Zug ab?'),
                      onPressed: () {
                        setState(() {
                          if (_discoveredFacts < 3) _discoveredFacts++;
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Wie viel kostet das?'),
                      onPressed: () {
                        setState(() {
                          if (_discoveredFacts < 3) _discoveredFacts++;
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Kann ich umbuchen?'),
                      onPressed: () {
                        setState(() {
                          if (_discoveredFacts < 3) _discoveredFacts++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. محكمة اللباقة الاجتماعية
          _buildCard(
            title: '2. محكمة اللباقة الاجتماعية (INNOV-W01-02)',
            subtitle: 'طلب الماء في اجتماع رسمي مع المشرف',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _pragmaticFeedback = 'Gib mir das Wasser: صحيحة نحوياً لكنها فظة في هذا السياق!';
                    });
                  },
                  child: const Text('Gib mir das Wasser.'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _pragmaticFeedback = 'Könnten Sie mir bitte...: ممتازة! تحقق قمة اللباقة الرسمية.';
                    });
                  },
                  child: const Text('Könnten Sie mir bitte etwas Wasser geben?'),
                ),
                if (_pragmaticFeedback.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_pragmaticFeedback, style: const TextStyle(color: Colors.teal)),
                ]
              ],
            ),
          ),

          // 3. إنقاذ المعنى
          _buildCard(
            title: '3. مهارة إنقاذ المعنى (INNOV-W01-03)',
            subtitle: 'نسيت كلمة (Regenschirm)؟ صف وظيفتها لإنقاذ الموقف:',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'مثال: Ein Ding gegen den Regen...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _circumlocutionInput = val),
                ),
                const SizedBox(height: 6),
                Text('الاستراتيجية: ${_circumlocutionInput.isEmpty ? "بانتظار الوصف البديل" : "تم رصد وصف وظيفي بديل ناجح!"}'),
              ],
            ),
          ),

          // 4. مسرح انقلاب المعنى
          _buildCard(
            title: '4. مسرح انقلاب المعنى (INNOV-W01-04)',
            subtitle: 'أثر موقع كلمة (nur) على بؤرة التركيز الدلالية',
            content: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'sentence_a', label: Text('Nur ich habe Anna eingeladen')),
                    ButtonSegment(value: 'sentence_b', label: Text('Ich habe nur Anna eingeladen')),
                  ],
                  selected: {_meaningShiftMode},
                  onSelectionChanged: (set) => setState(() => _meaningShiftMode = set.first),
                ),
                const SizedBox(height: 8),
                Text(
                  _meaningShiftMode == 'sentence_a'
                      ? 'الدلالة: أنا الشخص الوحيد الذي دعا آنا (لم يدعُها غيري).'
                      : 'الدلالة: دعوت آنا بمفردها (لم أدعُ أي شخص آخر).',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
