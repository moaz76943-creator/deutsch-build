import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class TransformedVariation {
  final String formTitle;
  final String targetSentence;
  final String note;

  const TransformedVariation({
    required this.formTitle,
    required this.targetSentence,
    required this.note,
  });
}

class SentenceTransformerScreen extends StatelessWidget {
  const SentenceTransformerScreen({super.key});

  final List<TransformedVariation> _variations = const [
    TransformedVariation(
      formTitle: 'الحاضر البسيط (Präsens)',
      targetSentence: 'Ich kaufe das Auto.',
      note: 'الجملة الأساسية: الفاعل ثم الفعل في الموضع الثاني.',
    ),
    TransformedVariation(
      formTitle: 'الماضي التام (Perfekt)',
      targetSentence: 'Ich habe das Auto gekauft.',
      note: 'استخدام الفعل المساعد haben + اسم المفعول في نهاية الجملة.',
    ),
    TransformedVariation(
      formTitle: 'النفي (Verneinung)',
      targetSentence: 'Ich kaufe das Auto nicht.',
      note: 'نفي الجملة باستخدام nicht في النهاية.',
    ),
    TransformedVariation(
      formTitle: 'سؤال نعم/لا (Ja/Nein-Frage)',
      targetSentence: 'Kaufst du das Auto?',
      note: 'تقدم الفعل إلى الموضع الأول في السؤال المباشر.',
    ),
    TransformedVariation(
      formTitle: 'جملة فرعية سببية (Nebensatz mit weil)',
      targetSentence: 'Ich arbeite viel, weil ich das Auto kaufe.',
      note: 'بعد أداة الربط weil ينتقل الفعل المصرف تماماً إلى نهاية الجملة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('محوّل الجمل والقواعد', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _variations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final v = _variations[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.formTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  const SizedBox(height: 8),
                  AppDirectionalText.target(
                    v.targetSentence,
                    style: AppStyles.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(v.note, style: AppStyles.subtitle.copyWith(fontSize: 14)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
