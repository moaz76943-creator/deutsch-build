import 'package:flutter/material.dart';
import '../services/database_integrity_service.dart';
import '../services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_language_provider.dart';

/// Remote metadata and verified on-device archives, never fabricated pack sizes.
class LanguageManagerScreen extends ConsumerWidget {
  const LanguageManagerScreen({super.key});

  static const _background = Color(0xFF0F172A);
  static const _card = Color(0xFF1E293B);
  static const _accent = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeLanguageProvider);
    final packs = state.visiblePacks;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          title: const Text('إدارة حزم اللغات'),
          backgroundColor: _background,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'تحديث قائمة اللغات',
              onPressed: state.isLoadingCatalog
                  ? null
                  : () => ref
                      .read(activeLanguageProvider.notifier)
                      .refreshCatalog(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
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
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFFBBF24),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
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
    final hasArchive = state.hasVerifiedArchive(pack.code);
    final isDownloading = state.isDownloading(pack.code);
    final progress = state.downloadProgress[pack.code] ?? 0.0;
    final canDownload = pack.canDownload && !isInstalled && !hasArchive && !isDownloading;

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
    } else if (hasArchive) {
      status = 'أرشيف محمّل — لم يُثبّت';
      statusColor = const Color(0xFFFCD34D);
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
                  ),
                ),
              ],
            ),
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
                if (!isInstalled && !hasArchive)
                  _actionButton(
                    icon: Icons.download_rounded,
                    label: 'تنزيل',
                    onPressed: canDownload
                        ? () => _runAction(
                              context,
                              () => ref
                                  .read(activeLanguageProvider.notifier)
                                  .downloadPack(pack.code),
                              'تم التحقق من الأرشيف؛ لم يُثبّت المحتوى بعد.',
                            )
                        : null,
                  ),
                if (hasArchive && !isGerman && !isActive)
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
    );
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
          'سيُحذف الأرشيف المحمّل للغة ${pack.nativeName} فقط. لن تتأثر بيانات التقدم والمراجعة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (approved != true || !context.mounted) return;
    await _runAction(
      context,
      () => ref.read(activeLanguageProvider.notifier).deletePack(pack.code),
      'تم حذف الأرشيف المحمّل.',
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
  }
}
