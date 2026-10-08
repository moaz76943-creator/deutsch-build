
import '../design_system/design_system.dart';
import 'home_screen.dart';
import 'curriculum_units_screen.dart';

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
      const Scaffold(body: Center(child: Text('المعجم والبحث (الدفعة 4)', style: TextStyle(color: Colors.white)))),
      const Scaffold(body: Center(child: Text('الملف والإحصائيات (الدفعة 5)', style: TextStyle(color: Colors.white)))),
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
