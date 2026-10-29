import '../design_system/design_system.dart';

class QuizExerciseScreen extends StatefulWidget {
  const QuizExerciseScreen({super.key});

  @override
  State<QuizExerciseScreen> createState() => _QuizExerciseScreenState();
}

class _QuizExerciseScreenState extends State<QuizExerciseScreen> {
  int? _selectedOption;
  final int _correctOption = 1;

  final List<String> _options = const [
    'der Haus',
    'das Haus',
    'die Haus',
    'den Haus',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تمرين القواعد'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'اختر أداة التعريف الصحيحة للكلمة التالية:',
                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                AppBaseGlassCard(
                  gradient: AppGradients.purpleCard,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      'المنزل (... Haus)',
                      style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(_options.length, (index) {
                  final isSelected = _selectedOption == index;
                  final isCorrect = isSelected && index == _correctOption;
                  final isWrong = isSelected && index != _correctOption;

                  Gradient? customGrad;
                  if (isCorrect) {
                    customGrad = const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF047857)]);
                  } else if (isWrong) {
                    customGrad = const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFFB91C1C)]);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppBaseGlassCard(
                      onTap: () => setState(() => _selectedOption = index),
                      gradient: customGrad,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _options[index],
                            style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedOption == null ? null : () {},
                  child: const Text('تحقق من الإجابة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
