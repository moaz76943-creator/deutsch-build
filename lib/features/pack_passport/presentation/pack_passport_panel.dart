import 'package:flutter/material.dart';

import '../../../core/theme/adaptive_glass_surface.dart';
import '../application/pack_passport_controller.dart';
import '../domain/pack_passport_models.dart';

final class PackPassportStrings {
  const PackPassportStrings({
    required this.title,
    required this.empty,
    required this.loading,
    required this.failed,
    required this.installed,
    required this.offlineReady,
    required this.size,
    required this.version,
    required this.verified,
    required this.yes,
    required this.no,
    required this.partial,
    required this.notInstalled,
    required this.unverified,
    required this.blocked,
    required this.logicalPacks,
    required this.physicalShards,
  });

  factory PackPassportStrings.arabic() => const PackPassportStrings(
        title: 'جواز سفر اللغات',
        empty: 'لا توجد اتجاهات لغوية لعرضها.',
        loading: 'جارٍ فحص حالة الحزم المحلية…',
        failed: 'تعذر قراءة حالة الحزم.',
        installed: 'مثبت',
        offlineReady: 'جاهز دون إنترنت',
        size: 'الحجم',
        version: 'الإصدار',
        verified: 'موثّق',
        yes: 'نعم',
        no: 'لا',
        partial: 'جزئي',
        notInstalled: 'غير مثبت',
        unverified: 'بانتظار التحقق',
        blocked: 'محظور',
        logicalPacks: 'الحزم المنطقية',
        physicalShards: 'شظايا PAD',
      );

  factory PackPassportStrings.english() => const PackPassportStrings(
        title: 'Pack Passport',
        empty: 'No language directions to display.',
        loading: 'Checking local pack state…',
        failed: 'Pack state could not be read.',
        installed: 'Installed',
        offlineReady: 'Offline Ready',
        size: 'Size',
        version: 'Version',
        verified: 'Verified',
        yes: 'Yes',
        no: 'No',
        partial: 'Partial',
        notInstalled: 'Not installed',
        unverified: 'Pending verification',
        blocked: 'Blocked',
        logicalPacks: 'Logical packs',
        physicalShards: 'PAD shards',
      );

  final String title;
  final String empty;
  final String loading;
  final String failed;
  final String installed;
  final String offlineReady;
  final String size;
  final String version;
  final String verified;
  final String yes;
  final String no;
  final String partial;
  final String notInstalled;
  final String unverified;
  final String blocked;
  final String logicalPacks;
  final String physicalShards;
}

typedef PackPassportLanguageLabelBuilder = String Function(
  String languageCode,
);

final class PackPassportPanel extends StatelessWidget {
  const PackPassportPanel({
    super.key,
    required this.controller,
    this.strings,
    this.languageLabelBuilder,
  });

