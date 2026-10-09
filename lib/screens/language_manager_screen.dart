import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../services/database_service.dart';

class LanguageManagerScreen extends StatefulWidget {
  const LanguageManagerScreen({super.key});

  @override
  State<LanguageManagerScreen> createState() => _LanguageManagerScreenState();
}

class _LanguageManagerScreenState extends State<LanguageManagerScreen> {
  bool _isLoading = false;
  
  // قائمة تجريبية توضيحية لبعض اللغات المتاحة للتنزيل من السحابة
  final List<Map<String, dynamic>> _languages = [
    {"code": "de", "name": "الألمانية (Deutsch)", "downloaded": true, "size": "4.2 MB"},
    {"code": "en", "name": "الإنجليزية (English)", "downloaded": true, "size": "3.8 MB"},
    {"code": "es", "name": "الإسبانية (Español)", "downloaded": false, "size": "4.5 MB"},
    {"code": "fr", "name": "الفرنسية (Français)", "downloaded": false, "size": "4.6 MB"},
    {"code": "tr", "name": "التركية (Türkçe)", "downloaded": false, "size": "3.9 MB"},
    {"code": "it", "name": "الإيطالية (Italiano)", "downloaded": false, "size": "4.1 MB"},
    {"code": "ru", "name": "الروسية (Русский)", "downloaded": false, "size": "5.0 MB"},
    {"code": "ja", "name": "اليابانية (日本語)", "downloaded": false, "size": "5.2 MB"},
  ];

  Future<void> _toggleDownload(int index) async {
    setState(() => _isLoading = true);
    // محاكاة عملية الاتصال بالسحابة وتنزيل حزمة اللغة وتخزينها محلياً
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _languages[index]['downloaded'] = !_languages[index]['downloaded'];
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languages[index]['downloaded'] ? 'تم تنزيل حزمة اللغة بنجاح!' : 'تم إزالة حزمة اللغة.'),
          backgroundColor: const Color(0xFF38BDF8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة اللغات والحزم السحابية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'اختر لغات التعلم الخاصة بك (تدعم التحميل والاستخدام بدون إنترنت)',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isDownloaded = lang['downloaded'] as bool;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppBaseGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      lang['name'] as String,
                                      style: AppTypography.display.copyWith(color: Colors.white, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isDownloaded ? 'متوفرة محلياً (${lang['size']})' : 'حزمة سحابية (${lang['size']})',
                                      style: AppTypography.body.copyWith(
                                        color: isDownloaded ? const Color(0xFF34D399) : Colors.white.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDownloaded ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF38BDF8),
                                  foregroundColor: isDownloaded ? Colors.white : Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _isLoading ? null : () => _toggleDownload(index),
                                icon: Icon(
                                  isDownloaded ? Icons.check_rounded : Icons.download_rounded,
                                  size: 18,
                                ),
                                label: Text(isDownloaded ? 'منزلة' : 'تنزيل'),
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
          ),
        ),
      ),
    );
  }
}
