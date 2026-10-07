import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/progress_storage_service.dart';
import '../services/tts_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TtsService _tts = TtsService();
  List<Map<String, dynamic>> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final rawList = await ProgressStorageService.getFavorites();
    final List<Map<String, dynamic>> parsed = [];
    for (var str in rawList) {
      try {
        parsed.add(Map<String, dynamic>.from(json.decode(str)));
      } catch (_) {}
    }
    setState(() {
      _favorites = parsed;
      _loading = false;
    });
  }

  void _removeFavorite(int index) async {
    final item = _favorites[index];
    await ProgressStorageService.toggleFavorite(json.encode(item));
    setState(() {
      _favorites.removeAt(index);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الإزالة من المفضلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved Terms / كلماتي المحفوظة', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${_favorites.length} كلمة محفوظة', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bookmark_border_rounded, size: 48, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 16),
                      const Text('لا توجد كلمات محفوظة حالياً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      const Text('اضغط على أيقونة الإشارة المرجعية لأي كلمة لحفظها هنا', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final item = _favorites[index];
                    final term = item['term'] ?? item['word'] ?? '';
                    final meaning = item['meaning'] ?? item['translation'] ?? '';
                    final lang = item['lang'] ?? 'de';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB)),
                            onPressed: () => _tts.speak(term, langCode: lang),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(term, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(meaning, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _removeFavorite(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
