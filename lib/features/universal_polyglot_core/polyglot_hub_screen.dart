import 'package:flutter/material.dart';
import 'polyglot_models.dart';
import 'package:deutsch_bilarabi/services/polyglot_intelligence_engine.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

class UniversalPolyglotHubScreen extends StatefulWidget {
  const UniversalPolyglotHubScreen({super.key});

  @override
  State<UniversalPolyglotHubScreen> createState() => _UniversalPolyglotHubScreenState();
}

class _UniversalPolyglotHubScreenState extends State<UniversalPolyglotHubScreen> {
  final String _activeLocale = 'ar';

  final List<CrossLinguisticCognate> _cognates = const [
    CrossLinguisticCognate(
      sourceWord: 'Gift (English: هدية)',
      targetWord: 'Gift (German: سُم)',
      sourceLang: 'EN',
      targetLang: 'DE',
      isFalseFriend: true,
      nuanceNotes: 'تطابق لفظي واختلاف تام في المعنى؛ تحذير من الخلط أثناء الترجمة.',
    ),
    CrossLinguisticCognate(
      sourceWord: 'Sukkar (عربي: سكر)',
      targetWord: 'Zucker (German: سكر)',
      sourceLang: 'AR',
      targetLang: 'DE',
      isFalseFriend: false,
      nuanceNotes: 'جذر تاريخي مشترك يسهل الحفظ الفوري بين اللغتين.',
    ),
    CrossLinguisticCognate(
      sourceWord: 'Haus (German: منزل)',
      targetWord: 'House (English: منزل)',
      sourceLang: 'DE',
      targetLang: 'EN',
      isFalseFriend: false,
      nuanceNotes: 'تشابه جرماني مباشر من العائلة اللغوية ذاتها.',
    ),
  ];

  final List<TypologicalStructure> _typologies = const [
    TypologicalStructure(
      language: 'الألمانية / الإنجليزية',
      typology: WordOrderTypology.svo,
      subject: 'Subject (الفاعل)',
      verb: 'Verb (الفعل)',
      object: 'Object (المفعول)',
    ),
    TypologicalStructure(
      language: 'التركية / اليابانية',
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
    final double sm2Factor = PolyglotIntelligenceEngine.getMorphologicalMultiplier(_activeLocale);
    final String languageName = LanguagePackManager.getLanguageName(_activeLocale);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحور اللغوي الشامل (Wave 04)'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. رادار الكلمات المتشابهة والأصدقاء المزيفون
          _buildSectionCard(
            title: '1. رادار الكلمات المشتركة (INNOV-W04-01)',
            subtitle: 'كشف الأصدقاء المزيفين والتشابه الدلالي لربط الذاكرة باللغات الأخرى',
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

          // 2. ترتيب الجمل والأنماط التيبولوجية
          _buildSectionCard(
            title: '2. الترتيب التيبولوجي للجمل (INNOV-W04-02)',
            subtitle: 'بنية الجمل الأساسية (SVO / SOV / VSO) لفهم تسلسل الكلمات التلقائي',
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
                            color: Colors.grey.withValues(alpha: 0.1),
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

          // 3. الميزان الصرفي ومعامل التكرار SM-2
          _buildSectionCard(
            title: '3. ميزان التكرار الذكي والكثافة الصرفية (INNOV-W04-03)',
            subtitle: 'معايرة فترات مراجعة SM-2 تلقائياً بحسب التركيب اللغوي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('اللغة النشطة: $languageName', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('معامل SM-2: ${sm2Factor.toStringAsFixed(2)}x',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('• اللغات التحليلية (الإنجليزية/الفرنسية): سرعة مراجعة قياسية.'),
                const SizedBox(height: 4),
                const Text('• اللغات الاشتقاقية والسامية (العربية/الألمانية): تباعد زمني موسع لتثبيت القواعد والجذور.'),
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
