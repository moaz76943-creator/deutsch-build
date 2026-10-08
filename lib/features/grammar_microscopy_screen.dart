import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';

class GrammarToken {
  final String text;
  final String role;
  final String explanation;
  final Color color;

  const GrammarToken({
    required this.text,
    required this.role,
    required this.explanation,
    required this.color,
  });
}

class GrammarMicroscopyScreen extends StatefulWidget {
  const GrammarMicroscopyScreen({super.key});

  @override
  State<GrammarMicroscopyScreen> createState() => _GrammarMicroscopyScreenState();
}

class _GrammarMicroscopyScreenState extends State<GrammarMicroscopyScreen> {
  GrammarToken? _selectedToken;

  final List<GrammarToken> _tokens = const [
    GrammarToken(
      text: 'Ich',
      role: 'Subject (Nominativ)',
      explanation: 'ضمير الفاعل في حالة الرفع (Nominativ).',
      color: Colors.blue,
    ),
    GrammarToken(
      text: 'habe',
      role: 'Hilfsverb (فعل مساعد)',
      explanation: 'تصريف فعل haben في الحاضر مع الضمير ich لبناء الماضي التام (Perfekt).',
      color: Colors.purple,
    ),
    GrammarToken(
      text: 'dem Mann',
      role: 'Dativ-Objekt (المجرور)',
      explanation: 'اسم مذكر في حالة Dativ؛ تحولت الأداة der إلى dem لأن الفعل geben يتطلب Dativ للشخص المستفيد.',
      color: Colors.teal,
    ),
    GrammarToken(
      text: 'das Buch',
      role: 'Akkusativ-Objekt (المفعول به)',
      explanation: 'اسم محايد في حالة النصب (Akkusativ) كشيء مباشر يقع عليه الفعل.',
      color: Colors.amber,
    ),
    GrammarToken(
      text: 'gegeben.',
      role: 'Partizip II (اسم المفعول)',
      explanation: 'التصريف الثالث من الفعل geben، ويوضع دائماً في نهاية الجملة الرئيسية.',
      color: Colors.deepOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مجهر القواعد التفاعلي', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اضغط على أي كلمة في الجملة لفحص دورها الإعرابي:',
                style: AppStyles.subtitle,
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: _tokens.map((token) {
                    final isSelected = _selectedToken?.text == token.text;
                    return ActionChip(
                      backgroundColor: isSelected ? token.color : token.color.withValues(alpha: 0.15),
                      label: Text(
                        token.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      onPressed: () => setState(() => _selectedToken = token),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedToken != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 6,
                            backgroundColor: _selectedToken!.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedToken!.role,
                            style: AppStyles.title.copyWith(fontSize: 18, color: _selectedToken!.color),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        _selectedToken!.explanation,
                        style: AppStyles.body.copyWith(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text('اختر عنصراً من الجملة لرؤية التفاصيل اللغوية.', style: AppStyles.subtitle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
