import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

class UniversalPolyglotHubScreen extends StatefulWidget {
  const UniversalPolyglotHubScreen({super.key});

  @override
  State<UniversalPolyglotHubScreen> createState() =>
      _UniversalPolyglotHubScreenState();
}

class _UniversalPolyglotHubScreenState
    extends State<UniversalPolyglotHubScreen> {
  String _interfaceLanguage = 'ar-SA';
  String _sourceLanguage = 'ar-SA';
  String _targetLanguage = 'de-DE';

  bool _isPackReady = false;
  bool _isLoading = false;
  bool _hasError = false;
  int _currentRequestEpoch = 0;

  List<String> _allLanguages = [];

  @override
  void initState() {
    super.initState();
    _initLanguages();
    _checkCapability();
  }

  void _initLanguages() {
    final Set<String> langs = {};
    langs.addAll(LanguagePackManager.supportedBcp47Locales);
    langs.addAll(LanguagePackManager.supportedLanguages);
    _allLanguages = langs.toList()..sort();
  }

  Future<void> _checkCapability() async {
    final int requestEpoch = ++_currentRequestEpoch;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isPackReady = false;
    });

    try {
      final bool sourceReady = await LanguagePackManager.verifyAndMountOfflinePack(_sourceLanguage);
      final bool targetReady = await LanguagePackManager.verifyAndMountOfflinePack(_targetLanguage);

      if (!mounted || requestEpoch != _currentRequestEpoch) return;

      setState(() {
        _isPackReady = sourceReady && targetReady;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || requestEpoch != _currentRequestEpoch) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
        _isPackReady = false;
      });
    }
  }

  void _onInterfaceLanguageChanged(String? val) {
    if (val != null && val != _interfaceLanguage) {
      setState(() => _interfaceLanguage = val);
    }
  }

  void _onSourceLanguageChanged(String? val) {
    if (val != null && val != _sourceLanguage) {
      setState(() => _sourceLanguage = val);
      _checkCapability();
    }
  }

  void _onTargetLanguageChanged(String? val) {
    if (val != null && val != _targetLanguage) {
      setState(() => _targetLanguage = val);
      _checkCapability();
    }
  }

  void _openDictionary() {
     Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
        return Scaffold(appBar: AppBar(title: const Text('Dictionary View')));
     }));
  }

  void _startLessons() {
     Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
        return Scaffold(appBar: AppBar(title: const Text('Lessons View')));
     }));
  }

  Future<void> _showLanguagePicker(
      String title, String currentValue, ValueChanged<String?> onChanged) async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _allLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = _allLanguages[index];
                      final name = LanguagePackManager.getLanguageName(lang);
                      final hasVoice = LanguagePackManager.getTtsLocale(lang).isNotEmpty;
                      return ListTile(
                        title: Text(name),
                        trailing: hasVoice ? const Icon(Icons.volume_up, size: 16) : null,
                        selected: lang == currentValue,
                        onTap: () => Navigator.pop(context, lang),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null && selected != currentValue) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final interfaceDirection = LanguagePackManager.textDirectionFor(_interfaceLanguage);

    return Directionality(
      textDirection: interfaceDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحور اللغوي الشامل'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildLanguageSelector('لغة الواجهة:', _interfaceLanguage, _onInterfaceLanguageChanged),
            _buildLanguageSelector('اللغة المصدر:', _sourceLanguage, _onSourceLanguageChanged),
            _buildLanguageSelector('اللغة الهدف:', _targetLanguage, _onTargetLanguageChanged),

            const SizedBox(height: 24),
            if (_hasError)
              const Text('حدث خطأ أثناء التحقق من الحزمة.', style: TextStyle(color: Colors.red))
            else if (_isLoading)
              const Center(child: Text('Loading...'))
            else if (!_isPackReady)
              const Text('الحزمة غير متوفرة أو غير جاهزة للاستخدام.', style: TextStyle(color: Colors.orange))
            else
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('الحزمة جاهزة للاستخدام!', style: TextStyle(color: Colors.green)),
                ],
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isPackReady ? () => _openDictionary() : null,
              child: const Text('فتح القاموس'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isPackReady ? () => _startLessons() : null,
              child: const Text('بدء الدروس'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(String label, String currentValue, ValueChanged<String?> onChanged) {
    final name = _allLanguages.contains(currentValue)
      ? LanguagePackManager.getLanguageName(currentValue)
      : currentValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => _showLanguagePicker(label, currentValue, onChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
