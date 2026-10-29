import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({super.key});

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  final List<String> _targetSentence = [];
  final List<String> _availableWords = ['trinke', 'Ich', 'gerne', 'Kaffee'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تركيب الجملة الألمانية'),
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
                  'رتب الكلمات لتكوين معنى: "أنا أحب شرب القهوة"',
                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(minHeight: 90),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _targetSentence.map((word) {
                      return InputChip(
                        label: Text(word, style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF2F6BFF),
                        onDeleted: () {
                          setState(() {
                            _targetSentence.remove(word);
                            _availableWords.add(word);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _availableWords.map((word) {
                    return ActionChip(
                      label: Text(word, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      onPressed: () {
                        setState(() {
                          _availableWords.remove(word);
                          _targetSentence.add(word);
                        });
                      },
                    );
                  }).toList(),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _targetSentence.isEmpty ? null : () {},
                  child: const Text('تأكيد الترتيب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
