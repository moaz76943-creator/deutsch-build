import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String _selectedLang = 'ar';
  String _searchQuery = '';

  final Map<String, String> _languageFlags = const {
    'ar': '🇸🇦',
    'en': '🇬🇧',
    'de': '🇩🇪',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'tr': '🇹🇷',
    'it': '🇮🇹',
    'ru': '🇷🇺',
    'fa': '🇮🇷',
    'ur': '🇵🇰',
  };

  @override
  Widget build(BuildContext context) {
    final allLangs = LanguagePackManager().supportedLanguages;
    final filteredLangs = allLangs.where((code) {
      final name = LanguagePackManager.getLanguageName(code).toLowerCase();
      final query = _searchQuery.toLowerCase().trim();
      return name.contains(query) || code.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 12),
                Text(
                  'اختر لغة الواجهة الأساسية',
                  style: AppTypography.display
                      .copyWith(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر لغتك الأم للبدء في تعلم الألمانية وتفسير القواعد وشروحاتها (100 لغة مدعومة)',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن لغتك بين 100 لغة مدعومة...',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredLangs.length,
                    // Performance: bound pre-build area beyond the viewport.
                    cacheExtent: 300,
                    // Items are pure StatelessWidgets (AppBaseGlassCard) with no persistent
                    // state that must survive scrolling off-screen. Selection lives in parent.
                    addAutomaticKeepAlives: false,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final code = filteredLangs[index];
                      final name = LanguagePackManager.getLanguageName(code);
                      final flag = _languageFlags[code] ?? '🌐';
                      return _buildOption(
                        id: code,
                        title: name,
                        subtitle: code == 'ar'
                            ? 'شروحات مبسطة ومقارنات واضحة'
                            : 'Full explanations & dynamic grammar guide',
                        flag: flag,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: widget.onContinue,
                  child: const Text('متابعة',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required String id,
    required String title,
    required String subtitle,
    required String flag,
  }) {
    final isSelected = _selectedLang == id;
    return AppBaseGlassCard(
      onTap: () => setState(() => _selectedLang = id),
      gradient: isSelected ? AppGradients.blueCard : null,
      child: Row(
        children: <Widget>[
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.title
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
