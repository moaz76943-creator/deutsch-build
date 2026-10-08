import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Phase3ProductionShell extends StatefulWidget {
  final dynamic corpus;
  final dynamic audioRuntime;
  final dynamic learnerRepository;
  final dynamic gamificationRepository;
  final dynamic quickReviewService;
  final dynamic explainerService;
  final String? reviewSourceLanguageCode;
  final String? reviewTranslationLanguageCode;
  final int? startTaskOrder;

  const Phase3ProductionShell({
    super.key,
    this.corpus,
    this.audioRuntime,
    this.learnerRepository,
    this.gamificationRepository,
    this.quickReviewService,
    this.explainerService,
    this.reviewSourceLanguageCode,
    this.reviewTranslationLanguageCode,
    this.startTaskOrder,
  });

  @override
  State<Phase3ProductionShell> createState() => _Phase3ProductionShellState();
}

class _Phase3ProductionShellState extends State<Phase3ProductionShell> {
  final FlutterTts _tts = FlutterTts();
  int _currentTabIndex = 0;
  bool _isFlipped = false;
  int _cardIndex = 0;
  int _masteredCount = 0;
  int _reviewCount = 5;
  double _speechRate = 0.42; // سرعة النطق المعتمدة
  bool _isTtsAvailable = true;

  final List<Map<String, String>> _dailyDeck = const [
    {
      'article': 'der',
      'target': 'Tisch',
      'translation': 'الطاولة',
      'example': 'Der Tisch ist groß.',
      'note': 'اسم مذكر يأخذ der في حالة الرفع.'
    },
    {
      'article': 'die',
      'target': 'Apotheke',
      'translation': 'الصيدلية',
      'example': 'Ich gehe in die Apotheke.',
      'note': 'اسم مؤنث، لاحظ حرف الجر in مع Akkusativ.'
    },
    {
      'article': 'das',
      'target': 'Rezept',
      'translation': 'الوصفة الطبية',
      'example': 'Haben Sie ein Rezept?',
      'note': 'اسم محايد، شائع في القطاع الطبي.'
    },
  ];

  final List<Map<String, dynamic>> _lifeScenarios = const [
    {
      'title': 'في الصيدلية (Apotheke)',
      'desc': 'طلب دواء ووصف الأعراض',
      'phrases': [
        'Ich brauche etwas gegen Kopfschmerzen.',
        'Haben Sie Hustensaft für Kinder?',
        'Wie oft muss ich die Tabletten einnehmen?'
      ]
    },
    {
      'title': 'عند الطبيب (Beim Arzt)',
      'desc': 'حجز موعد وشرح الحالة',
      'phrases': [
        'Ich möchte einen Termin vereinbaren.',
        'Mein Bauch tut sehr weh.',
        'Ich brauche eine Krankschreibung.'
      ]
    },
    {
      'title': 'تسجيل السكن (Bürgeramt)',
      'desc': 'المعاملات الرسمية وتثبيت العنوان',
      'phrases': [
        'Ich möchte meine Wohnung anmelden.',
        'Hier ist die Wohnungsgeberbestätigung.',
        'Brauche ich weitere Unterlagen?'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final languages = await _tts.getLanguages;
      final bool hasGerman = (languages as List?)?.any((l) => l.toString().startsWith('de')) ?? false;
      
      setState(() => _isTtsAvailable = hasGerman);
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(_speechRate);
    } catch (_) {
      setState(() => _isTtsAvailable = false);
    }
  }

  void _speak(String text) async {
    await _tts.setSpeechRate(_speechRate);
    final res = await _tts.speak(text);
    if (res == 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تنبيه: محرك الصوت الألماني غير متوفر دون اتصال في جهازك.')),
      );
    }
  }

  void _toggleSpeed() {
    setState(() {
      if (_speechRate == 0.30) {
        _speechRate = 0.45;
      } else if (_speechRate == 0.45) {
        _speechRate = 0.65;
      } else {
        _speechRate = 0.30;
      }
    });
  }

  String get _speedLabel {
    if (_speechRate <= 0.35) return 'بطيء جداً (0.3x)';
    if (_speechRate <= 0.50) return 'طبيعي (0.45x)';
    return 'سريع (0.65x)';
  }

  void _handleReview(bool remembered) {
    setState(() {
      if (remembered) _masteredCount++;
      if (_reviewCount > 0) _reviewCount--;
      _isFlipped = false;
      _cardIndex = (_cardIndex + 1) % _dailyDeck.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('DEUTSCH بالعربي', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر التحكم السريع بسرعة الصوت
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0284C7)),
            icon: const Icon(Icons.speed_rounded, size: 18),
            label: Text(_speedLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: _toggleSpeed,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isTtsAvailable)
              Container(
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'حزمة الصوت الألماني غير مثبتة محلياً على هاتفك؛ تأكد من تنزيل لغة الصوت de-DE من إعدادات أندرويد.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildDailySessionTab(),
                  _buildLifeScenariosTab(),
                  _buildListeningTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded, color: Color(0xFF0284C7)),
            label: 'درس اليوم',
          ),
          NavigationDestination(
            icon: Icon(Icons.domain_outlined),
            selectedIcon: Icon(Icons.domain_rounded, color: Color(0xFF0284C7)),
            label: 'مواقف الحياة',
          ),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones_rounded, color: Color(0xFF0284C7)),
            label: 'استماع تلقائي',
          ),
        ],
      ),
    );
  }

  Widget _buildDailySessionTab() {
    final currentCard = _dailyDeck[_cardIndex];
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('المتبقي لليوم', '$_reviewCount', Colors.orange),
                Container(height: 30, width: 1, color: Colors.grey.shade200),
                _buildMetric('المتقن اليوم', '$_masteredCount', Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${currentCard['article']!} ', style: const TextStyle(fontSize: 26, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                          Text(currentCard['target']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0284C7)),
                            onPressed: () => _speak('${currentCard['article']} ${currentCard['target']}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isFlipped)
                        const Text('اضغط على البطاقة لكشف المعنى والشرح', style: TextStyle(color: Colors.grey, fontSize: 14))
                      else ...[
                        const Divider(height: 32),
                        Text(currentCard['translation']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        Text(currentCard['example']!, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF475569))),
                        const SizedBox(height: 8),
                        Text(currentCard['note']!, style: const TextStyle(fontSize: 13, color: Colors.orange)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isFlipped)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('لم أتذكرها'),
                    onPressed: () => _handleReview(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('تذكرتها بنجاح'),
                    onPressed: () => _handleReview(true),
                  ),
                ),
              ],
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => setState(() => _isFlipped = true),
              child: const Text('أظهر الإجابة والشرح'),
            ),
        ],
      ),
    );
  }

  Widget _buildLifeScenariosTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _lifeScenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, idx) {
        final item = _lifeScenarios[idx];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(item['desc'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
            children: [
              const Divider(),
              ...((item['phrases'] as List<String>).map((p) => ListTile(
                    dense: true,
                    leading: IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0284C7)),
                      onPressed: () => _speak(p),
                    ),
                    title: Text(p, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListeningTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.headphones_rounded, size: 70, color: Color(0xFF0284C7)),
          const SizedBox(height: 20),
          const Text('وضع الاستماع الهادئ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('استمع لعبارات المواقف اليومية بشكل متكرر دون الحاجة للمس الشاشة', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('تشغيل عبارات الصيدلية آلياً'),
            onPressed: () {
              for (var p in _lifeScenarios[0]['phrases']) {
                _speak(p);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}
