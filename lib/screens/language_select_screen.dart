
import '../design_system/design_system.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String _selectedLang = 'ar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16),
                Text(
                  'لغة الواجهة والشرح',
                  style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر اللغة التي تفضل قراءة الشروحات والقواعد بها',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                _buildOption(
                  id: 'ar',
                  title: 'العربية',
                  subtitle: 'شروحات مبسطة ومقارنات واضحة',
                  flag: '🇸🇦',
                ),
                const SizedBox(height: 16),
                _buildOption(
                  id: 'en',
                  title: 'English',
                  subtitle: 'Detailed explanations & English terms',
                  flag: '🇬🇧',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: widget.onContinue,
                  child: const Text('متابعة'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({required String id, required String title, required String subtitle, required String flag}) {
    final isSelected = _selectedLang == id;
    return AppBaseGlassCard(
      onTap: () => setState(() => _selectedLang = id),
      gradient: isSelected ? AppGradients.blueCard : null,
      child: Row(
        children: <Widget>[
          Text(flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTypography.title.copyWith(color: Colors.white, fontSize: 17)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
        ],
      ),
    );
  }
}
