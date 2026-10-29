import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/main_shell_screen.dart';
import '../../core/i18n/language_registry.dart';
import '../../core/catalog/language_readiness_matrix.dart';
import '../../services/language_pack_manager.dart';

/// مسار الصفر-إلى-واحد: أسرع تجربة وصول لأول بطاقة بدون إنترنت
class FastOnboardingScreen extends StatefulWidget {
  const FastOnboardingScreen({super.key, this.languagePackVerifier});
  
  final Future<bool> Function(String)? languagePackVerifier;

  @override
  State<FastOnboardingScreen> createState() => _FastOnboardingScreenState();
}

class _FastOnboardingScreenState extends State<FastOnboardingScreen> {
  bool _isLoading = true;
  String? _interfaceLanguage;
  String? _sourceLanguage;
  String? _targetLanguage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingLearner();
  }

  Future<void> _checkExistingLearner() async {
    final prefs = await SharedPreferences.getInstance();
    final isComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    if (isComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        // Default to Arabic interface if nothing is set
        _interfaceLanguage = 'ar';
      });
    }
  }

  void _onContinue() async {
    if (_interfaceLanguage == null || _sourceLanguage == null || _targetLanguage == null) {
      setState(() => _errorMessage = 'يرجى اختيار لغة الواجهة، اللغة المصدر، واللغة الهدف');
      return;
    }

    if (_sourceLanguage == _targetLanguage) {
      setState(() => _errorMessage = 'لا يمكن أن تكون اللغة المصدر والهدف متطابقتين');
      return;
    }

    final targetTier = LanguageReadinessMatrix.getTier(_targetLanguage!);
    if (targetTier != LanguageReadinessTier.productionReady) {
      setState(() => _errorMessage = 'هذه اللغة غير مدعومة حالياً للاستخدام كهدف');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Map<String, String> bcp47Map = {
        'de': 'de-DE',
        'ar': 'ar-SA',
        'en': 'en-US',
        'fr': 'fr-FR',
        'es': 'es-ES',
        'tr': 'tr-TR',
        'ru': 'ru-RU',
        'zh': 'zh-CN',
        'it': 'it-IT',
      };

      final String bcp47Target = bcp47Map[_targetLanguage!] ?? '${_targetLanguage!}-${_targetLanguage!.toUpperCase()}';

      final verifier = widget.languagePackVerifier ?? LanguagePackManager.verifyAndMountOfflinePack;
      final bool isReady = await verifier(bcp47Target);

      if (!mounted) return;

      if (!isReady) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'حزمة اللغة غير متوفرة أو تالفة. يرجى التحقق من توفر الحزمة.';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('interface_lang', _interfaceLanguage!);
      await prefs.setString('source_lang', _sourceLanguage!);
      await prefs.setString('target_lang', _targetLanguage!);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ غير متوقع: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    final allLanguages = LanguageRegistry.supportedLanguages.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إعدادات اللغة',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'لغة واجهة التطبيق:',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _interfaceLanguage,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                hint: const Text('اختر لغة الواجهة', style: TextStyle(color: Colors.white54)),
                items: allLanguages.map((code) {
                  final profile = LanguageRegistry.getProfile(code);
                  return DropdownMenuItem(
                    value: code,
                    child: Text('${profile.nameAr} (${profile.nameEn})', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  _interfaceLanguage = val;
                  _errorMessage = null;
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                'اللغة التي تعرفها (المصدر):',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _sourceLanguage,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                hint: const Text('اختر اللغة المصدر', style: TextStyle(color: Colors.white54)),
                items: allLanguages.map((code) {
                  final profile = LanguageRegistry.getProfile(code);
                  return DropdownMenuItem(
                    value: code,
                    enabled: code != _targetLanguage,
                    child: Text(
                      '${profile.nameAr} (${profile.nameEn})',
                      style: TextStyle(
                        color: code == _targetLanguage ? Colors.white24 : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  _sourceLanguage = val;
                  _errorMessage = null;
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                'اللغة التي تريد تعلمها (الهدف):',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _targetLanguage,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                hint: const Text('اختر اللغة الهدف', style: TextStyle(color: Colors.white54)),
                items: allLanguages.map((code) {
                  final profile = LanguageRegistry.getProfile(code);
                  return DropdownMenuItem(
                    value: code,
                    enabled: code != _sourceLanguage,
                    child: Text(
                      '${profile.nameAr} (${profile.nameEn})',
                      style: TextStyle(
                        color: code == _sourceLanguage ? Colors.white24 : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  _targetLanguage = val;
                  _errorMessage = null;
                }),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                key: const Key('continue_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _onContinue,
                child: const Text('متابعة', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
