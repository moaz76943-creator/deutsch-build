import 'package:flutter/material.dart';
import 'wave_06_models.dart';

class Wave06HubScreen extends StatefulWidget {
  const Wave06HubScreen({super.key});

  @override
  State<Wave06HubScreen> createState() => _Wave06HubScreenState();
}

class _Wave06HubScreenState extends State<Wave06HubScreen> {
  // 1. بيانات مسرح التركيز
  String _focusTarget = 'subject';
  final _spotlight = const SpotlightSentence(
    baseSubject: 'Ich (أنا)',
    baseVerb: 'sehe (أرى)',
    baseObject: 'den Hund (الكلب)',
  );

  // 2. بيانات العبء النحوي
  int _branchingLevel = 0;

  // 3. بيانات الجاذبية اللفظية (التلازم)
  String _selectedCollocation = '';

  // 4. بيانات أشعة إكس (الحذف والاختزال)
  bool _xRayEnabled = false;

  // 5. بيانات التلطيف البراغماتي
  double _mitigationSlider = 0;
  final List<MitigationLevel> _mitigationLevels = const [
    MitigationLevel(level: 0, text: 'Ich will nicht. (لا أريد)', explanation: 'مباشر جداً، قد يُعتبر فظاً.'),
    MitigationLevel(level: 1, text: 'Ich möchte lieber nicht. (أفضل ألا أفعل)', explanation: 'مهذب، يستخدم صيغة التمني.'),
    MitigationLevel(level: 2, text: 'Ich würde wirklich gerne, aber leider... (كنت أود ذلك بشدة لكن للأسف...)', explanation: 'قمة الدبلوماسية، حفظ ماء الوجه للطرفين.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مختبر الطلاقة الخفية (Wave 06)'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. مسرح البنية المعلوماتية
          _buildCard(
            title: '1. مسرح بؤرة التركيز (INNOV-W06-01)',
            subtitle: 'وجّه إضاءة المسرح لتغيير بنية الجملة الألمانية',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'subject', label: Text('الفاعل')),
                    ButtonSegment(value: 'object', label: Text('المفعول (Focus)')),
                  ],
                  selected: {_focusTarget},
                  onSelectionChanged: (set) => setState(() => _focusTarget = set.first),
                ),
                const SizedBox(height: 12),
                Text(
                  _spotlight.getFocusedSentence(_focusTarget),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
          ),

          // 2. العبء المعرفي النحوي
          _buildCard(
            title: '2. محاكي التفرع النحوي (INNOV-W06-02)',
            subtitle: 'أضف جملاً فرعية لترى متى ينهار الدماغ (الذاكرة العاملة)',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _branchingLevel++),
                  child: const Text('إضافة جملة موصولة متداخلة +'),
                ),
                const SizedBox(height: 8),
                Text('Das ist das Haus${_buildNestedClauses(_branchingLevel)}, das Jack gebaut hat.'),
                const SizedBox(height: 8),
                if (_branchingLevel > 2)
                  const Text('⚠️ تحذير: انهيار الذاكرة العاملة! الجملة معقدة جداً للمستمع، قسّمها فوراً.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                if (_branchingLevel > 0)
                  TextButton(
                    onPressed: () => setState(() => _branchingLevel = 0),
                    child: const Text('إعادة ضبط'),
                  ),
              ],
            ),
          ),

          // 3. الجاذبية اللفظية
          _buildCard(
            title: '3. حقل جاذبية التلازم اللفظي (INNOV-W06-03)',
            subtitle: 'اختر الفعل الذي ينجذب طبيعياً لـ "قرار" (Entscheidung)',
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionChip(
                      label: const Text('machen (يصنع)'),
                      backgroundColor: _selectedCollocation == 'machen' ? Colors.red.shade100 : null,
                      onPressed: () => setState(() => _selectedCollocation = 'machen'),
                    ),
                    const Text('➡️ Entscheidung ⬅️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ActionChip(
                      label: const Text('treffen (يتخذ)'),
                      backgroundColor: _selectedCollocation == 'treffen' ? Colors.green.shade100 : null,
                      onPressed: () => setState(() => _selectedCollocation = 'treffen'),
                    ),
                  ],
                ),
                if (_selectedCollocation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _selectedCollocation == 'treffen' 
                          ? '✅ تلازم صحيح! الألمان يقولون "يتخذ قراراً" وليس "يصنع".' 
                          : '❌ تنافر مغناطيسي! الترجمة الحرفية من الإنجليزية (Make a decision) خاطئة هنا.',
                      style: TextStyle(color: _selectedCollocation == 'treffen' ? Colors.green : Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // 4. كشاف الاختزال
          _buildCard(
            title: '4. كشاف أشعة إكس للحذف (INNOV-W06-04)',
            subtitle: 'اكتشف الضمائر التي يمكن حذفها (Pro-drop / Topic-drop)',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Switch(value: _xRayEnabled, onChanged: (v) => setState(() => _xRayEnabled = v)),
                    const Text('تفعيل أشعة X للكشف عن الحشو'),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      const TextSpan(text: 'أمس، '),
                      TextSpan(
                        text: '[أنا] ',
                        style: TextStyle(
                          color: _xRayEnabled ? Colors.grey.withValues(alpha: 0.3) : Colors.black,
                          decoration: _xRayEnabled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const TextSpan(text: 'ذهبت إلى السوق، و '),
                      TextSpan(
                        text: '[أنا] ',
                        style: TextStyle(
                          color: _xRayEnabled ? Colors.grey.withValues(alpha: 0.3) : Colors.black,
                          decoration: _xRayEnabled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const TextSpan(text: 'اشتريت تفاحاً.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. التلطيف البراغماتي
          _buildCard(
            title: '5. خوارزمية تلطيف الصدمات (INNOV-W06-05)',
            subtitle: 'شريط الدبلوماسية (حفظ ماء الوجه للمستمع)',
            content: Column(
              children: [
                Slider(
                  value: _mitigationSlider,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  label: 'المستوى ${_mitigationSlider.toInt()}',
                  onChanged: (val) => setState(() => _mitigationSlider = val),
                ),
                Text(
                  _mitigationLevels[_mitigationSlider.toInt()].text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _mitigationLevels[_mitigationSlider.toInt()].explanation,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildNestedClauses(int level) {
    if (level == 0) return '';
    if (level == 1) return ', das dem Mann gehört';
    if (level == 2) return ', das dem Mann, der den Hund sah, gehört';
    return ', das dem Mann, der den Hund, der die Katze jagte, sah, gehört';
  }

  Widget _buildCard({required String title, required String subtitle, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }
}
