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
<<<<<<< HEAD
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 940),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حزم اللغات المتاحة',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'المثبتة: ${state.installedCodes.length}  •  في الكتالوج: ${state.remotePacks.length}',
                          style: const TextStyle(color: Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'الأحجام مأخوذة من الكتالوج. تنزيل الأرشيف '
                          'لا يعني استيراد محتواه إلى قاعدة المعجم.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Row(
=======
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
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
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
<<<<<<< HEAD
                        ],
                      ],
                    ),
                  ),
                  if (state.isLoadingCatalog)
                    const LinearProgressIndicator(
                      color: _accent,
                      backgroundColor: _card,
                      minHeight: 2,
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => ref
                          .read(activeLanguageProvider.notifier)
                          .refreshCatalog(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        itemCount: packs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _packCard(context, ref, state, packs[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
  }

  Widget _packCard(
    BuildContext context,
    WidgetRef ref,
    ActiveLanguageState state,
    LanguagePackMetadata pack,
  ) {
    final isGerman = pack.code == 'de';
    final isQuarantined = state.quarantinedCodes.contains(pack.code);
    final isActive = state.activeLanguageCode == pack.code;
    final isInstalled = state.isInstalled(pack.code);
    final isDownloading = state.isDownloading(pack.code);
    final progress = state.downloadProgress[pack.code] ?? 0.0;
    final canDownload = pack.canDownload && !isInstalled && !isDownloading;

    final String status;
    final Color statusColor;
    if (isQuarantined) {
      status = 'معزولة — قاعدة غير سليمة';
      statusColor = const Color(0xFFFCA5A5);
    } else if (isDownloading) {
      status = 'جارٍ التنزيل';
      statusColor = _accent;
    } else if (isActive) {
      status = 'نشطة';
      statusColor = const Color(0xFF6EE7B7);
    } else if (isInstalled) {
      status = 'مثبتة';
      statusColor = const Color(0xFF86EFAC);
    } else if (pack.canDownload) {
      status = 'قابلة للتنزيل';
      statusColor = const Color(0xFFFCD34D);
    } else {
      status = 'غير متاحة للتنزيل';
      statusColor = const Color(0xFF94A3B8);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? _accent.withValues(alpha: 0.65) : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _flagFor(pack.code),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.nativeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pack.name} • ${pack.code.toUpperCase()}',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الحجم: ${_formattedSize(pack.sizeBytes)}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statusChip(status, statusColor),
                      if (isGerman) ...[
                        const SizedBox(height: 6),
                        _statusChip('Built-in', const Color(0xFFCBD5E1)),
                      ],
                    ],
=======
                        ),
                      );
                    },
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
            if (isDownloading) ...[
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
                color: _accent,
                backgroundColor: Colors.black26,
              ),
              const SizedBox(height: 5),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isQuarantined)
                  _actionButton(
                    icon: Icons.refresh_rounded,
                    label: 'إعادة فحص محلية',
                    onPressed: () => _runAction(
                      context,
                      () async {
                        final recovered =
                            await DatabaseIntegrityService.instance.recover(
                          languageCode: pack.code,
                          closeMounted: () => DatabaseService.instance
                              .closeContentDb(pack.code),
                          remount: () =>
                              DatabaseService.instance.getContentDb(pack.code),
                        );
                        if (!recovered) {
                          throw StateError('Pack still quarantined');
                        }
                      },
                      'تم فحص القاعدة المحلية بنجاح.',
                    ),
                  ),
                if (isInstalled && !isActive)
                  _actionButton(
                    icon: Icons.play_arrow_rounded,
                    label: 'استخدام',
                    onPressed: isDownloading
                        ? null
                        : () => _runAction(
                              context,
                              () => ref
                                  .read(activeLanguageProvider.notifier)
                                  .selectLanguage(pack.code),
                              'تم اختيار اللغة: ${pack.nativeName}',
                            ),
                  ),
                if (!isInstalled)
                  _actionButton(
                    icon: Icons.download_rounded,
                    label: 'تنزيل',
                    onPressed: canDownload
                        ? () => _runAction(
                              context,
                              () => ref
                                  .read(activeLanguageProvider.notifier)
                                  .downloadPack(pack.code),
                              'تم حفظ الأرشيف والتحقق من سلامته.',
                            )
                        : null,
                  ),
                if (isInstalled && !isGerman && !isActive)
                  _actionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'حذف',
                    destructive: true,
                    onPressed: isDownloading
                        ? null
                        : () => _confirmDelete(context, ref, pack),
                  ),
                if (isActive)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'اللغة المحددة حاليًا',
                      style: TextStyle(color: Color(0xFF6EE7B7)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    )
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool destructive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: destructive ? const Color(0xFFFCA5A5) : Colors.white,
        side: BorderSide(
          color: destructive ? const Color(0xFFF87171) : _accent,
        ),
        minimumSize: const Size(96, 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LanguagePackMetadata pack,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف حزمة اللغة؟'),
        content: Text(
          'سيُحذف الأرشيف المحلي للغة ${pack.nativeName} لتحرير مساحة التخزين. لا يمكن حذف الألمانية المضمنة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
          ),
        ),
      ),
    );
<<<<<<< HEAD
    if (approved != true || !context.mounted) return;
    await _runAction(
      context,
      () => ref.read(activeLanguageProvider.notifier).deletePack(pack.code),
      'تم حذف الأرشيف المحلي.',
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('تعذر تنفيذ العملية: $error')),
        );
    }
  }

  String _formattedSize(int? bytes) {
    if (bytes == null) return 'غير معروف';
    final megabytes = bytes / (1024 * 1024);
    return '${megabytes.toStringAsFixed(megabytes < 0.01 ? 4 : 2)} MB';
  }

  String _flagFor(String code) {
    const flags = <String, String>{
      'de': '🇩🇪',
      'en': '🇬🇧',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'nl': '🇳🇱',
      'ru': '🇷🇺',
      'tr': '🇹🇷',
      'zh': '🇨🇳',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'hi': '🇮🇳',
      'uk': '🇺🇦',
      'pl': '🇵🇱',
      'sv': '🇸🇪',
      'no': '🇳🇴',
      'fi': '🇫🇮',
      'el': '🇬🇷',
      'id': '🇮🇩',
      'vi': '🇻🇳',
      'th': '🇹🇭',
      'fa': '🇮🇷',
      'he': '🇮🇱',
      'cs': '🇨🇿',
      'da': '🇩🇰',
      'ro': '🇷🇴',
      'hu': '🇭🇺',
    };
    return flags[code] ?? '🌐';
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  }
}
