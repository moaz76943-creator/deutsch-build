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
  String _statusMessage = 'جارٍ فحص حزم اللغات المحفوظة...';
  Map<String, dynamic>? _loadedPack;
  List<dynamic> _availableLanguages = [];

  final String _manifestUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/manifest.json';
  final String _packsBaseUrl =
      'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/packs/';

  @override
  void initState() {
    super.initState();
    _checkSavedPack();
  }

  Future<File> _getLocalPackFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/current_active_pack.json');
  }

  Future<void> _checkSavedPack() async {
    try {
      final file = await _getLocalPackFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _loadedPack = jsonDecode(content);
          _isLoading = false;
        });
        return;
      }
      await _fetchManifest();
    } catch (_) {
      await _fetchManifest();
    }
  }

  Future<void> _fetchManifest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جارٍ الاتصال بمخزن اللغات...';
    });

    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(_manifestUrl));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final data = jsonDecode(body);

      setState(() {
        _availableLanguages = data['languages'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'تعذر الاتصال بالمخزن. يرجى تفعيل الإنترنت.';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadLanguage(String code, String packFile) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جارٍ تنزيل حزمة $code وحفظها أوفلاين...';
    });

    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('$_packsBaseUrl$packFile'));
      final res = await req.close();
      final bytes = await res.fold<List<int>>([], (p, e) => p..addAll(e));
      
      final decompressed = gzip.decode(bytes);
      final jsonStr = utf8.decode(decompressed);
      final parsed = jsonDecode(jsonStr);

      final file = await _getLocalPackFile();
      await file.writeAsString(jsonStr);

      setState(() {
        _loadedPack = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'فشل التنزيل: $e';
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
              Text(_statusMessage, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      );
    }

    if (_loadedPack != null) {
      final header = _loadedPack!['header'] ?? {};
      final domains = _loadedPack!['domains'] as List<dynamic>? ?? [];

      return Scaffold(
        appBar: AppBar(
          title: Text('${header['native'] ?? header['name']} (أوفلاين)'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'تغيير اللغة',
              onPressed: () {
                setState(() => _loadedPack = null);
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Text('${d['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(
                  d['name'] ?? '',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('المحور التعليمي • بطاقات تفاعلية'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DomainCardScreen(domainName: d['name'] ?? ''),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('اختر لغتك التعليمية'), centerTitle: true),
      body: _availableLanguages.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: _fetchManifest,
                child: const Text('إعادة المحاولة'),
              ),
            )
          : ListView.builder(
              itemCount: _availableLanguages.length,
              itemBuilder: (context, i) {
                final lang = _availableLanguages[i];
                return ListTile(
                  leading: const Icon(Icons.public, color: Colors.deepPurple),
                  title: Text('${lang['name']} (${lang['native_name']})'),
                  subtitle: Text('حجم الحزمة: ${(lang['size_bytes'] / 1024).toStringAsFixed(1)} KB'),
                  trailing: ElevatedButton(
                    onPressed: () => _downloadLanguage(lang['code'], lang['pack_file']),
                    child: const Text('تنزيل'),
                  ),
                );
              },
            ),
    );
  }
}

class DomainCardScreen extends StatefulWidget {
  final String domainName;
  const DomainCardScreen({super.key, required this.domainName});

  @override
  State<DomainCardScreen> createState() => _DomainCardScreenState();
}

class _DomainCardScreenState extends State<DomainCardScreen> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.domainName)),
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => _showBack = !_showBack),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(24),
            child: Container(
              height: 220,
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showBack ? 'الترجمة والمعنى' : 'المفردة / الجملة بالألمانية',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showBack ? widget.domainName : 'Guten Tag',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _showBack ? 'اضغط للعودة إلى الوجه' : 'اضغط لقلب البطاقة ومعرفة المعنى',
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
