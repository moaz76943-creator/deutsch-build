import 'package:flutter/material.dart';
import 'wave_07_models.dart';
import 'dart:async';

class Wave07HubScreen extends StatefulWidget {
  const Wave07HubScreen({super.key});

  @override
  State<Wave07HubScreen> createState() => _Wave07HubScreenState();
}

class _Wave07HubScreenState extends State<Wave07HubScreen> {
  // 1. بيانات محرك التردد (Hesitation)
  double _timeLeft = 1.0;
  Timer? _timer;
  bool _isPlaying = false;
  final List<HesitationFiller> _fillers = const [
    HesitationFiller(text: 'Ähm...', meaning: 'صوت تفكير', timeBonus: 2),
    HesitationFiller(text: 'Also,', meaning: 'حسناً/إذن', timeBonus: 3),
    HesitationFiller(text: 'Quasi', meaning: 'بمثابة/تقريباً', timeBonus: 3),
  ];

  // 2. بيانات ناسج الإحالة (Anaphora)
  String? _selectedPronoun;
  final _anaphoraTask = const AnaphoraTask(
    sentence1: 'Ich sehe das Auto.',
    antecedent: 'das Auto (محايد)',
    sentence2: '___ ist sehr schnell.',
    pronounOptions: ['Er', 'Sie', 'Es'],
    correctPronoun: 'Es',
  );

  // 3. نول المبني للمجهول (Kinetic Loom)
  bool _isPassive = false;

  // 4. مزلاق الإثراء الدلالي
  double _enrichmentSlider = 0;
  final List<EnrichmentLevel> _enrichmentLevels = const [
    EnrichmentLevel(level: 0, verb: 'gehen (يذهب)', nuance: 'فعل عام ومجرد.'),
    EnrichmentLevel(
        level: 1,
        verb: 'laufen (يمشي بسرعة/يركض)',
        nuance: 'فعل أكثر دقة وحيوية.'),
    EnrichmentLevel(
        level: 2,
        verb: 'schlendern (يتسكع ببطء)',
        nuance: 'مستوى C1: دقة وصفية عالية.'),
  ];

  // 5. ماسح الفراغ الدلالي
  bool _voidScanned = false;

