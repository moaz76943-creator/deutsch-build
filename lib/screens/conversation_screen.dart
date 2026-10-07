import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String languageName;

  const ConversationScreen({Key? key, required this.languageName}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final List<Map<String, dynamic>> _dialogues = [
    {
      'role': 'bot',
      'speaker': 'المعلم الذكي',
      'text_target': 'Guten Tag! Wie kann ich Ihnen heute helfen?',
      'text_ar': 'يوم سعيد! كيف يمكنني مساعدتك اليوم؟',
    },
    {
      'role': 'user',
      'speaker': 'أنت (المتعلم)',
      'text_target': 'Ich möchte bitte ein Kilo Äpfel kaufen.',
      'text_ar': 'أود شراء كيلو من التفاح من فضلك.',
    },
    {
      'role': 'bot',
      'speaker': 'المعلم الذكي',
      'text_target': 'Sehr gerne! Möchten Sie die roten oder die grünen Äpfel?',
      'text_ar': 'بكل سرور! هل تفضل التفاح الأحمر أم الأخضر؟',
    },
    {
      'role': 'user',
      'speaker': 'أنت (المتعلم)',
      'text_target': 'Die roten bitte. Wie viel kostet das?',
      'text_ar': 'الأحمر لو سمحت. كم ثمن ذلك؟',
    },
    {
      'role': 'bot',
      'speaker': 'المعلم الذكي',
      'text_target': 'Das macht zusammen zwei Euro fünfzig.',
      'text_ar': 'المجموع يورو ونصف.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('محادثة تفاعلية (${widget.languageName})', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('موقف: في السوبرماركت والتسوق', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dialogues.length,
              itemBuilder: (context, index) {
                final d = _dialogues[index];
                final isUser = d['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF2563EB) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                      border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              d['speaker'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isUser ? Colors.white70 : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.volume_up_rounded,
                              size: 16,
                              color: isUser ? Colors.white70 : const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d['text_target'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['text_ar'],
                          style: TextStyle(
                            fontSize: 13,
                            color: isUser ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // شريط التفاعل السفلي العصري
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('اضغط على الميكروفون للتحدث والتدرب...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2563EB),
                  child: IconButton(
                    icon: const Icon(Icons.mic_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
