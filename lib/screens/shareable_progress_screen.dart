import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class ShareableProgressScreen extends StatelessWidget {
  const ShareableProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بطاقة الإنجاز القابلة للمشاركة'),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      const Text('🔥 5 أيام متتالية من التعلم',
                          style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                          '⭐ أتممت حفظ وتثبيت أكثر من 500 كلمة بنجاح عبر منصة "Deutsch بالعربي"',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('مستوى الإتقان: 84% 🚀',
                            style: TextStyle(
                                color: Color(0xFF34D399),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'تم نسخ وتوليد بطاقة الإنجاز بنجاح للمشاركة!'),
                          backgroundColor: Color(0xFF34D399)),
                    );
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('مشاركة البطاقة كصورة',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
