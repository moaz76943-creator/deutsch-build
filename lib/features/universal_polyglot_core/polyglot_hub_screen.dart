import 'package:flutter/material.dart';
import 'polyglot_models.dart';
import 'package:deutsch_bilarabi/services/polyglot_intelligence_engine.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';

class UniversalPolyglotHubScreen extends StatefulWidget {
  const UniversalPolyglotHubScreen({super.key});

  @override
  State<UniversalPolyglotHubScreen> createState() =>
      _UniversalPolyglotHubScreenState();
}

class _UniversalPolyglotHubScreenState
    extends State<UniversalPolyglotHubScreen> with WidgetsBindingObserver {
  String _interfaceLocale = 'ar';
  String _sourceLocale = 'en';
  String _targetLocale = 'de';
  bool _isSourceReady = false;
  bool _isTargetReady = false;
  bool _isLoading = false;
  int _resolutionId = 0;

  static const String _interfacePrefKey = 'polyglot_interface_locale';
  static const String _sourcePrefKey = 'polyglot_source_locale';
  static const String _targetPrefKey = 'polyglot_target_locale';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resolveCapabilities();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await PreferencesService.instance();
    if (mounted) {
       setState(() {
          _interfaceLocale = prefs.getString(_interfacePrefKey) ?? 'ar';
          _sourceLocale = prefs.getString(_sourcePrefKey) ?? 'en';
          _targetLocale = prefs.getString(_targetPrefKey) ?? 'de';
       });
       _resolveCapabilities();
    }
  }

  Future<void> _savePreference(String key, String value) async {
    final prefs = await PreferencesService.instance();
    await prefs.setString(key, value);
  }

  Future<void> _resolveCapabilities() async {
    final int currentResolutionId = ++_resolutionId;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    bool sourceReady = false;
    bool targetReady = false;

    try {
      final isSourceSupported = LanguagePackManager.isLanguagesSupported(_sourceLocale);
      final isTargetSupported = LanguagePackManager.isLanguagesSupported(_targetLocale);

      if (isSourceSupported) {
         final sourceSync = PolyglotIntelligenceEngine.checkDeltaSyncVersion(_sourceLocale, 2);
         if (!(sourceSync['needsDeltaPatch'] as bool)) {
            sourceReady = await LanguagePackManager.verifyAndMountOfflinePack(_sourceLocale);
         }
      }

      if (isTargetSupported) {
         final targetSync = PolyglotIntelligenceEngine.checkDeltaSyncVersion(_targetLocale, 2);
         if (!(targetSync['needsDeltaPatch'] as bool)) {
            targetReady = await LanguagePackManager.verifyAndMountOfflinePack(_targetLocale);
         }
      }

    } catch (e) {
      // Functional UI on error
      sourceReady = false;
      targetReady = false;
    }

    if (mounted && _resolutionId == currentResolutionId) {
      setState(() {
        _isSourceReady = sourceReady;
        _isTargetReady = targetReady;
        _isLoading = false;
      });
    }
  }

  final List<CrossLinguisticCognate> _cognates = const [
    CrossLinguisticCognate(
      sourceWord: 'Gift (English: هدية)',
      targetWord: 'Gift (German: سُم)',
      sourceLang: 'EN',
      targetLang: 'DE',
      isFalseFriend: true,
      nuanceNotes:
          'تطابق لفظي واختلاف تام في المعنى؛ تحذير من الخلط أثناء الترجمة.',
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

  Widget _buildLanguageDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
    List<String> options,
  ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: options.map((code) {
              return DropdownMenuItem(
                value: code,
                child: Text(LanguagePackManager.getLanguageName(code)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sm2Factor =
        PolyglotIntelligenceEngine.getMorphologicalMultiplier(_interfaceLocale);
    final String languageName =
        LanguagePackManager.getLanguageName(_interfaceLocale);

    final isRtl = LanguagePackManager.isRtlLanguage(_interfaceLocale);
    final allLanguages = {
      ...LanguagePackManager.supportedBcp47Locales,
      ...LanguagePackManager.supportedLanguages
    }.toList();

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحور اللغوي الشامل'),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildLanguageDropdown('لغة الواجهة:', _interfaceLocale, (val) {
                      if (val != null && val != _interfaceLocale) {
                        setState(() {
                          _interfaceLocale = val;
                        });
                        _savePreference(_interfacePrefKey, val);
                        _resolveCapabilities();
                      }
                    }, allLanguages),
                    _buildLanguageDropdown('اللغة المصدر:', _sourceLocale, (val) {
                      if (val != null && val != _sourceLocale) {
                        setState(() {
                          _sourceLocale = val;
                        });
                        _savePreference(_sourcePrefKey, val);
                        _resolveCapabilities();
                      }
                    }, allLanguages),
                    _buildLanguageDropdown('اللغة الهدف:', _targetLocale, (val) {
                      if (val != null && val != _targetLocale) {
                        setState(() {
                          _targetLocale = val;
                        });
                        _savePreference(_targetPrefKey, val);
                        _resolveCapabilities();
                      }
                    }, allLanguages),
                  ],
                ),
              ),
            ),
            // 1. رادار الكلمات المتشابهة والأصدقاء المزيفون
            _buildSectionCard(
            title: '1. رادار الكلمات المشتركة (INNOV-W04-01)',
            subtitle:
                'كشف الأصدقاء المزيفين والتشابه الدلالي لربط الذاكرة باللغات الأخرى',
            child: Column(
              children: _cognates.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item.isFalseFriend
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
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
            subtitle:
                'بنية الجمل الأساسية (SVO / SOV / VSO) لفهم تسلسل الكلمات التلقائي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _typologies.map((t) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(t.language,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
                    Text('اللغة النشطة: $languageName',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          'معامل SM-2: ${sm2Factor.toStringAsFixed(2)}x',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                    '• اللغات التحليلية (الإنجليزية/الفرنسية): سرعة مراجعة قياسية.'),
                const SizedBox(height: 4),
                const Text(
                    '• اللغات الاشتقاقية والسامية (العربية/الألمانية): تباعد زمني موسع لتثبيت القواعد والجذور.'),
              ],
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: (_isSourceReady && _isTargetReady) ? () {} : null,
                          child: const Text('فتح القاموس'),
                        ),
                        ElevatedButton(
                          onPressed: (_isSourceReady && _isTargetReady) ? () {} : null,
                          child: const Text('بدء الدروس'),
                        ),
                      ],
                   ),
                   if (!_isSourceReady || !_isTargetReady)
                     Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                         _isLoading ? 'جاري التحقق...' : 'المحتوى غير متاح لهذا الزوج من اللغات',
                         style: TextStyle(color: _isLoading ? Colors.blue : Colors.red),
                       ),
                     ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'كل اللغات المسجلة:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final code = allLanguages[index];
                    return ListTile(
                      title: Text(LanguagePackManager.getLanguageName(code)),
                      subtitle: Text(code),
                      leading: Icon(
                        Icons.language,
                        color: LanguagePackManager.isLanguagesSupported(code)
                            ? Colors.green
                            : Colors.grey,
                      ),
                    );
                  },
                  childCount: allLanguages.length,
                ),
              ),
            ),
          ],
        ),
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
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}
