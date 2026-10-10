import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeutschApp());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch بالعربي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VocabularyScreen(),
    );
  }
}

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  bool _isLoading = true;
  String _status = 'جارٍ فحص المفردات المحفوظة...';
  List<dynamic> _vocabList = [];
  List<dynamic> _filteredList = [];
  int _currentIndex = 0;
  bool _showTranslation = false;
  bool _isCardMode = true;

  final String _masterPackUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/deutsch_deep_master.pack.gz';

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/deutsch_master_vocab.json');
  }

  Future<void> _loadVocabulary() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        final list = data['vocabulary'] as List<dynamic>? ?? [];
        if (list.isNotEmpty && mounted) {
          setState(() {
            _vocabList = list;
            _filteredList = list;
            _isLoading = false;
          });
          return;
        }
      }
      await _downloadVocabulary();
    } catch (_) {
      await _downloadVocabulary();
    }
  }

  Future<void> _downloadVocabulary() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _status = 'جارٍ تنزيل المفردات الألمانية الحقيقية...';
    });

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
      final req = await client.getUrl(Uri.parse(_masterPackUrl));
      final res = await req.close();

      if (res.statusCode != 200) {
        throw HttpException('خطأ في السيرفر: ${res.statusCode}');
      }

      final bytes = await res.fold<List<int>>([], (p, e) => p..addAll(e));
      final decompressed = gzip.decode(bytes);
      final jsonStr = utf8.decode(decompressed);
      final data = jsonDecode(jsonStr);

      final file = await _getLocalFile();
      await file.writeAsString(jsonStr);

      final list = data['vocabulary'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _vocabList = list;
          _filteredList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'تعذر التنزيل: تأكد من تفعيل الإنترنت لأول مرة.';
          _isLoading = false;
        });
      }
    } finally {
      client?.close();
    }
  }

  Color _getArticleColor(String? article) {
    switch (article?.toLowerCase().trim()) {
      case 'der':
        return Colors.blue.shade700;
      case 'die':
        return Colors.red.shade700;
      case 'das':
        return Colors.green.shade700;
      default:
        return Colors.deepPurple;
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredList = _vocabList;
      } else {
        _filteredList = _vocabList.where((item) {
          final word = (item['word'] ?? '').toString().toLowerCase();
          final tr = (item['translation'] ?? '').toString().toLowerCase();
          final q = query.toLowerCase();
          return word.contains(q) || tr.contains(q);
        }).toList();
      }
      _currentIndex = 0;
      _showTranslation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    if (_vocabList.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _downloadVocabulary,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCardMode ? 'بطاقات الكلمات (${_filteredList.length})' : 'قاموس المفردات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isCardMode ? Icons.list : Icons.style),
            tooltip: _isCardMode ? 'عرض كقائمة' : 'عرض كبطاقات',
            onPressed: () => setState(() => _isCardMode = !_isCardMode),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث المحتوى',
            onPressed: _downloadVocabulary,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة ألمانية أو عربية...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(child: Text('لا توجد نتائج للبحث'))
                : _isCardMode
                    ? _buildCardCarousel()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCarousel() {
    final item = _filteredList[_currentIndex];
    final word = item['word'] ?? '';
    final article = item['article'] ?? '';
    final translation = item['translation'] ?? '';
    final artColor = _getArticleColor(article);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => setState(() => _showTranslation = !_showTranslation),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: double.infinity,
                height: 280,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (article.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: artColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          article,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: artColor),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      word,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 36),
                    AnimatedOpacity(
                      opacity: _showTranslation ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        translation,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (!_showTranslation)
                      Text(
                        'اضغط على البطاقة لإظهار المعنى',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentIndex > 0
                  ? () => setState(() {
                        _currentIndex--;
                        _showTranslation = false;
                      })
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${_currentIndex + 1} / ${_filteredList.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton.filled(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentIndex < _filteredList.length - 1
                  ? () => setState(() {
                        _currentIndex++;
                        _showTranslation = false;
                      })
                  : null,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _filteredList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = _filteredList[i];
        final word = item['word'] ?? '';
        final article = item['article'] ?? '';
        final translation = item['translation'] ?? '';
        final artColor = _getArticleColor(article);

        return ListTile(
          leading: article.isNotEmpty
              ? CircleAvatar(
                  backgroundColor: artColor.withOpacity(0.15),
                  child: Text(article, style: TextStyle(color: artColor, fontWeight: FontWeight.bold, fontSize: 13)),
                )
              : const CircleAvatar(child: Icon(Icons.translate, size: 18)),
          title: Text(word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          trailing: Text(
            translation,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          onTap: () {
            setState(() {
              _currentIndex = i;
              _showTranslation = true;
              _isCardMode = true;
            });
          },
        );
      },
    );
  }
}
