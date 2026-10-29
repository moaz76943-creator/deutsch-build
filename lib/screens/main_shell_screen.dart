import 'package:deutsch_bilarabi/design_system/floating_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';
import 'curriculum_units_screen.dart';
import 'offline_dictionary_screen.dart';
import 'profile_hub_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onNavigateToUnits: () => setState(() => _currentIndex = 1)),
      const CurriculumUnitsScreen(),
      const OfflineDictionaryScreen(),
      const ProfileHubScreen(),
    ];

    final shell = Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : FloatingBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const <NavBarItemData>[
                NavBarItemData(icon: Icons.home_rounded, label: 'الرئيسية'),
                NavBarItemData(icon: Icons.menu_book_rounded, label: 'الدروس'),
                NavBarItemData(icon: Icons.translate_rounded, label: 'المعجم'),
                NavBarItemData(icon: Icons.person_rounded, label: 'حسابي'),
              ],
            ),
    );
    // Screens reached from onboarding tests and deep links still need the
    // root provider container. The application root already provides one.
    try {
      ProviderScope.containerOf(context);
      return shell;
    } on StateError {
      return ProviderScope(child: shell);
    }
  }
}
