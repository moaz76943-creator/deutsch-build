import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/pack_manager.dart';
import '../../../core/services/audio_tts_service.dart';

class SectionExplorerScreen extends StatefulWidget {
  final String initialLanguage;

  const SectionExplorerScreen({Key? key, this.initialLanguage = 'de'}) : super(key: key);

  @override
  State<SectionExplorerScreen> createState() => _SectionExplorerScreenState();
}

class _SectionExplorerScreenState extends State<SectionExplorerScreen> {
  late String currentLanguage;
  String selectedSection = 'HOME_KITCHEN';
  String selectedCefr = 'A1';
  bool isLoading = true;
  bool isSearching = false;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  static const Set<String> rtlLanguages = {'ar', 'fa', 'he', 'ur', 'ps', 'yi', 'ug'};

  // قائمة اللغات الـ 100 الكاملة
  final List<Map<String, String>> availableLanguages = [
    {'code': 'de', 'name': 'الألمانية (Deutsch)'},
    {'code': 'ar', 'name': 'العربية (العربية)'},
    {'code': 'en', 'name': 'الإنجليزية (English)'},
    {'code': 'fr', 'name': 'الفرنسية (Français)'},
    {'code': 'es', 'name': 'الإسبانية (Español)'},
    {'code': 'it', 'name': 'الإيطالية (Italiano)'},
    {'code': 'tr', 'name': 'التركية (Türkçe)'},
    {'code': 'pt', 'name': 'البرتغالية (Português)'},
    {'code': 'ru', 'name': 'الروسية (Русский)'},
    {'code': 'nl', 'name': 'الهولندية (Nederlands)'},
    {'code': 'ja', 'name': 'اليابانية (日本語)'},
    {'code': 'zh', 'name': 'الصينية (中文)'},
    {'code': 'ko', 'name': 'الكورية (한국어)'},
    {'code': 'hi', 'name': 'الهندية (हिन्दी)'},
    {'code': 'fa', 'name': 'الفارسية (فارسی)'},
    {'code': 'ur', 'name': 'الأردية (اردو)'},
    {'code': 'he', 'name': 'العبرية (עברית)'},
    {'code': 'sv', 'name': 'السويدية (Svenska)'},
    {'code': 'pl', 'name': 'البولندية (Polski)'},
    {'code': 'el', 'name': 'اليونانية (Ελληνικά)'},
    {'code': 'th', 'name': 'التايلاندية (ไทย)'},
    {'code': 'vi', 'name': 'الفيتنامية (Tiếng Việt)'},
    {'code': 'id', 'name': 'الإندونيسية (Bahasa Indonesia)'},
    {'code': 'uk', 'name': 'الأوكرانية (Українська)'},
    {'code': 'ro', 'name': 'الرومانية (Română)'},
    {'code': 'cs', 'name': 'التشيكية (Čeština)'},
    {'code': 'hu', 'name': 'المجرية (Magyar)'},
    {'code': 'da', 'name': 'الدنماركية (Dansk)'},
    {'code': 'fi', 'name': 'الفنلندية (Suomi)'},
    {'code': 'no', 'name': 'النرويجية (Norsk)'},
    {'code': 'sw', 'name': 'السواحلية (Kiswahili)'},
    {'code': 'am', 'name': 'الأمهرية (አማርኛ)'},
    {'code': 'bn', 'name': 'البنغالية (বাংলা)'},
    {'code': 'ms', 'name': 'الماليزية (Bahasa Melayu)'},
    {'code': 'sk', 'name': 'السلوفاكية (Slovenčina)'},
    {'code': 'bg', 'name': 'البلغارية (Български)'},
    {'code': 'hr', 'name': 'الكرواتية (Hrvatski)'},
    {'code': 'sr', 'name': 'الصربية (Српски)'},
    {'code': 'sl', 'name': 'السلوفينية (Slovenščina)'},
    {'code': 'lt', 'name': 'الليتوانية (Lietuvių)'},
    {'code': 'lv', 'name': 'اللاتفية (Latviešu)'},
    {'code': 'et', 'name': 'الإستونية (Eesti)'},
    {'code': 'ka', 'name': 'الجورجية (ქართული)'},
    {'code': 'hy', 'name': 'الأرمنية (Հայերեն)'},
    {'code': 'az', 'name': 'الأذربيجانية (Azərbaycan)'},
    {'code': 'kk', 'name': 'الكازاخية (Қазақша)'},
    {'code': 'uz', 'name': 'الأوزبكية (Oʻzbek)'},
    {'code': 'ta', 'name': 'التاميلية (தமிழ்)'},
    {'code': 'te', 'name': 'التيلجو (తెలుగు)'},
    {'code': 'ml', 'name': 'الماليالامية (മലയാളം)'},
    {'code': 'mr', 'name': 'الماراثية (मराठी)'},
    {'code': 'gu', 'name': 'الغوجاراتية (ગુજરાતી)'},
    {'code': 'kn', 'name': 'الكانادا (ಕನ್ನಡ)'},
    {'code': 'pa', 'name': 'البنجابية (ਪੰਜਾਬੀ)'},
    {'code': 'ne', 'name': 'النيبالية (नेपाली)'},
    {'code': 'si', 'name': 'السنهالية (සිංහල)'},
    {'code': 'my', 'name': 'البورمية (မြန်မာ)'},
    {'code': 'km', 'name': 'الخميرية (ខ្មែរ)'},
    {'code': 'lo', 'name': 'اللاوية (ລາວ)'},
    {'code': 'is', 'name': 'الآيسلندية (Íslenska)'},
    {'code': 'ga', 'name': 'الأيرلندية (Gaeilge)'},
    {'code': 'cy', 'name': 'الويلزية (Cymraeg)'},
    {'code': 'eu', 'name': 'الباسكية (Euskara)'},
    {'code': 'gl', 'name': 'الجاليكية (Galego)'},
    {'code': 'ca', 'name': 'الكتالونية (Català)'},
    {'code': 'af', 'name': 'الأفريكانية (Afrikaans)'},
    {'code': 'sq', 'name': 'الألبانية (Shqip)'},
    {'code': 'mk', 'name': 'المقدونية (Македонски)'},
    {'code': 'bs', 'name': 'البوسنية (Bosanski)'},
    {'code': 'be', 'name': 'البيلاروسية (Беларуская)'},
    {'code': 'tg', 'name': 'الطاجيكية (Тоҷикӣ)'},
    {'code': 'ky', 'name': 'القيرغيزية (Кыргызча)'},
    {'code': 'tk', 'name': 'التركمانية (Türkmen)'},
    {'code': 'tt', 'name': 'التترية (Татар)'},
    {'code': 'ug', 'name': 'الأويغورية (ئۇيغۇرچە)'},
    {'code': 'ps', 'name': 'البشتو (پښتو)'},
    {'code': 'so', 'name': 'الصومالية (Soomaali)'},
    {'code': 'yo', 'name': 'اليوروبا (Yorùbá)'},
    {'code': 'ig', 'name': 'الإيجبو (Igbo)'},
    {'code': 'ha', 'name': 'الهوسا (Hausa)'},
    {'code': 'zu', 'name': 'الزولو (isiZulu)'},
    {'code': 'xh', 'name': 'الخوسا (isiXhosa)'},
    {'code': 'st', 'name': 'السوتو (Sesotho)'},
    {'code': 'sn', 'name': 'الشونا (chiShona)'},
    {'code': 'rw', 'name': 'الكينيارواندا (Kinyarwanda)'},
    {'code': 'mg', 'name': 'الملغاشية (Malagasy)'},
    {'code': 'ny', 'name': 'الشيشيوا (Chichewa)'},
    {'code': 'ti', 'name': 'التغرينية (ትግርኛ)'},
    {'code': 'or', 'name': 'الأوديا (ଓଡ଼ିଆ)'},
    {'code': 'as', 'name': 'الآسامية (অসমীয়া)'},
    {'code': 'tl', 'name': 'التاغالوغ (Tagalog)'},
    {'code': 'jv', 'name': 'الجاوية (Basa Jawa)'},
    {'code': 'su', 'name': 'السوندية (Basa Sunda)'},
    {'code': 'eo', 'name': 'الإسبرانتو (Esperanto)'},
    {'code': 'la', 'name': 'اللاتينية (Latina)'},
    {'code': 'mt', 'name': 'المالطية (Malti)'},
    {'code': 'lb', 'name': 'اللوكسمبورغية (Lëtzebuergesch)'},
    {'code': 'sm', 'name': 'الساموية (Gagana Samoa)'},
    {'code': 'mi', 'name': 'الماورية (Māori)'},
    {'code': 'ht', 'name': 'الكريولية (Kreyòl Ayisyen)'}
  ];