  void _startHesitationTimer() {
    setState(() {
      _timeLeft = 1.0;
      _isPlaying = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft -= 0.02; // ينقص الوقت بسرعة
        } else {
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _buyTime(int bonus) {
    if (!_isPlaying) return;
    setState(() {
      _timeLeft = (_timeLeft + (bonus * 0.1)).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مختبر الخطاب والإحالة (Wave 07)'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. محرك استراتيجيات التردد
          _buildCard(
            title: '1. محرك التردد وشراء الوقت (INNOV-W07-01)',
            subtitle:
                'تجنب الصمت المطبق عند نسيان الكلمة باستخدام حشوات أهل اللغة',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _timeLeft,
                  color: _timeLeft > 0.3 ? Colors.green : Colors.red,
                  minHeight: 10,
                ),
                const SizedBox(height: 12),
                if (!_isPlaying && _timeLeft <= 0)
                  const Text(
                      'انتهى الوقت! لقد صمتَّ طويلاً وانقطع حبل الأفكار.',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                if (!_isPlaying && _timeLeft > 0)
                  ElevatedButton(
                    onPressed: _startHesitationTimer,
                    child: const Text('ابدأ المحادثة'),
                  ),
                if (_isPlaying) ...[
                  const Text(
                      'أنت تتحدث الآن... نسيت الكلمة! اضغط لإنقاذ الموقف:'),
                  Wrap(
                    spacing: 8,
                    children: _fillers
                        .map((f) => ActionChip(
                              label: Text(f.text),
                              onPressed: () => _buyTime(f.timeBonus),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // 2. ناسج التماسك النصي
          _buildCard(
            title: '2. ناسج الإحالة والضمائر (INNOV-W07-02)',
            subtitle: 'اربط الجملة الثانية بالأولى دون كسر التماسك النحوي',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_anaphoraTask.sentence1,
                    style: const TextStyle(fontSize: 16)),
                Text('المرجع: ${_anaphoraTask.antecedent}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedPronoun,
                      hint: const Text('اختر الضمير'),
                      items: _anaphoraTask.pronounOptions
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedPronoun = val),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        _anaphoraTask.sentence2
                            .replaceFirst('___', _selectedPronoun ?? '___'),
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                if (_selectedPronoun != null)
                  Text(
                    _selectedPronoun == _anaphoraTask.correctPronoun
                        ? '✅ خيط متصل! التماسك النصي سليم.'
                        : '❌ انقطع الخيط! الضمير لا يطابق جنس الاسم (Auto محايد دائمًا).',
                    style: TextStyle(
                        color: _selectedPronoun == _anaphoraTask.correctPronoun
                            ? Colors.green
                            : Colors.red),
                  )
              ],
            ),
          ),

          // 3. نول المبني للمجهول
          _buildCard(
            title: '3. نول الفاعل والمفعول (INNOV-W07-03)',
            subtitle: 'انقل ثقل الجملة بصرياً (المبني للمعلوم / المجهول)',
            content: Column(
              children: [
                SwitchListTile(
                  title: Text(_isPassive
                      ? 'المبني للمجهول (Passiv)'
                      : 'المبني للمعلوم (Aktiv)'),
                  value: _isPassive,
                  onChanged: (val) => setState(() => _isPassive = val),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isPassive
                        ? Colors.indigo.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _isPassive ? Colors.indigo : Colors.blue),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          _isPassive
                              ? 'Der Kuchen (المفعول أصبح محوراً)'
                              : 'Der Mann (الفاعل)',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_isPassive ? 'wird gegessen' : 'isst',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.red)),
                      Text(_isPassive ? '(von dem Mann)' : 'den Kuchen',
                          style: TextStyle(
                              color: _isPassive ? Colors.grey : Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. مزلاق الإثراء الدلالي
          _buildCard(
            title: '4. مزلاق الإثراء الدلالي (INNOV-W07-04)',
            subtitle: 'ارتقِ من مستوى B1 إلى C1 باستبدال الأفعال الباهتة',
            content: Column(
              children: [
                Slider(
                  value: _enrichmentSlider,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  label: 'المستوى ${_enrichmentSlider.toInt()}',
                  onChanged: (val) => setState(() => _enrichmentSlider = val),
                ),
                Text(
                  'Er ${_enrichmentLevels[_enrichmentSlider.toInt()].verb} durch den Park.',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                const SizedBox(height: 4),
                Text(_enrichmentLevels[_enrichmentSlider.toInt()].nuance,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // 5. ماسح الفراغ الدلالي
          _buildCard(
            title: '5. ماسح التكافؤ الصفري / الفراغ (INNOV-W07-05)',
            subtitle: 'اكتشف الكلمات التي يجب ألا تُترجم إطلاقاً (أفخاخ حرفية)',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Switch(
                        value: _voidScanned,
                        onChanged: (v) => setState(() => _voidScanned = v)),
                    const Text('تفعيل ماسح الفراغ (Void Scanner)'),
                  ],
                ),
                const Text('الجملة العربية: أنا أستمع (إلى) الموسيقى.',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: 'Ich höre '),
                      TextSpan(
                        text: _voidScanned ? ' 🕳️ (فراغ) ' : ' [zu] ',
                        style: TextStyle(
                          color: _voidScanned ? Colors.deepPurple : Colors.red,
                          decoration:
                              _voidScanned ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: ' die Musik.'),
                    ],
                  ),
                ),
                if (_voidScanned)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                        'تبخر حرف الجر! الفعل (hören) يأخذ المفعول به مباشرة في الألمانية دون وساطة.',
                        style: TextStyle(color: Colors.deepPurple)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      {required String title,
      required String subtitle,
      required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
