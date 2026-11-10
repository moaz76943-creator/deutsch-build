import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CurriculumHubScreen extends StatefulWidget {
  const CurriculumHubScreen({super.key});

  @override
  State<CurriculumHubScreen> createState() => _CurriculumHubScreenState();
}

class _CurriculumHubScreenState extends State<CurriculumHubScreen> {
  List<dynamic> _missions = [];
  bool _isLoading = true;
  // Simple in-memory cache to avoid re-parsing on subsequent visits (measurable for navigation).
  static List<dynamic>? _cachedMissions;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    if (_cachedMissions != null) {
      setState(() {
        _missions = _cachedMissions!;
        _isLoading = false;
      });
      return;
    }
    try {
      final jsonStr = await rootBundle.loadString('assets/data/missions_50.json');
      // Offload CPU-bound JSON decoding to a background isolate.
      // Prevents potential UI jank during startup/screen load.
      final decoded = await compute(_decodeJson, jsonStr);
      _cachedMissions = decoded;
      if (mounted) {
        setState(() {
          _missions = decoded;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static List<dynamic> _decodeJson(String jsonStr) {
    return jsonDecode(jsonStr) as List<dynamic>;
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
              // Performance: bound pre-build area beyond the viewport.
              cacheExtent: 300,
              // Pure card items; no persistent state to keep alive when off-screen.
              // Disabling reduces memory pressure on longer mission lists.
              addAutomaticKeepAlives: false,
              itemCount: _missions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _missions[index] is Map
                    ? Map<String, dynamic>.from(_missions[index] as Map)
                    : <String, dynamic>{};
                return RepaintBoundary(
                  // Isolates repaint of each mission card. Reduces overpaint
                  // when sibling items update or during scroll on complex glass cards.
                  // Expected: fewer dropped frames on curriculum list scroll,
                  // especially on mid-range devices.
                  child: AppBaseGlassCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF4F46E5).withValues(alpha: 0.1),
                        child: Text(
                          '${item['level'] ?? 'A1'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text('${item['titleAr'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${item['titleDe'] ?? ''}'),
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
                  ),
                );
              },
            ),
    );
  }
}
