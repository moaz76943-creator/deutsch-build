import 'package:flutter/material.dart';
import 'dart:ui';
import 'wave_05_models.dart';

class Wave05HubScreen extends StatefulWidget {
  const Wave05HubScreen({super.key});

  @override
  State<Wave05HubScreen> createState() => _Wave05HubScreenState();
}

class _Wave05HubScreenState extends State<Wave05HubScreen> {
  // بيانات تجريبية للمغناطيسية الصرفية
  final List<MorphemeBlock> _turkishAgglutination = const [
    MorphemeBlock(text: 'Ev', isRoot: true, type: 'بيت'),
    MorphemeBlock(text: 'ler', isRoot: false, type: 'جمع'),
    MorphemeBlock(text: 'im', isRoot: false, type: 'ملكية (ي)'),
    MorphemeBlock(text: 'de', isRoot: false, type: 'في'),
  ];
  final List<MorphemeBlock> _assembledMorphemes = [];

  // بيانات مقياس تحمل الغموض
  final _ambiguityTask = const AmbiguityTask(
    sentenceTokens: ['Der', 'Mann', 'ging', 'schnell', 'in', 'das', 'große', 'Gebäude.'],
    blurredIndices: [3, 6], // طمس "schnell" و "große"
    question: 'ما هو الحدث الرئيسي في هذه الجملة؟',
    correctAnswer: 'شخص دخل إلى مبنى',
    hint: 'الكلمات المطموسة هي مجرد صفات وظروف لا تغير الحدث الأساسي!',
  );
  bool _revealed = false;
  bool _trustScorePenalty = false;

  // بيانات الاستعارات
  final _metaphor = const MetaphorConcept(
    coreConcept: 'الغضب (Anger)',
    sourceLanguageMetaphor: 'نار تشتعل (العربية)',
    targetLanguageMetaphor: 'وعاء يغلي وينفجر (الإنجليزية/الألمانية)',
    explanation: 'لا تترجم الكلمة، بل ترجم الصورة الذهنية!',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المختبر الإدراكي الكوني (Wave 05)'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. المغناطيسية الصرفية
          _buildCard(
            title: '1. المغناطيسية الصرفية والالتصاق (INNOV-W05-01)',
            subtitle: 'مثال للغة ملتصقة (التركية): Evlerimde (في بيوتي)',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: _turkishAgglutination.map((block) {
                    final isUsed = _assembledMorphemes.contains(block);
                    return ActionChip(
                      label: Text('${block.text} (${block.type})'),
                      backgroundColor: block.isRoot ? Colors.blue.shade100 : Colors.orange.shade100,
                      onPressed: isUsed
                          ? null
                          : () => setState(() => _assembledMorphemes.add(block)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _assembledMorphemes.isEmpty
                        ? 'اسحب الكتل الممغنطة لتركيب الكلمة...'
                        : _assembledMorphemes.map((e) => e.text).join(''),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
                if (_assembledMorphemes.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _assembledMorphemes.clear()),
                    child: const Text('إعادة التركيب'),
                  )
              ],
            ),
          ),

          // 2. تحمل الغموض
          _buildCard(
            title: '2. مقياس تحمل الغموض السياقي (INNOV-W05-02)',
            subtitle: 'اقرأ الجملة واستنتج المعنى دون كشف الكلمات المطموسة',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  children: List.generate(_ambiguityTask.sentenceTokens.length, (index) {
                    final isBlurred = _ambiguityTask.blurredIndices.contains(index) && !_revealed;
                    return isBlurred
                        ? Container(
                            margin: const EdgeInsets.only(top: 4),
                            color: Colors.grey.shade400,
                            child: Text(
                              _ambiguityTask.sentenceTokens[index],
                              style: const TextStyle(color: Colors.transparent),
                            ),
                          )
                        : Text(
                            _ambiguityTask.sentenceTokens[index],
                            style: const TextStyle(fontSize: 16),
                          );
                  }),
                ),
                const SizedBox(height: 12),
                Text('السؤال: ${_ambiguityTask.question}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('النتيجة الصحيحة: ${_ambiguityTask.correctAnswer}')),
                      ),
                      child: const Text('أجب بالتخمين'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _revealed = true;
                        _trustScorePenalty = true;
                      }),
                      child: const Text('كشف الكلمات', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                if (_trustScorePenalty)
                  const Text('تم الكشف! (انخفض رصيد الثقة اللغوية - حاول التخمين مستقبلاً)', style: TextStyle(color: Colors.red, fontSize: 12))
              ],
            ),
          ),

          // 3. الاستعارات المفاهيمية
          _buildCard(
            title: '3. الخريطة الكونية للاستعارات (INNOV-W05-03)',
            subtitle: _metaphor.coreConcept,
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetaphorNode(_metaphor.sourceLanguageMetaphor, Colors.blue),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                    _buildMetaphorNode(_metaphor.targetLanguageMetaphor, Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_metaphor.explanation, style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),

          // 4 و 5. (معاينة مرئية للإيقاع والنبر)
          _buildCard(
            title: '4 & 5. ناظم الإيقاع والتزامن الصوتي (INNOV-W05-04/05)',
            subtitle: 'محاكاة لحركة العين والنبر الإيقاعي',
            content: const Text(
              'تعمل في الخلفية كفلتر زمني فوق نصوص القراءة، تجبر العين على القفز كمتحدث أصلي (Saccades) وتطلب النقر لضبط الإيقاع المقطعي (Isochrony).',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetaphorNode(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
