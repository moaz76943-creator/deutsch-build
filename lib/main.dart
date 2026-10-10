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
      home: const MainPackScreen(),
    );
  }
}

class MainPackScreen extends StatefulWidget {
  const MainPackScreen({super.key});

  @override
  State<MainPackScreen> createState() => _MainPackScreenState();
}

class _MainPackScreenState extends State<MainPackScreen> {
  bool _isLoading = true;
  String _statusMessage = 'جارٍ فحص حزم اللغات...';
  Map<String, dynamic>? _loadedData;
  List<dynamic> _availableLanguages = [];

  final String _manifestUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/manifest.json';
  final String _packsBaseUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/packs/';

  @override
  void initState() {
    super.initState();
    _checkAndInitPacks();
  }

  Future<File> _getLocalPackFile(String langCode) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/pack_$langCode.json');
  }

  Future<void> _checkAndInitPacks() async {
    try {
      final localArFile = await _getLocalPackFile('ar');
      if (await localArFile.exists()) {
        final content = await localArFile.readAsString();
        setState(() {
          _loadedData = jsonDecode(content);
          _isLoading = false;
        });
        return;
      }
      await _fetchStoreManifest();
    } catch (e) {
      setState(() {
        _statusMessage = 'تنبيه: شغّل الإنترنت لأول مرة لتنزيل حزمة لغتك.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStoreManifest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جارٍ الاتصال بمخزن اللغات...';
    });

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(_manifestUrl));
      final response = await request.close();
      final rawBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(rawBody);

      setState(() {
        _availableLanguages = data['languages'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'تعذر الوصول للمتجر. تأكد من اتصال الإنترنت.';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPack(String langCode, String fileName) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جارٍ تنزيل الحزمة وحفظها أوفلاين...';
    });

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$_packsBaseUrl$fileName'));
      final response = await request.close();

      final bytes = await response.fold<List<int>>([], (prev, elem) => prev..addAll(elem));
      final decompressedBytes = gzip.decode(bytes);
      final jsonString = utf8.decode(decompressedBytes);
      final parsedJson = jsonDecode(jsonString);

      final localFile = await _getLocalPackFile(langCode);
      await localFile.writeAsString(jsonString);

      setState(() {
        _loadedData = parsedJson;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ أثناء تنزيل الحزمة: $e';
        _isLoading = false;
      });
    }
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
              Text(_statusMessage, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_loadedData != null) {
      final header = _loadedData!['header'] ?? {};
      final domains = _loadedData!['domains'] as List<dynamic>? ?? [];

      return Scaffold(
        appBar: AppBar(
          title: Text('${header['name'] ?? 'اللغة'} (أوفلاين)'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تغيير أو تحديث اللغة',
              onPressed: () {
                setState(() {
                  _loadedData = null;
                });
                _fetchStoreManifest();
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: domains.length,
          itemBuilder: (context, index) {
            final domain = domains[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${domain['id']}'),
                ),
                title: Text(
                  domain['name'] ?? '',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('محور تعليمي • ${header['code']?.toUpperCase()}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم فتح: ${domain['name']}')),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('متجر اللغات المباشر')),
      body: _availableLanguages.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_statusMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchStoreManifest,
                      child: const Text('إعادة المحاولة'),
                    )
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _availableLanguages.length,
              itemBuilder: (context, index) {
                final lang = _availableLanguages[index];
                return ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('${lang['name']} (${lang['native_name']})'),
                  subtitle: Text('حجم الحزمة: ${(lang['size_bytes'] / 1024).toStringAsFixed(1)} KB'),
                  trailing: ElevatedButton(
                    onPressed: () => _downloadPack(lang['code'], lang['pack_file']),
                    child: const Text('تنزيل'),
                  ),
                );
              },
            ),
    );
  }
}
