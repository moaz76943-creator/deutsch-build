import '../design_system/design_system.dart';
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

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
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
  }
}
