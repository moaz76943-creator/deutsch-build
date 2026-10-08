import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class SearchResultItem {
  final String title;
  final String subtitle;
  final String category; // 'مفردات', 'قواعد', 'أفعال', 'حوارات'
  final IconData icon;

  const SearchResultItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
  });
}

class UniversalSearchScreen extends StatefulWidget {
  const UniversalSearchScreen({super.key});

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  List<SearchResultItem> _results = [];

  final List<SearchResultItem> _database = const [
    SearchResultItem(title: 'gehen', subtitle: 'يذهب - فعل شاذ مع sein', category: 'أفعال', icon: Icons.bolt_rounded),
    SearchResultItem(title: 'der Tisch', subtitle: 'طاولة - اسم مذكر', category: 'مفردات', icon: Icons.title_rounded),
    SearchResultItem(title: 'Dativ-Präpositionen', subtitle: 'حروف الجر: aus, bei, mit, nach, von, zu', category: 'قواعد', icon: Icons.biotech_rounded),
    SearchResultItem(title: 'In der Apotheke', subtitle: 'حوار واقعي لطلب الأدوية', category: 'حوارات', icon: Icons.alt_route_rounded),
    SearchResultItem(title: 'Akkusativ-Objekt', subtitle: 'المفعول به المباشر في الجملة', category: 'قواعد', icon: Icons.transform_rounded),
  ];

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    final q = query.trim().toLowerCase();
    setState(() {
      _results = _database.where((item) =>
        item.title.toLowerCase().contains(q) || item.subtitle.toLowerCase().contains(q) || item.category.toLowerCase().contains(q)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('البحث الشامل', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _queryController,
                autofocus: true,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'ابحث عن كلمة، قاعدة، أو حوار...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _queryController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _queryController.clear(); _onSearch(''); })
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _results.isEmpty && _queryController.text.isNotEmpty
                    ? const Center(child: Text('لا توجد نتائج مطابقة.', style: AppStyles.subtitle))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                child: Icon(item.icon, color: AppColors.primary),
                              ),
                              title: AppDirectionalText.target(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text('${item.category} • ${item.subtitle}', style: AppStyles.body),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
