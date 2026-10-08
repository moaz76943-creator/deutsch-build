import '../design_system/design_system.dart';

class AudioPracticeScreen extends StatefulWidget {
  const AudioPracticeScreen({super.key});

  @override
  State<AudioPracticeScreen> createState() => _AudioPracticeScreenState();
}

class _AudioPracticeScreenState extends State<AudioPracticeScreen> {
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستماع والنطق المتقن'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              children: <Widget>[
                const Spacer(),
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.graphic_eq_rounded, size: 72, color: Color(0xFF38BDF8)),
                      const SizedBox(height: 18),
                      Text(
                        'Guten标志 Wie geht es Ihnen?',
                        style: AppTypography.title.copyWith(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'صباح الخير! كيف حال حضرتك؟',
                        style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            iconSize: 44,
                            icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
                            color: const Color(0xFFF39C6B),
                            onPressed: () => setState(() => _isPlaying = !_isPlaying),
                          ),
                          const SizedBox(width: 16),
                          ActionChip(
                            label: Text('${_playbackSpeed}x'),
                            onPressed: () {
                              setState(() {
                                _playbackSpeed = _playbackSpeed == 1.0 ? 0.75 : 1.0;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_rounded),
                  label: const Text('اضغط وتحدث للتدريب على النطق'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
