import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  String _statusMessage = 'جاهز لإجراء النسخ الاحتياطي أو الاستعادة المحلية.';
  bool _isLoading = false;

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final Map<String, dynamic> data = {};
      for (var key in keys) {
        data[key] = prefs.get(key);
      }

      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/deutsch_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await backupFile.writeAsString(jsonEncode(data));

      setState(() {
        _statusMessage = 'تم تصدير النسخة الاحتياطية بنجاح إلى:
${backupFile.path}';
      });
    } catch (e) {
      setState(() => _statusMessage = 'فشل تصدير النسخة الاحتياطية: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreLatestBackup() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().whereType<File>().where((f) => f.path.contains('deutsch_backup_')).toList();

      if (files.isEmpty) {
        setState(() => _statusMessage = 'لم يتم العثور على أي ملفات نسخ احتياطي سابقة محلياً.');
        return;
      }

      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final latest = files.first;
      final raw = await latest.readAsString();
      final Map<String, dynamic> data = jsonDecode(raw);

      final prefs = await SharedPreferences.getInstance();
      for (var entry in data.entries) {
        if (entry.value is bool) await prefs.setBool(entry.key, entry.value);
        else if (entry.value is int) await prefs.setInt(entry.key, entry.value);
        else if (entry.value is double) await prefs.setDouble(entry.key, entry.value);
        else if (entry.value is String) await prefs.setString(entry.key, entry.value);
        else if (entry.value is List) await prefs.setStringList(entry.key, List<String>.from(entry.value));
      }

      setState(() {
        _statusMessage = 'تمت استعادة البيانات بنجاح من:
${latest.path}';
      });
    } catch (e) {
      setState(() => _statusMessage = 'فشل استعادة البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي والاستعادة المحلية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security_update_good_rounded, size: 72, color: Color(0xFF4F46E5)),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _exportBackup,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('تصدير نسخة احتياطية محلية (JSON)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _restoreLatestBackup,
                icon: const Icon(Icons.download_rounded),
                label: const Text('استعادة أحدث نسخة احتياطية'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
