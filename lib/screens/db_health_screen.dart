import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../repositories/vocabulary_repository.dart';

class DbHealthScreen extends StatefulWidget {
  const DbHealthScreen({super.key});

  @override
  State<DbHealthScreen> createState() => _DbHealthScreenState();
}

class _DbHealthScreenState extends State<DbHealthScreen> {
  final VocabularyRepository _repository = VocabularyRepository();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _repository.getDatabaseHealthStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صحة البيانات والتحليلات المحلية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppBaseGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('📊 مؤشرات الأداء والذاكرة المحلية', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('إجمالي المفردات المخزنة: ${_stats['totalCount'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text('حجم الذاكرة المستهلكة: ${((_stats['sizeInBytes'] ?? 0) / 1024).toStringAsFixed(2)} KB', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text('حالة قاعدة البيانات: ${_stats['status']}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppBaseGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🌐 توزيع المفردات حسب اللغات', style: TextStyle(color: Color(0xFF34D399), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ...((_stats['langCounts'] as Map<String, dynamic>? ?? {}).entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.between,
                                  children: [
                                    Text('اللغة: ${entry.key.toUpperCase()}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    Text('${entry.value} مفردة', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            })),
                          ],
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
