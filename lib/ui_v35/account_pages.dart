import '../models/supported_language.dart';

import 'package:flutter/material.dart';

import '../services/ai_contract.dart';
import '../services/release.dart';
import '../services/repository.dart';
import '../services/subscription.dart';
import '../services/privacy_settings.dart';
import '../services/neuro_accessibility_settings.dart';
import 'pages/core_pages.dart';

class PremiumButton extends StatelessWidget {
  final LearnerRepository repo;
  final String label;
  final IconData icon;
  final VoidCallback onOpen;
  const PremiumButton({
    super.key,
    required this.repo,
    required this.label,
    required this.icon,
    required this.onOpen,
  });
  @override
  Widget build(BuildContext c) => FilledButton.icon(
        onPressed: () => Navigator.push(
          c,
          MaterialPageRoute(builder: (_) => SubscriptionPage(repo: repo)),
        ),
        icon: const Icon(Icons.lock_outline),
        label: Text(label),
      );
}

class SubscriptionPage extends StatefulWidget {
  final LearnerRepository? repo;
  const SubscriptionPage({super.key, required this.repo});
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool premium = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final x = await SubscriptionService.isPremium();
    if (mounted) setState(() => premium = x);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('الباقات والاشتراك')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deutsch بالعربي Premium',
                      style: Theme.of(c)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الأساسيات مجانية، بينما المزايا التي تختصر وقت التعلم وتزيد التخصيص تكون ضمن Premium.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _PlanCard(
              title: 'شهري',
              price: '\$5',
              period: 'شهريًا',
              badge: 'مرن',
              features: [
                'كل المحتوى التعليمي المتقدم',
                'المراجعة الذكية',
                'الاختبارات المتقدمة',
                'إحصائيات التعلم المتقدمة',
                'بدون إعلانات',
              ],
              plan: 'monthly',
            ),
            const _PlanCard(
              title: '3 أشهر',
              price: '\$10',
              period: 'كل 3 أشهر',
              badge: 'الأفضل قيمة',
              features: [
                'كل مزايا Premium',
                'مراجعة ذكية مستمرة',
                'مسار تعلم شخصي',
                'قائمة أفعال دراسية غير محدودة',
                'بدون إعلانات',
              ],
              plan: 'quarterly',
            ),
            const _PlanCard(
              title: 'سنة',
              price: '\$25',
              period: 'سنويًا',
              badge: 'الأوفر',
              features: [
                'كل مزايا Premium',
                'أفضل سعر للاستخدام الطويل',
                'مسار تعلم شخصي وإحصائيات متقدمة',
                'مراجعات واختبارات متقدمة',
                'بدون إعلانات',
              ],
              plan: 'yearly',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🆓 ماذا يبقى مجانيًا؟',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• أساسيات المفردات والقاموس\n• النطق الألماني\n• التصنيفات والأمثلة\n• جلسات التعلم الأساسية\n• اختبار تحديد المستوى الأساسي\n• جزء من الأفعال والتصريفات',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '⭐ ماذا يضيف Premium؟',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• فتح المحتوى المتقدم\n• مراجعة ذكية للكلمات الصعبة\n• خطة تعلم شخصية\n• اختبارات متقدمة\n• إحصائيات وتقدم أعمق\n• مزايا تعلم إضافية بدون إعلانات',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (premium)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.verified),
                  title: Text('Premium مفعّل'),
                  subtitle: Text(
                    'الدفع الحقيقي غير مفعّل بعد؛ لا يتم اعتبار التخزين المحلي إثباتًا للاشتراك.',
                  ),
                ),
              ),
          ],
        ),
      );
}

class _PlanCard extends StatelessWidget {
  final String title, price, period, badge, plan;
  final List<String> features;
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.badge,
    required this.features,
    required this.plan,
  });
  @override
  Widget build(BuildContext c) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(c)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Chip(label: Text(badge)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(c)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  Text(period),
                ],
              ),
              const SizedBox(height: 10),
              ...features.map(
                (x) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 19),
                      const SizedBox(width: 7),
                      Expanded(child: Text(x)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => showDialog(
                    context: c,
                    builder: (d) => AlertDialog(
                      title: const Text('جاهز للربط بالدفع'),
                      content: Text(
                        'الباقة $title بسعر $price $period.\n\nسيتم ربط هذا الخيار لاحقًا بمتجر Google Play/App Store؛ لا يوجد تحصيل مالي حقيقي في هذه النسخة.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(d),
                          child: const Text('حسنًا'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('اختيار الباقة'),
                ),
              ),
            ],
          ),
        ),
      );
}

class SettingsV35 extends StatelessWidget {
  final LearnerRepository repo;
  final PrivacySettingsStore privacySettings;
  final NeuroAccessibilitySettings? neuroSettings;
  final VoidCallback? onCleared;
  const SettingsV35({
    super.key,
    required this.repo,
    required this.privacySettings,
    this.neuroSettings,
    this.onCleared,
  });
  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('مسح التقدم؟'),
        content: const Text(
          'سيتم حذف XP والمراجعات والمحاولات والمفضلة من هذا الجهاز فقط. لا يمكن التراجع عن العملية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final cleared = await repo.clearLocalData();
      if (cleared) {
        onCleared?.call();
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف بيانات التعلم المحلية.')),
          );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حذف بيانات التعلم المحلية بالكامل.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('الإعدادات والخصوصية')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Target Language'),
                trailing: DropdownButton<AppTargetLanguage>(
                  value: AppTargetLanguage.german,
                  underline: const SizedBox(),
                  items: AppTargetLanguage.values.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (newLang) {},
                ),
              ),
            ),
            if (neuroSettings != null)
              Card(
                child: ListenableBuilder(
                  listenable: neuroSettings!,
                  builder: (context, _) => SwitchListTile(
                    title: const Text('وضعية التيسير المعرفي'),
                    subtitle: const Text(
                      'تحسين تباعد الأحرف وتبسيط الواجهة لتقليل الإجهاد البصري.',
                    ),
                    value: neuroSettings!.isEnabled,
                    onChanged: (val) => neuroSettings!.setEnabled(val),
                    secondary: const Icon(Icons.accessibility_new_outlined),
                  ),
                ),
              ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('الخصوصية'),
                subtitle: Text(
                  'التقدم والمحاولات محفوظة محليًا. لا توجد مزامنة سحابية ولا اتصال شبكي للتطبيق.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.offline_bolt_outlined),
                title: Text('Offline'),
                subtitle: Text('المحتوى والجلسات والتقدم وTTS تعمل محليًا.'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('تراخيص المصادر المفتوحة'),
                subtitle: const Text(
                  'اعرض تراخيص وملاحظات المكونات مفتوحة المصدر المستخدمة في التطبيق.',
                ),
                onTap: () => showLicensePage(
                  context: c,
                  applicationName: 'Deutsch بالعربي',
                  applicationVersion: '3.3.10',
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('AI Teacher'),
                subtitle: Text(AiTeacherContract.rules.join('\\n')),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _reset(c),
              icon: const Icon(Icons.delete_outline),
              label: const Text('مسح بيانات التعلم من الجهاز'),
            ),
            const SizedBox(height: 10),
            if (adminToolsEnabled)
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(builder: (_) => const QualityV35()),
                ),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('مركز الجودة'),
              ),
          ],
        ),
      );
}

/// كل كلمة تظهر معلوماتها الأساسية والأصلية عموديًا في نفس القائمة،
/// مع زر نطق ظاهر دون الحاجة إلى فتح بطاقة أو الضغط على الكلمة نفسها.
