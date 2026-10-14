import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/main_shell_screen.dart';
import '../../services/language_pack_manager.dart';
import '../../core/catalog/language_readiness_matrix.dart';

class FastOnboardingScreen extends StatefulWidget {
  const FastOnboardingScreen({super.key});

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  bool _isLoading = true;
  String _interfaceLanguage = 'ar-SA';
  String _sourceLanguage = 'ar-SA';
  String _targetLanguage = 'de-DE';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool('has_completed_onboarding') ?? false;

    if (hasCompleted) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
        );
      }
      return;
    }

    setState(() {
      _interfaceLanguage = prefs.getString('pref_interface_lang') ?? 'ar-SA';
      _sourceLanguage = prefs.getString('pref_source_lang') ?? 'ar-SA';
      _targetLanguage = prefs.getString('pref_target_lang') ?? 'de-DE';
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_interface_lang', _interfaceLanguage);
    await prefs.setString('pref_source_lang', _sourceLanguage);
    await prefs.setString('pref_target_lang', _targetLanguage);
  }

  Future<void> _handleStart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_sourceLanguage == _targetLanguage) {
      setState(() {
        _errorMessage = 'Source and target languages cannot be the same.';
        _isLoading = false;
      });
      return;
    }

    final targetBaseCode = _targetLanguage.split('-').first;

    if (!LanguageReadinessMatrix.isProductionReady(targetBaseCode)) {
      setState(() {
        _errorMessage = 'Target language is not yet ready for production.';
        _isLoading = false;
      });
      return;
    }

    final isOfflinePackAvailable = await LanguagePackManager.verifyAndMountOfflinePack(_targetLanguage);
    if (!isOfflinePackAvailable) {
      setState(() {
        _errorMessage = 'Offline pack for target language is not available.';
        _isLoading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _errorMessage == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    final isRtl = _interfaceLanguage.startsWith('ar');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.language, size: 64, color: Colors.blueAccent),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Deutsch Bilarabi',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                const Text('Interface Language', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                _buildLanguageDropdown(
                  value: _interfaceLanguage,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _interfaceLanguage = val;
                        _savePreferences();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                const Text('Source Language (Your native language)', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                _buildLanguageDropdown(
                  value: _sourceLanguage,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _sourceLanguage = val;
                        _savePreferences();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                const Text('Target Language (What you want to learn)', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                _buildLanguageDropdown(
                  value: _targetLanguage,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _targetLanguage = val;
                        _savePreferences();
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleStart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Start Learning', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown({required String value, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1E293B),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: LanguagePackManager.supportedBcp47Locales.map((locale) {
            return DropdownMenuItem(
              value: locale,
              child: Text(
                LanguagePackManager.getLanguageName(locale),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
