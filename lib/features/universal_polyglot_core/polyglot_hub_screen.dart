import 'package:flutter/material.dart';
import 'polyglot_models.dart';

class UniversalPolyglotHubScreen extends StatefulWidget {
  const UniversalPolyglotHubScreen({super.key});

  @override
  State<UniversalPolyglotHubScreen> createState() => _UniversalPolyglotHubScreenState();
}

class _UniversalPolyglotHubScreenState extends State<UniversalPolyglotHubScreen> {
  final List<CrossLinguisticCognate> _cognates = const [
    CrossLinguisticCognate(
      sourceWord: 'Gift (English: هدية)',
      targetWord: 'Gift (German: سُم)',
      sourceLang: 'EN',
      targetLang: 'DE',
      isFalseFriend: true,
      nuanceNotes: 'صديق كاذب! تشابه لفظي تام مع اختلاف معنى خطير.',
    ),
    CrossLinguisticCognate(
      sourceWord: 'Sukkar (عربي: سكر)',
      targetWord: 'Zucker (German: سكر)',
      sourceLang: 'AR',
      targetLang: 'DE',
      isFalseFriend: false,
      nuanceNotes: 'جذر لغوي مشترك حقيقي نتيجة التبادل التجاري التاريخي.',
    ),
  ];

  final List<TypologicalStructure> _typologies = const [
    TypologicalStructure(
      language: 'الإنجليزية / الفرنسية',
      typology: WordOrderTypology.svo,
      subject: 'Subject (الفاعل)',
      verb: 'Verb (الفعل)',
      object: 'Object (المفعول)',
    ),
    TypologicalStructure(
      language: 'اليابانية / التركية',
      typology: WordOrderTypology.sov,
      subject: 'Subject (الفاعل)',
      verb: 'Verb (الفعل)',
      object: 'Object (المفعول)',
    ),
    TypologicalStructure(
      language: 'العربية الكلاسيكية',
      typology: WordOrderTypology.vso,
      subject: 'الفاعل',
      verb: 'الفعل',
      object: 'المفعول به',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحرك الكوني متعدد اللغات (Wave 04)'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. الأصدقاء الكاذبون ونقل الجذور
          _buildSectionCard(
            title: '1. رادار الجذور والأصدقاء الكاذبين (INNOV-W04-01)',
            subtitle: 'كشف التطابق الدلالي والتحذير من الأفخاخ الصوتية العابرة للغات',
            child: Column(
              children: _cognates.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item.isFalseFriend ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: item.isFalseFriend ? Colors.orange : Colors.green,
                  ),
                  title: Text('${item.sourceWord} ⇄ ${item.targetWord}'),
                  subtitle: Text(item.nuanceNotes),
                );
              }).toList(),
            ),
          ),

          // 2. مختبر الترتيب الكوني
          _buildSectionCard(
            title: '2. مختبر الترتيب التيبولوجي الكوني (INNOV-W04-02)',
            subtitle: 'مصفوفة بناء الجمل الإنسانية (SVO / SOV / VSO)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _typologies.map((t) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(t.language, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t.renderSequence(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. ميزان التكلفة الصرفية
          _buildSectionCard(
            title: '3. ميزان التكلفة المعرفية الذهنية (INNOV-W04-03)',
            subtitle: 'قياس حمل الذاكرة العاملة حسب الكثافة الصرفية للغة',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• لغات قليلة التصريف (مثل الإنجليزية): تركيز 80% على السياق والكلمات.'),
                SizedBox(height: 4),
                Text('• لغات عالية التصريف (مثل الألمانية / الروسية / العربية): استهلاك عالي لمطابقة الجنس، الحالة، والعدد.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
            child,
          ],
        ),
      ),
    );
  }
}
