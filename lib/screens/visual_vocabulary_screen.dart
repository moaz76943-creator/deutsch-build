import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/repositories/vocabulary_repository.dart';
import 'package:deutsch_bilarabi/models/vocabulary_item.dart';
import 'package:deutsch_bilarabi/widgets/neumorphic_vocabulary_card.dart';

class VisualVocabularyScreen extends StatefulWidget {
  const VisualVocabularyScreen({super.key});

  @override
  State<VisualVocabularyScreen> createState() => _VisualVocabularyScreenState();
}

class _VisualVocabularyScreenState extends State<VisualVocabularyScreen> {
  final VocabularyRepository _repository = VocabularyRepository();
  List<VocabularyItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rawList = await _repository.getVocabularyList();
    if (mounted) {
      setState(() {
        _items = rawList.map((e) => VocabularyItem.fromJson(e)).where((item) => item.imageUrl.isNotEmpty).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفردات البصرية المباشرة'),
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
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('لا توجد مفردات بصور.', style: TextStyle(color: Colors.white)))
                    : SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return SizedBox(
                              width: 200,
                              child: NeumorphicVocabularyCard(
                                imageUrl: item.imageUrl,
                                heroTag: 'visual_vocab_${item.word}_$index',
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.languageCode == 'de' ? '${item.article} ${item.word}' : item.word, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(item.meaning, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}