  final List<Map<String, String>> sections = [
    {'id': 'HOME_KITCHEN', 'title': 'المطبخ والأواني 🍳'},
    {'id': 'HOME_BATHROOM', 'title': 'الحمام والنظافة 🚿'},
    {'id': 'HOME_LIVING', 'title': 'غرفة المعيشة 🛋️'},
    {'id': 'PHARMA', 'title': 'الصيدلة والعلاج 💊'},
    {'id': 'EMERGENCY', 'title': 'طوارئ وإسعاف 🚨'},
  ];

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.initialLanguage;
    loadSectionData();
  }

  bool get isCurrentRtl => rtlLanguages.contains(currentLanguage);

  Future<void> loadSectionData() async {
    setState(() => isLoading = true);
    try {
      await PackManager.initLanguagePack(currentLanguage);
      final data = await PackManager.getConceptsBySection(
        sectionId: selectedSection,
        cefr: selectedCefr,
      );
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> performInstantSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() => isSearching = true);
    final results = await PackManager.searchInstant(query.trim());
    setState(() {
      searchResults = results;
    });
  }

  void showLicenseDialog() async {
    final meta = await PackManager.getDatasetMetadata();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('المصادر والتراخيص المفتوحة ⚖️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المصدر: ${meta['source'] ?? 'Kaikki / Wiktionary'}'),
            const SizedBox(height: 6),
            Text('الترخيص: ${meta['license'] ?? 'CC BY-SA 4.0 / GFDL 1.3'}'),
            const SizedBox(height: 6),
            Text('تاريخ البناء: ${meta['pipeline_build'] ?? '2026-10-12'}'),
            const SizedBox(height: 12),
            const Text(
              'المحتوى المعجمي مرخص بموجب رخصة المشاع الإبداعي النسبة-المشاركة بالمثل، مع الالتزام الكامل بشروط النسبة القانونية.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void openQuizDialog(String conceptId, String word) async {
    final exercises = await PackManager.getExercises(conceptId);
    if (exercises.isEmpty || !mounted) return;

    final ex = exercises.first;
    final List distractors = jsonDecode(ex['distractors_json'] as String? ?? '[]');
    final List<String> options = [ex['correct_answer'] as String, ...distractors.map((e) => e.toString())]..shuffle();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ex['prompt'] as String? ?? 'اختر الإجابة الصحيحة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade50,
                  foregroundColor: Colors.black87,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final isCorrect = opt == ex['correct_answer'];
                  await PackManager.recordQuizResult(conceptId: conceptId, isCorrect: isCorrect);
                  await loadSectionData();

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isCorrect ? '✅ إجابة صحيحة! تم تحديث جدول المراجعة.' : '❌ خطأ! الإجابة: ${ex['correct_answer']}'),
                      backgroundColor: isCorrect ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: Text(opt, style: const TextStyle(fontSize: 16)),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = isSearching ? searchResults : items;

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentLanguage,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: Colors.indigo.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            onChanged: (newLang) {
              if (newLang != null && newLang != currentLanguage) {
                setState(() {
                  currentLanguage = newLang;
                  searchController.clear();
                  isSearching = false;
                });
                loadSectionData();
              }
            },
            items: availableLanguages.map((lang) {
              return DropdownMenuItem<String>(
                value: lang['code'],
                child: Text(lang['name']!),
              );
            }).toList(),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'التراخيص والمصادر',
            onPressed: showLicenseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: searchController,
              onChanged: performInstantSearch,
              decoration: InputDecoration(
                hintText: 'بحث فوري في المعجم (FTS5)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          performInstantSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          if (!isSearching) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: sections.map((sec) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sec['title']!),
                    selected: selectedSection == sec['id'],
                    onSelected: (val) {
                      if (val) {
                        setState(() => selectedSection = sec['id']!);
                        loadSectionData();
                      }
                    },
                  ),
                )).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['A1', 'A2', 'B1', 'B2'].map((lvl) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FilterChip(
                    label: Text(lvl),
                    selected: selectedCefr == lvl,
                    onSelected: (val) {
                      if (val) {
                        setState(() => selectedCefr = lvl);
                        loadSectionData();
                      }
                    },
                  ),
                )).toList(),
              ),
            ),
          ],
          const Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? Center(
                        child: Text(
                          isSearching
                              ? 'لم يتم العثور على نتائج مطابقة لـ "${searchController.text}"'
                              : 'لا توجد مفردات مسجلة لهذا المستوى حالياً.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: displayList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          final pos = item['part_of_speech'] ?? 'noun';
                          final word = item['word'] ?? item['display_text'] ?? '';
                          final boxLevel = item['box_level'] as int? ?? 0;

                          return Directionality(
                            textDirection: isCurrentRtl ? TextDirection.rtl : TextDirection.ltr,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: pos == 'verb'
                                    ? Colors.orange.shade100
                                    : (pos == 'phrase' ? Colors.purple.shade100 : Colors.blue.shade100),
                                child: Text(
                                  pos == 'verb' ? 'فعل' : (pos == 'phrase' ? 'جملة' : 'اسم'),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                word,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                isSearching ? 'المعرف: ${item['concept_id']}' : 'المستوى في الذاكرة: صندوق $boxLevel',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, color: Colors.blueGrey),
                                    tooltip: 'استماع للنطق',
                                    onPressed: () => AudioTtsService.speak(
                                      text: word,
                                      languageCode: currentLanguage,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.quiz, color: Colors.indigo),
                                    tooltip: 'بدء تمرين',
                                    onPressed: () => openQuizDialog(item['concept_id'], word),
                                  ),
                                ],
                              ),
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
