import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class VocabularyJournalScreen extends StatefulWidget {
  const VocabularyJournalScreen({super.key});

  @override
  State<VocabularyJournalScreen> createState() => _VocabularyJournalScreenState();
}

class _VocabularyJournalScreenState extends State<VocabularyJournalScreen> {
  final TextEditingController _wordController = TextEditingController();
  final List<Map<String, String>> _journalItems = [
    {"word": "die Herausforderung", "meaning": "التحدي / الصعوبة", "example": "Das ist eine große Herausforderung."},
    {"word": "nachhaltig", "meaning": "مستدام / دائم", "example": "Wir brauchen nachhaltige Lösungen."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مفكرة الكلمات الحية الشخصية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('أضف كلمة جديدة تدربت عليها:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _wordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'اكتب الكلمة هنا...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (_wordController.text.trim().isNotEmpty) {
                            setState(() {
                              _journalItems.insert(0, {
                                "word": _wordController.text.trim(),
                                "meaning": "تم توليد المعنى والأمثلة تلقائياً",
                                "example": "مثال توضيحي ذكي للكلمة الجديدة."
                              });
                              _wordController.clear();
                            });
                          }
                        },
                        child: const Text('إضافة وتحليل بالذكاء الاصطناعي', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('سجل كلماتك الشخصية:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _journalItems.length,
                    itemBuilder: (context, index) {
                      final item = _journalItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppBaseGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item['word']!, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('المعنى: ${item['meaning']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('مثال: ${item['example']}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