  final PackPassportController controller;
  final PackPassportStrings? strings;
  final PackPassportLanguageLabelBuilder? languageLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final copy = strings ?? PackPassportStrings.arabic();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Semantics(
          container: true,
          label: copy.title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                copy.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildBody(context, copy),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    PackPassportStrings copy,
  ) {
    switch (controller.state) {
      case PackPassportLoadState.idle:
        return _InfoSurface(
          icon: Icons.inventory_2_outlined,
          text: copy.empty,
        );
      case PackPassportLoadState.loading:
        return _InfoSurface(
          icon: Icons.sync,
          text: copy.loading,
          progress: true,
        );
      case PackPassportLoadState.failed:
        return _InfoSurface(
          icon: Icons.warning_amber_rounded,
          text: copy.failed,
          error: true,
        );
      case PackPassportLoadState.ready:
        if (controller.entries.isEmpty) {
          return _InfoSurface(
            icon: Icons.inventory_2_outlined,
            text: copy.empty,
          );
        }
        return Column(
          children: <Widget>[
            for (final entry in controller.entries) ...<Widget>[
              _PackPassportCard(
                entry: entry,
                strings: copy,
                languageLabelBuilder: languageLabelBuilder,
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
    }
  }
}

final class _PackPassportCard extends StatelessWidget {
  const _PackPassportCard({
    required this.entry,
    required this.strings,
    required this.languageLabelBuilder,
  });

  final PackPassportEntry entry;
  final PackPassportStrings strings;
  final PackPassportLanguageLabelBuilder? languageLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final source = _languageLabel(entry.request.source);
    final target = _languageLabel(entry.request.target);
    final installedText = _installedText();
    final verifiedText = _verificationText();

    return Semantics(
      container: true,
      label: '$source to $target',
      value:
          '${strings.installed}: $installedText, '
          '${strings.offlineReady}: '
          '${entry.offlineReady ? strings.yes : strings.no}, '
          '${strings.verified}: $verifiedText',
      child: AdaptiveGlassSurface(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '$source  →  $target',
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(
                  entry.offlineReady
                      ? Icons.offline_pin_outlined
                      : Icons.cloud_download_outlined,
                  semanticLabel: strings.offlineReady,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StatusPill(
                  icon: Icons.download_done_outlined,
                  label: strings.installed,
                  value: installedText,
                  status: entry.installState ==
                          PackPassportInstallState.installed
                      ? _VisualStatus.good
                      : entry.installState ==
                              PackPassportInstallState.partial
                          ? _VisualStatus.pending
                          : _VisualStatus.neutral,
                ),
                _StatusPill(
                  icon: Icons.offline_bolt_outlined,
                  label: strings.offlineReady,
                  value: entry.offlineReady ? strings.yes : strings.no,
                  status: entry.offlineReady
                      ? _VisualStatus.good
                      : _VisualStatus.pending,
                ),
                _StatusPill(
                  icon: Icons.sd_storage_outlined,
                  label: strings.size,
                  value: _sizeText(entry),
                  status: _VisualStatus.neutral,
                ),
                _StatusPill(
                  icon: Icons.sell_outlined,
                  label: strings.version,
                  value: entry.versionSummary,
                  status: _VisualStatus.neutral,
                ),
                _StatusPill(
                  icon: Icons.verified_user_outlined,
                  label: strings.verified,
                  value: verifiedText,
                  status: entry.verificationStatus ==
                          PackPassportVerificationStatus.verified
                      ? _VisualStatus.good
                      : entry.verificationStatus ==
                              PackPassportVerificationStatus.blocked
                          ? _VisualStatus.error
                          : _VisualStatus.pending,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${strings.logicalPacks}: ${entry.logicalPackIds.length}'
              ' · '
              '${strings.physicalShards}: ${entry.physicalShardIds.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (entry.blockReason != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                entry.blockReason!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _languageLabel(String code) =>
      languageLabelBuilder?.call(code) ?? code.toUpperCase();

  String _installedText() {
    switch (entry.installState) {
      case PackPassportInstallState.notInstalled:
        return strings.notInstalled;
      case PackPassportInstallState.partial:
        return '${strings.partial} '
            '(${entry.installedComponentCount}/'
            '${entry.requiredComponentCount})';
      case PackPassportInstallState.installed:
        return strings.yes;
    }
  }

  String _verificationText() {
    switch (entry.verificationStatus) {
      case PackPassportVerificationStatus.unverified:
        return strings.unverified;
      case PackPassportVerificationStatus.verified:
        return strings.yes;
      case PackPassportVerificationStatus.blocked:
        return strings.blocked;
    }
  }

  static String _sizeText(PackPassportEntry entry) {
    final installed = _formatBytes(entry.installedSizeBytes);
    final expected = _formatBytes(entry.expectedSizeBytes);
    if (entry.installedSizeBytes <= 0) return expected;
    if (entry.installedSizeBytes == entry.expectedSizeBytes) {
      return installed;
    }
    return '$installed / $expected';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kib = bytes / 1024;
    if (kib < 1024) return '${kib.toStringAsFixed(1)} KiB';
    final mib = kib / 1024;
    if (mib < 1024) return '${mib.toStringAsFixed(1)} MiB';
    final gib = mib / 1024;
    return '${gib.toStringAsFixed(1)} GiB';
  }
}

enum _VisualStatus {
  neutral,
  pending,
  good,
  error,
}

final class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
  });

  final IconData icon;
  final String label;
  final String value;
  final _VisualStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = switch (status) {
      _VisualStatus.good => scheme.primary,
      _VisualStatus.pending => scheme.tertiary,
      _VisualStatus.error => scheme.error,
      _VisualStatus.neutral => scheme.onSurfaceVariant,
    };

    return Semantics(
      label: '$label: $value',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: scheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: foreground,
              ),
              const SizedBox(width: 6),
              Text(
                '$label: $value',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _InfoSurface extends StatelessWidget {
  const _InfoSurface({
    required this.icon,
    required this.text,
    this.progress = false,
    this.error = false,
  });

  final IconData icon;
  final String text;
  final bool progress;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AdaptiveGlassSurface(
      child: Row(
        children: <Widget>[
          if (progress)
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              icon,
              color: error ? scheme.error : scheme.onSurfaceVariant,
            ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
