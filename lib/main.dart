import 'design_system/design_system.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell_screen.dart';

void main() {
  runApp(const DeutschApp());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch بالعربي',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => OnboardingScreen(
          onStart: () {
            // الانتقال الفوري للواجهة الرئيسية المجمعة عند الضغط على زر "ابدأ"
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShellScreen()),
            );
          },
        ),
      ),
    );
  }
}
