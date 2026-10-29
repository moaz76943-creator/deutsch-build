import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurriculumHubScreen extends StatefulWidget {
  const CurriculumHubScreen({super.key});

  @override
  State<CurriculumHubScreen> createState() => _CurriculumHubScreenState();
}

class _CurriculumHubScreenState extends State<CurriculumHubScreen> {
  List<dynamic> _missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/missions_50.json');
      setState(() {
        _missions = jsonDecode(jsonStr);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المناهج والمهام الحياتية (50 مهمة)'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _missions[index];
                return AppBaseGlassCard(
                  
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      child: Text(
                        item['level'] ?? 'A1',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    title: Text(item['titleAr'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(item['titleDe'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('بدء التدريب: ${item['titleAr']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
