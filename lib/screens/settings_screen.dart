import 'package:flutter/material.dart';
import '../services/progress_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _offlineAudio = true;
  double _speechRate = 0.45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Settings / الإعدادات',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('الصوت والنطق الصوتي / Audio & TTS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سرعة النطق التلقائي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${(_speechRate * 2).toStringAsFixed(1)}x', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _speechRate,
                  min: 0.25,
                  max: 0.75,
                  divisions: 4,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (val) => setState(() => _speechRate = val),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تشغيل بدون إنترنت (Offline Mode)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('استخدام الحزم المحلية المخزنة مسبقاً', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  value: _offlineAudio,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) => setState(() => _offlineAudio = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('البيانات والتقدم / Data & Progress'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              leading: const Icon(Icons.refresh_rounded, color: Colors.redAccent),
              title: const Text('إعادة ضبط نقاط التعلم', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('إعادة تعيين رصيد النقاط والبدء من جديد', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              onTap: () async {
                await ProgressStorageService.addPoints(-500);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث النقاط بنجاح')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('حول التطبيق / About'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deutsch بالعربي - Universal Edition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('النسخة 2.0 • 20 لغة متكاملة بدون إنترنت', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
      ),
    );
  }
}
