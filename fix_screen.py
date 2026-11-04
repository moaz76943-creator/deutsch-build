import re

with open('lib/screens/phonetics_lab_screen.dart', 'r') as f:
    content = f.read()

# Make it a StatefulWidget and fix some of the things. The file currently has both sets of changes from merge conflict.

# Re-apply the valid changes correctly.
content = content.replace('''
class PhoneticsLabScreen extends StatelessWidget {
  const PhoneticsLabScreen({super.key});

  @override
<<<<<<< HEAD
  State<PhoneticsLabScreen> createState() => _PhoneticsLabScreenState();
}

class _PhoneticsLabScreenState extends State<PhoneticsLabScreen> {
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  double _speechRate = 0.9;

  final List<Map<String, dynamic>> _sounds = [
    {
      "symbol": "ä / ö / ü",
      "ipa": "[ɛː] / [øː] / [yː]",
      "desc": "حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية",
      "lang": "الألمانية",
      "langCode": "de-DE",
      "hasAudio": true
    },
    {
      "symbol": "ñ",
      "ipa": "[ɲ]",
      "desc": "حرف النون المضخم في اللغة الإسبانية",
      "lang": "الإسبانية",
      "langCode": "es-ES",
      "hasAudio": true
    },
    {
      "symbol": "ğ",
      "ipa": "[ɰ]",
      "desc": "الحرف الصامت أو الناعم في اللغة التركية",
      "lang": "التركية",
      "langCode": "tr-TR",
      "hasAudio": false
    },
  ];''', '''
class PhoneticsLabScreen extends StatefulWidget {
  const PhoneticsLabScreen({super.key});

  @override
  State<PhoneticsLabScreen> createState() => _PhoneticsLabScreenState();
}

class _PhoneticsLabScreenState extends State<PhoneticsLabScreen> {
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  double _speechRate = 0.9;

  final List<Map<String, dynamic>> _sounds = [
    {
      "symbol": "ä / ö / ü",
      "ipa": "[ɛː] / [øː] / [yː]",
      "desc": "حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية",
      "lang": "الألمانية",
      "langCode": "de-DE",
      "hasAudio": true
    },
    {
      "symbol": "ñ",
      "ipa": "[ɲ]",
      "desc": "حرف النون المضخم في اللغة الإسبانية",
      "lang": "الإسبانية",
      "langCode": "es-ES",
      "hasAudio": true
    },
    {
      "symbol": "ğ",
      "ipa": "[ɰ]",
      "desc": "الحرف الصامت أو الناعم في اللغة التركية",
      "lang": "التركية",
      "langCode": "tr-TR",
      "hasAudio": false
    },
    {
      "symbol": "unverified",
      "ipa": "غير متوفر",
      "desc": "وصف غير متوفر",
      "lang": "لغة غير متوفرة",
      "langCode": "unverified",
      "hasAudio": false
    },
  ];''')

content = content.replace('''
  @override
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sounds = [
      {"symbol": "ä / ö / ü", "desc": "حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية", "lang": "الألمانية"},
      {"symbol": "ñ", "desc": "حرف النون المضخم في اللغة الإسبانية", "lang": "الإسبانية"},
      {"symbol": "ğ", "desc": "الحرف الصامت أو الناعم في اللغة التركية", "lang": "التركية"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('معمل تدريب الصوتيات ومخارج الحروف'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _speechRate == 0.9 ? Icons.speed : Icons.speed_outlined,
              semanticLabel: 'تغيير سرعة النطق',
            ),
            onPressed: _toggleSpeed,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
<<<<<<< HEAD
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final item = _sounds[index];
                final hasAudio = item['hasAudio'] as bool;
                final isCurrentPlaying =
                    _currentlyPlayingIndex == index && _isPlaying;

=======
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final item = sounds[index];
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
<<<<<<< HEAD
                            color:
                                const Color(0xFF34D399).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
=======
                            color: const Color(0xFF34D399).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['symbol']!,
                            style: const TextStyle(color: Color(0xFF34D399), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
<<<<<<< HEAD
                                item['symbol'] as String,
                                style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: TextDirection.ltr,
=======
                                item['lang']!,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                                child: Text(
                                  item['ipa'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF6EE7B7), fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc']!,
                                style: AppTypography.body.copyWith(color: Colors.white, fontSize: 14),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                              ),
                            ],
                          ),
                        ),
<<<<<<< HEAD
                        const SizedBox(width: 16),
                        Expanded(
                          child: Semantics(
                            label: item['desc'] as String,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item['lang'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF38BDF8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'] as String,
                                  style: AppTypography.body.copyWith(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (hasAudio)
                          AppAudioButton(
                            onPressed: () => _playAudio(index),
                            semanticLabel: 'استمع للفظ الصحيح',
                            isActive: isCurrentPlaying,
                            icon: isCurrentPlaying
                                ? FontAwesomeIcons.stop
                                : FontAwesomeIcons.volumeHigh,
                          )
                        else
                          const Tooltip(
                            message: 'النطق الصوتي غير متوفر حالياً',
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: FaIcon(
                                FontAwesomeIcons.microphoneSlash,
                                color: Colors.white38,
                                size: 20,
                              ),
                            ),
                          ),
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                      ],
                    ),
                  ),
                )
              }
return null;,''', '''
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معمل تدريب الصوتيات ومخارج الحروف'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _speechRate == 0.9 ? Icons.speed : Icons.speed_outlined,
              semanticLabel: 'تغيير سرعة النطق',
            ),
            tooltip: 'تغيير سرعة النطق',
            onPressed: _toggleSpeed,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final item = _sounds[index];
                final hasAudio = item['hasAudio'] as bool;
                final isCurrentPlaying =
                    _currentlyPlayingIndex == index && _isPlaying;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF34D399).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['symbol'] as String,
                                style: const TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  item['ipa'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF6EE7B7), fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Semantics(
                            label: item['desc'] as String,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item['lang'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF38BDF8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'] as String,
                                  style: AppTypography.body.copyWith(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (hasAudio)
                          AppAudioButton(
                            onPressed: () => _playAudio(index),
                            semanticLabel: 'استمع للفظ الصحيح',
                            isActive: isCurrentPlaying,
                            icon: isCurrentPlaying
                                ? FontAwesomeIcons.stop
                                : FontAwesomeIcons.volumeHigh,
                          )
                        else
                          const Tooltip(
                            message: 'النطق الصوتي غير متوفر حالياً',
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: FaIcon(
                                FontAwesomeIcons.microphoneSlash,
                                color: Colors.white38,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }''')

with open('lib/screens/phonetics_lab_screen.dart', 'w') as f:
    f.write(content)
