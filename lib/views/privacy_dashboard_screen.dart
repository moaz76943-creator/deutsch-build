import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/app_design_system.dart';
import '../features/backup_restore_manager.dart';

class PrivacyDashboardScreen extends StatefulWidget {
  const PrivacyDashboardScreen({super.key});

  @override
  State<PrivacyDashboardScreen> createState() => _PrivacyDashboardScreenState();
}

class _PrivacyDashboardScreenState extends State<PrivacyDashboardScreen> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    final targetPath = '/sdcard/Download/deutsch_biarabi_backup.json';
    final success = await BackupRestoreManager.exportBackupToFile(targetPath);
    setState(() => _isExporting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم حفظ النسخة بنجاح في مجلد التنزيلات!' : 'تعذر حفظ الملف، تحقق من الصلاحيات.',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _confirmClearData() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح كافة بيانات التعلم؟'),
        content: const Text('سيتم حذف تقدمك وسجل الأخطاء والنقاط المخزنة محلياً على جهازك. لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح البيانات المحلية بالكامل.')),
              );
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الخصوصية والبيانات', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: AppColors.success, size: 28),
                      const SizedBox(width: 8),
                      Text('بياناتك ملكك بالكامل', style: AppStyles.title.copyWith(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• التطبيق يعمل محلياً 100% دون خوادم سحابية.'),
                  const Text('• لا يتم جمع أو مشاركة أي بيانات شخصية أو حساسة.'),
                  const Text('• تقدمك وسجلات الأخطاء مخزنة مشفرة على ذاكرة هاتفك فقط.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('إدارة النسخ الاحتياطي', style: AppStyles.title.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    text: _isExporting ? 'جارٍ التصدير...' : 'تصدير نسخة احتياطية (Download)',
                    icon: Icons.file_download_outlined,
                    onPressed: _isExporting ? () {} : _handleExport,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('مسح جميع بياناتي محلياً'),
                    onPressed: _confirmClearData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
