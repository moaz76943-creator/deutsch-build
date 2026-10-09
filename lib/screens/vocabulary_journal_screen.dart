import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../design_system/design_system.dart';

class VocabularyJournalScreen extends StatefulWidget {
  const VocabularyJournalScreen({super.key});

  @override
  State<VocabularyJournalScreen> createState() => _VocabularyJournalScreenState();
}

class _VocabularyJournalScreenState extends State<VocabularyJournalScreen> {
  final TextEditingController _wordController = TextEditingController();
  List<Map<String, String>> _journalItems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedWords();
  }

  // تحميل الكلمات المخزنة محلياً بصفة دائمة
  Future<void> _loadSavedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('saved_vocabulary_list');
    if (storedData != null) {
      final List<dynamic> decoded = jsonDecode(storedData);
      setState(() {
        _journalItems = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    } else {
      // عناصر افتراضية أولية إذا كانت القاعدة فارغة
      _journalItems = [
        {"word": "die Herausforderung", "meaning": "التحدي / الصعوبة", "example": "Das ist eine große Herausforderung."},
        {"word": "nachhaltig", "meaning": "مستدام / دائم", "example": "Wir brauchen nachhaltige Lösungen."},
      ];
      _saveWordsToLocal();
    }
  }

  // حفظ الكلمات في ذاكرة الجهاز المحلية بصورة دائمة
  Future<void> _saveWordsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_vocabulary_list', jsonEncode(_journalItems));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مفكرة الكلمات الحية (محفوظة محلياً)'),
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
                      const Text('أضف كلمة جديدة (ستحفظ بشكل دائم على جهازك):', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold)),
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
                        onPressed: () async {
                          if (_wordController.text.trim().isNotEmpty) {
                            setState(() {
                              _journalItems.insert(0, {
                                "word": _wordController.text.trim(),
                                "meaning": "معنى مُضاف محلياً",
                                "example": "مثال توضيحي مخزن في الذاكرة الدائمة."
                              });
                            });
                            await _saveWordsToLocal();
                            _wordController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حفظ الكلمة محلياً بشكل دائم بنجاح!'), backgroundColor: Color(0xFF34D399)),
                            );
                          }
                        },
                        child: const Text('حفظ دائم في قاعدة البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('سجل كلماتك المخزنة محلياً:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
