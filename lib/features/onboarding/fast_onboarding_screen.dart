import 'package:flutter/material.dart';
import '../../screens/flashcards_screen.dart';

/// مسار الصفر-إلى-واحد: أسرع تجربة وصول لأول بطاقة بدون إنترنت
class FastOnboardingScreen extends StatelessWidget {
  const FastOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 24),
                const Text(
                  'DEUTSCH بالعربي',
                  style: TextStyle(
                    fontSize: 28, 
                    fontFamily: 'Cairo', 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تعلم الألمانية دون إنترنت، ومراجعاتك محفوظة بأمان على هاتفك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontFamily: 'Cairo', color: Colors.white70),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    // الانتقال المباشر والفوري لأول بطاقة تعليمية
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const FlashcardsScreen()),
                    );
                  },
                  child: const Text(
                    'ابدأ جلستك الأولى الآن',
                    style: TextStyle(
                      fontSize: 18, 
                      fontFamily: 'Cairo', 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
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
