import 'dart:async';
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
  double downloadProgress = 0.0;
  String loadingMessage = 'جاري إعداد الحزمة...';
  String? loadError;
  bool isSearching = false;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  int _loadGeneration = 0;
  int _searchGeneration = 0;
  Timer? _searchDebounce;

  static const Set<String> rtlLanguages = {'ar', 'fa', 'he', 'ur', 'ps', 'yi', 'ug'};

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

  @override
  void dispose() {
    _loadGeneration++;
    _searchGeneration++;
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  bool get isCurrentRtl => rtlLanguages.contains(currentLanguage);

  Future<void> loadSectionData() async {
    final gen = ++_loadGeneration;
    _searchGeneration++;
    _searchDebounce?.cancel();

    if (!mounted) return;

    setState(() {
      isLoading = true;
      loadError = null;
      downloadProgress = 0.0;
      loadingMessage = 'جاري إعداد حزمة اللغة...';
    });

    try {
      await PackManager.initLanguagePack(
        currentLanguage,
        onDownloadProgress: (progress) {
          if (!mounted || gen != _loadGeneration) return;
          setState(() {
            downloadProgress = progress;
            loadingMessage = 'تنزيل الحزمة: ${(progress * 100).toInt()}%';
          });
        },
      );

      final data = await PackManager.getConceptsBySection(
        sectionId: selectedSection,
        cefr: selectedCefr,
      );

      if (!mounted || gen != _loadGeneration) return;
      setState(() {
        items = data;
        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted || gen != _loadGeneration) return;
      setState(() {
        isLoading = false;
        loadError = e.toString();
        loadingMessage = 'تعذر تحميل المحتوى';
      });
    }
  }

  void performInstantSearch(String query) {
    final gen = ++_searchGeneration;
    _searchDebounce?.cancel();
    final normalized = query.trim();

    if (!mounted) return;

    if (normalized.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() => isSearching = true);

    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final results = await PackManager.searchInstant(normalized);
        if (!mounted || gen != _searchGeneration) return;
        setState(() {
          searchResults = results;
        });
      } catch (e) {
        if (!mounted || gen != _searchGeneration) return;
        setState(() {
          searchResults = [];
          loadError = 'فشل البحث: $e';
        });
      }
    });
  }

  void showLicenseDialog() async {
    final meta = await PackManager.getDatasetMetadata();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('المصادر والتراخيص المفتوحة ⚖️'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المصدر: ${meta['source'] ?? 'Kaikki / Wiktionary'}'),
              const SizedBox(height: 6),
              Text('الترخيص: ${meta['license'] ?? 'CC BY-SA 4.0'}'),
              const SizedBox(height: 12),
              const Text(
                'المحتوى المعجمي مرخص بموجب رخصة المشاع الإبداعي CC BY-SA 4.0. يمكنك تصدير البيانات بالكامل:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          Wrap(
            spacing: 8,
            children: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('تصدير JSON'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    final path = await PackManager.exportDatasetAsJson(currentLanguage);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ تم التصدير: $path'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تعذر التصدير: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          ),
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final isCorrect = opt == ex['correct_answer'];
                    await PackManager.recordQuizResult(conceptId: conceptId, isCorrect: isCorrect);
                    await loadSectionData();

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isCorrect ? '✅ إجابة صحيحة! تم تحديث المراجعة.' : '❌ خطأ! الإجابة: ${ex['correct_answer']}'),
                        backgroundColor: isCorrect ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: Text(opt, textAlign: TextAlign.center, softWrap: true),
                ),
              ),
            )).toList(),
          ),
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
            isDense: true,
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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'التراخيص والتصدير',
            onPressed: showLicenseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.indigo.shade50,
              child: Column(
                children: [
                  Text(loadingMessage, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: downloadProgress > 0 ? downloadProgress : null),
                ],
              ),
            ),
          if (loadError != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(loadError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
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
            child: displayList.isEmpty && !isLoading
                ? Center(
                    child: Text(
                      isSearching
                          ? 'لم يتم العثور على نتائج لـ "${searchController.text}"'
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
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            softWrap: true,
                          ),
                          subtitle: Text(
                            isSearching ? 'المعرف: ${item['concept_id']}' : 'المستوى في الذاكرة: صندوق $boxLevel',
                          ),
                          trailing: Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.blueGrey),
                                tooltip: 'استماع للنطق',
                                onPressed: () async {
                                  try {
                                    await AudioTtsService.speak(
                                      text: word,
                                      languageCode: currentLanguage,
                                    );
                                  } catch (err) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('⚠️ تعذر النطق: $err'),
                                          backgroundColor: Colors.orange.shade800,
                                        ),
                                      );
                                    }
                                  }
                                },
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
