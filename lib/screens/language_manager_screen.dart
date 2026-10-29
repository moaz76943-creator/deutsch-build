import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

class LanguageManagerScreen extends StatefulWidget {
  const LanguageManagerScreen({super.key});

  @override
  State<LanguageManagerScreen> createState() => _LanguageManagerScreenState();
}

class _LanguageManagerScreenState extends State<LanguageManagerScreen> {
  bool _isLoading = false;
  late List<Map<String, dynamic>> _languages;

  @override
  void initState() {
    super.initState();
    _languages = LanguagePackManager.supportedLanguages.map((code) {
      final name = LanguagePackManager.getLanguageName(code);
      final isDefault = ['de', 'ar', 'en'].contains(code);
      return {
        'code': code,
        'name': name,
        'downloaded': isDefault,
        'size': '${(3.2 + (code.hashCode.abs() % 25) / 10).toStringAsFixed(1)} MB',
      };
    }).toList();
  }

  Future<void> _toggleDownload(int index) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final item = _languages[index];
    final willDownload = !(item["downloaded"] as bool);
    if (willDownload) {
      final ttsLocale = LanguagePackManager.getTtsLocale(item['code'] as String);
      await LanguagePackManager.verifyAndMountOfflinePack(ttsLocale);
    }
    setState(() {
      item['downloaded'] = willDownload;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            willDownload
                ? 'تم تحميل وتفعيل حزمة لغة: ${item['name']}'
                : 'تم إلغاء حزمة لغة: ${item['name']}',
          ),
          backgroundColor: const Color(0xFF38BDF8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة حزم اللغات (100 لغة)'),
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
              children: [
                Text(
                  'حمّل اللغات المتاحة للعمل بدون إنترنت (100 لغة مدعومة)',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
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
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang['name'] as String,
                                      style: AppTypography.display.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isDownloaded
                                          ? 'حزمة متوفرة (${lang['size']})'
                                          : 'جاهزة للتحميل (${lang['size']})',
                                      style: AppTypography.body.copyWith(
                                        color: isDownloaded
                                            ? const Color(0xFF34D399)
                                            : Colors.white.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDownloaded
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFF38BDF8),
                                  foregroundColor: isDownloaded
                                      ? Colors.white
                                      : Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _isLoading ? null : () => _toggleDownload(index),
                                icon: Icon(
                                  isDownloaded ? Icons.check_rounded : Icons.download_rounded,
                                  size: 18,
                                ),
                                label: Text(isDownloaded ? 'مثبت' : 'تنزيل'),
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
