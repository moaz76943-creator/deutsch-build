import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DialogueMessage {
  final String speaker;
  final String german;
  final String arabic;
  final bool isLeft;

  const DialogueMessage({
    required this.speaker,
    required this.german,
    required this.arabic,
    required this.isLeft,
  });
}

class InteractiveDialoguesScreen extends StatefulWidget {
  const InteractiveDialoguesScreen({super.key});

  @override
  State<InteractiveDialoguesScreen> createState() => _InteractiveDialoguesScreenState();
}

class _InteractiveDialoguesScreenState extends State<InteractiveDialoguesScreen> {
  final FlutterTts _tts = FlutterTts();
  int _activeMessageIndex = -1;

  final List<DialogueMessage> _conversation = const [
    DialogueMessage(
      speaker: 'الصيدلي (Apotheker)',
      german: 'Guten Tag! Wie kann ich Ihnen helfen?',
      arabic: 'طاب يومك! كيف يمكنني مساعدتك؟',
      isLeft: true,
    ),
    DialogueMessage(
      speaker: 'المريض (Patient)',
      german: 'Hallo, ich habe starke Kopfschmerzen und brauche etwas dagegen.',
      arabic: 'مرحباً، لدي صداع قوي وأحتاج دواءً له.',
      isLeft: false,
    ),
    DialogueMessage(
      speaker: 'الصيدلي (Apotheker)',
      german: 'Haben Sie auch Fieber oder Magenschmerzen?',
      arabic: 'هل لديك أيضاً حمى أو ألم في المعدة؟',
      isLeft: true,
    ),
    DialogueMessage(
      speaker: 'المريض (Patient)',
      german: 'Nein, nur Kopfschmerzen seit heute Morgen.',
      arabic: 'لا، فقط صداع منذ هذا الصباح.',
      isLeft: false,
    ),
    DialogueMessage(
      speaker: 'الصيدلي (Apotheker)',
      german: 'Ich gebe Ihnen Paracetamol. Nehmen Sie eine Tablette mit Wasser.',
      arabic: 'سأعطيك باراسيتامول. خذ حبة واحدة مع الماء.',
      isLeft: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
  }

  Future<void> _speakLine(int index, String text, bool isMalePitch) async {
    setState(() => _activeMessageIndex = index);
    await _tts.setPitch(isMalePitch ? 0.9 : 1.2); // تنويع نبرة الصوت بين المتحدثين
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محادثة تفاعلية: في الصيدلية'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _conversation.length,
        itemBuilder: (ctx, i) {
          final msg = _conversation[i];
          final isActive = _activeMessageIndex == i;

          return Align(
            alignment: msg.isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              decoration: BoxDecoration(
                color: msg.isLeft
                    ? (isActive ? Colors.blue.shade100 : Colors.blue.shade50)
                    : (isActive ? Colors.teal.shade100 : Colors.teal.shade50),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isLeft ? 4 : 18),
                  bottomRight: Radius.circular(msg.isLeft ? 18 : 4),
                ),
                border: Border.all(
                  color: (msg.isLeft ? Colors.blueAccent : Colors.teal).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        msg.isLeft ? Icons.local_pharmacy_rounded : Icons.person_rounded,
                        size: 16,
                        color: msg.isLeft ? Colors.blue.shade700 : Colors.teal.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        msg.speaker,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: msg.isLeft ? Colors.blue.shade800 : Colors.teal.shade800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        color: msg.isLeft ? Colors.blue.shade800 : Colors.teal.shade800,
                        onPressed: () => _speakLine(i, msg.german, msg.isLeft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg.german,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg.arabic,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
