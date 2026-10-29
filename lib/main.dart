import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

void main() async {
  // 1. ضمان استقرار محرك الرسوميات وربط النظام
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تثبيت اتجاه الشاشة وتحسين مظهر شريط الحالة
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. مصيدة الأخطاء الشفافة لحماية التطبيق من الانهيار المفاجئ
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("[DBA][FLUTTER_ERROR] ${details.exceptionAsString()}");
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F172A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
                    SizedBox(width: 8),
                    Text(
                      "STARTUP ISSUE DETECTED",
                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  details.exceptionAsString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: "monospace"),
                ),
                const SizedBox(height: 12),
                Text(
                  details.stack.toString(),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: "monospace"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // 4. تشغيل التطبيق محاطاً بـ ProviderScope لضمان عمل كل مزودات الحالة
  runApp(
    const ProviderScope(
      child: DeutschApp(),
    ),
  );
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deutsch بالعربي',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
      ),
      // نقطة الانطلاق إلى شاشة البداية الكاملة لتطبيقك
      home: const FastOnboardingScreen(),
    );
  }
}
