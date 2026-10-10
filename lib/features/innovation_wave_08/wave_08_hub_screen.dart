import 'package:flutter/material.dart';
import 'wave_08_models.dart';
import 'dart:async';

class Wave08HubScreen extends StatefulWidget {
  const Wave08HubScreen({super.key});

  @override
  State<Wave08HubScreen> createState() => _Wave08HubScreenState();
}

class _Wave08HubScreenState extends State<Wave08HubScreen> {
  // 1. طيف الازدواجية (Diglossia)
  double _registerSlider = 0;
  final List<RegisterLevel> _registerLevels = const [
    RegisterLevel(level: 0, phrase: 'Wie geht es dir?', context: 'أكاديمي / رسمي (Standard)'),
    RegisterLevel(level: 1, phrase: 'Wie geht\'s?', context: 'محايد / يومي (Umgangssprache)'),
    RegisterLevel(level: 2, phrase: 'Was geht ab?', context: 'شارع / شبابي (Slang)'),
  ];

  // 2. محاكي الإدراك المجسد (Gestures)
  bool _gestureMatched = false;

  // 3. مصفوفة اليقين (Evidentiality)
  String _knowledgeSource = 'witness';

  // 4. منقذ حالة الانحباس (TOT)
  int _totHintLevel = 0;
  final _totWord = const TOTWord(
    targetWord: 'Gedächtnis',
    visualStructure: 'G e _ _ _ _ _ _ i s',
    rhymeHint: 'على وزن: Verhältnis',
    semanticHint: 'عكس النسيان، المكان الذي تخزن فيه ذكرياتك.',
  );

  // 5. الفلتر العاطفي (Affective Filter)
  int _frustrationClicks = 0;
  Color _backgroundColor = Colors.white;

  void _simulateFrustration() {
    setState(() {
      _frustrationClicks++;
      if (_frustrationClicks >= 3) {
        // تفعيل الفلتر المهدئ
        _backgroundColor = Colors.lightBlue.shade50;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يبدو أن المهمة معقدة. خذ نفساً عميقاً، قمنا بتبسيط الألوان وإبطاء الإيقاع لأجلك.'),
            backgroundColor: Colors.teal,
          ),
        );
        _frustrationClicks = 0; // إعادة ضبط
      } else {
        _backgroundColor = Colors.red.shade50; // مؤشر توتر خفيف
      }
    });
    
    // العودة للون الطبيعي بعد فترة
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _backgroundColor = Colors.white);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      color: _backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('اللسانيات والإدراك المجسد (Wave 08)'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. طيف الازدواجية
            _buildCard(
              title: '1. طيف المقامات والازدواجية (INNOV-W08-01)',
              subtitle: 'اسحب المؤشر للنزول من لغة الكتب إلى لغة الشارع',
              content: Column(
                children: [
                  Slider(
                    value: _registerSlider,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: 'مستوى ${_registerSlider.toInt()}',
                    onChanged: (val) => setState(() => _registerSlider = val),
                  ),
                  Text(
                    _registerLevels[_registerSlider.toInt()].phrase,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _registerLevels[_registerSlider.toInt()].context,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            // 2. الإدراك المجسد
            _buildCard(
              title: '2. الإدراك المجسد والإيماءات (INNOV-W08-02)',
              subtitle: 'اسحب الحركة الجسدية المطابقة للكلمة',
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Draggable<String>(
                    data: 'perfect',
                    feedback: Text('👌', style: TextStyle(fontSize: 40)),
                    childWhenDragging: Text('👌', style: TextStyle(fontSize: 40, color: Colors.grey)),
                    child: Text('👌', style: TextStyle(fontSize: 40)),
                  ),
                  DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: _gestureMatched ? Colors.green : Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: _gestureMatched ? Colors.green.shade50 : null,
                        ),
                        child: Text(
                          _gestureMatched ? 'Perfekt! 👌' : 'اسحب الإيماءة هنا\n(Perfekt)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _gestureMatched ? Colors.green : Colors.black, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    onAcceptWithDetails: (details) {
                      if (details.data == 'perfect') setState(() => _gestureMatched = true);
                    },
                  ),
                ],
              ),
            ),

            // 3. مصفوفة اليقين
            _buildCard(
              title: '3. مصفوفة اليقين المعرفي (INNOV-W08-03)',
              subtitle: 'حدد مصدر معلومتك ليتغير النحو تلقائياً',
              content: Column(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'witness', label: Text('رأيته 👁️')),
                      ButtonSegment(value: 'rumor', label: Text('إشاعة 👂')),
                      ButtonSegment(value: 'deduction', label: Text('استنتاج 🧠')),
                    ],
                    selected: {_knowledgeSource},
                    onSelectionChanged: (set) => setState(() => _knowledgeSource = set.first),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.shade50,
                    width: double.infinity,
                    child: Text(
                      _knowledgeSource == 'witness'
                          ? 'Der Zug hat Verspätung. (حقيقة مؤكدة)'
                          : _knowledgeSource == 'rumor'
                              ? 'Der Zug soll Verspätung haben. (نقل عن آخرين)'
                              : 'Der Zug muss Verspätung haben. (استنتاج منطقي)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // 4. منقذ حالة الانحباس اللفظي (TOT)
            _buildCard(
              title: '4. منقذ الانحباس (Tip-of-the-Tongue) (INNOV-W08-04)',
              subtitle: 'الكلمة عالقة في ذهنك؟ اطلب تلميحاً لتبني مساراً عصبياً.',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ما هي الكلمة الألمانية التي تعني (الذاكرة)؟'),
                  const SizedBox(height: 8),
                  if (_totHintLevel > 0)
                    Text('1. البناء البصري: ${_totWord.visualStructure}', style: const TextStyle(fontSize: 16, color: Colors.indigo)),
                  if (_totHintLevel > 1)
                    Text('2. تلميح صوتي: ${_totWord.rhymeHint}', style: const TextStyle(fontSize: 16, color: Colors.indigo)),
                  if (_totHintLevel > 2)
                    Text('3. تلميح دلالي: ${_totWord.semanticHint}', style: const TextStyle(fontSize: 16, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sos),
                        label: const Text('طلب تلميح متدرج'),
                        onPressed: () {
                          if (_totHintLevel < 3) setState(() => _totHintLevel++);
                        },
                      ),
                      const SizedBox(width: 8),
                      if (_totHintLevel == 3)
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الكلمة هي: ${_totWord.targetWord}'))),
                          child: const Text('كشف الكلمة النهائية', style: TextStyle(color: Colors.red)),
                        )
                    ],
                  ),
                ],
              ),
            ),

            // 5. منظم الفلتر العاطفي
            _buildCard(
              title: '5. منظم الفلتر العاطفي (INNOV-W08-05)',
              subtitle: 'اضغط بسرعة وعشوائية لمحاكاة التوتر والإحباط',
              content: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
                  onPressed: _simulateFrustration,
                  child: const Text('إجابة خاطئة سريعة (محاكاة الإحباط)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
