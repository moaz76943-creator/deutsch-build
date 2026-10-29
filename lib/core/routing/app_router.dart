import '../../features/wordbit/ui/wordbit_carousel_screen.dart';
// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, unused_import
import 'package:flutter/material.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/flashcards_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/vocabulary_journal_screen.dart';
import '../../screens/speed_quiz_screen.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String dashboard = '/dashboard';
  static const String flashcards = '/flashcards';
  static const String vocabJournal = '/journal';
  static const String speedQuiz = '/speed-quiz';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => OnboardingScreen(onStart: () {}));
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case flashcards:
        return MaterialPageRoute(builder: (_) => FlashcardsScreen());
      case vocabJournal:
        return MaterialPageRoute(builder: (_) => VocabularyJournalScreen());
      case speedQuiz:
        return MaterialPageRoute(builder: (_) => SpeedQuizScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('المسار غير موجود: ' + (settings.name ?? '')),
            ),
          ),
        );
    }
  }
}
