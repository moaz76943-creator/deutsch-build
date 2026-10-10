import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

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
      home: const SafePackScreen(),
    );
  }
}

class SafePackScreen extends StatefulWidget {
  const SafePackScreen({super.key});

  @override
  State<SafePackScreen> createState() => _SafePackScreenState();
}

class _SafePackScreenState extends State<SafePackScreen> {
  bool _isLoading = true;
  String _statusMessage = 'جارٍ التحقق من الحزم المثبتة...';
  Map<String, dynamic>? _activePack;
  List<dynamic> _availableLanguages = [];

  final String _manifestUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/manifest.json';
  final String _packsBaseUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/packs/';

  @override
  void initState() {
    super.initState();
    _initAppStorage();
  }

  Future<Directory> _getAppDir() async => await getApplicationDocumentsDirectory();

  Future<void> _initAppStorage() async {
    try {
      final dir = await _getAppDir();
      final configFile = File('${dir.path}/active_lang.json');

      if (await configFile.exists()) {
        final config = jsonDecode(await configFile.readAsString());
        final activeCode = config['active_code'];
        final packFile = File('${dir.path}/pack_$activeCode.json');

        if (await packFile.exists()) {
          final packData = jsonDecode(await packFile.readAsString());
          if (mounted) {
            setState(() {
              _activePack = packData;
              _isLoading = false;
            });
            return;
          }
        }
      }
      await _fetchManifest();
    } catch (_) {
      await _fetchManifest();
    }
  }

  Future<void> _fetchManifest() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'جارٍ الاتصال بمخزن اللغات...';
    });

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      final req = await client.getUrl(Uri.parse(_manifestUrl));
      final res = await req.close();

      if (res.statusCode != 200) {
        throw HttpException('خطأ في السيرفر: ${res.statusCode}');
      }

      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body);

      if (mounted) {
        setState(() {
          _availableLanguages = data['languages'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'تعذر الاتصال بالمخزن. يرجى التأكد من الإنترنت.';
          _isLoading = false;
        });
      }
    } finally {
      client?.close();
    }
  }

  Future<void> _safeDownloadAndVerify(Map<String, dynamic> lang) async {
    final code = lang['code'];
    final fileName = lang['pack_file'];
    final expectedSha = lang['sha256'];

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'جارٍ تنزيل حزمة $code...';
    });

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
      final req = await client.getUrl(Uri.parse('$_packsBaseUrl$fileName'));
      final res = await req.close();

      if (res.statusCode != 200) {
        throw HttpException('فشل التنزيل برمز: ${res.statusCode}');
      }

      final compressedBytes = await res.fold<List<int>>([], (p, e) => p..addAll(e));

      if (mounted) {
        setState(() => _statusMessage = 'جارٍ التحقق من بصمة الأمان (SHA-256)...');
      }

      // 1. التحقق من بصمة الملف المضغوط
      final actualSha = sha256.convert(compressedBytes).toString();
      if (expectedSha != null && actualSha.toLowerCase() != expectedSha.toString().toLowerCase()) {
        throw Exception('فشل التحقق الأمني: البصمة غير متطابقة.');
      }

      if (mounted) {
        setState(() => _statusMessage = 'جارٍ فك الضغط والتثبيت الآمن...');
      }

      // 2. فك الضغط والتحقق من صحة الـ JSON
      final decompressedBytes = gzip.decode(compressedBytes);
      final jsonString = utf8.decode(decompressedBytes);
      final parsedPack = jsonDecode(jsonString);

      // 3. النشر الذري (Atomic Write) عبر ملف مؤقت
      final dir = await _getAppDir();
      final tempFile = File('${dir.path}/pack_${code}_temp.json');
      await tempFile.writeAsString(jsonString);

      final finalFile = File('${dir.path}/pack_$code.json');
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(finalFile.path);

      // 4. حفظ مؤشر اللغة النشطة
      final configFile = File('${dir.path}/active_lang.json');
      await configFile.writeAsString(jsonEncode({'active_code': code}));

      if (mounted) {
        setState(() {
          _activePack = parsedPack;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'تنبيه: $e';
          _isLoading = false;
        });
      }
    } finally {
      client?.close();
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_statusMessage, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      );
    }

    if (_activePack != null) {
      final header = _activePack!['header'] ?? {};
      final domains = _activePack!['domains'] as List<dynamic>? ?? [];

      return Scaffold(
        appBar: AppBar(
          title: Text('${header['native'] ?? header['name']} (مثبتة أوفلاين)'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'المتجر واللغات',
              onPressed: () {
                setState(() => _activePack = null);
                _fetchManifest();
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: domains.length,
          itemBuilder: (context, i) {
            final d = domains[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(child: Text('${d['id']}')),
                title: Text(
                  d['name'] ?? '',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('محور تعليمي موثق'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('اختر لغة التعلم'), centerTitle: true),
      body: _availableLanguages.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: _fetchManifest,
                child: const Text('إعادة فحص المخزن'),
              ),
            )
          : ListView.builder(
              itemCount: _availableLanguages.length,
              itemBuilder: (context, i) {
                final lang = _availableLanguages[i];
                return ListTile(
                  leading: const Icon(Icons.public),
                  title: Text('${lang['name']} (${lang['native_name']})'),
                  subtitle: Text('حجم الحزمة: ${(lang['size_bytes'] / 1024).toStringAsFixed(1)} KB'),
                  trailing: ElevatedButton(
                    onPressed: () => _safeDownloadAndVerify(lang),
                    child: const Text('تثبيت آمن'),
                  ),
                );
              },
            ),
    );
  }
}
