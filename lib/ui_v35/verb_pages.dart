import 'package:flutter/material.dart';

import '../models/verb_conjugation.dart';
import '../services/repository.dart';
import '../services/verb_index.dart';
import 'safe_ui.dart';

class VerbConjugationPage extends StatefulWidget {
  final LearnerRepository repo;
  final VerbIndex verbIndex;
  const VerbConjugationPage({
    super.key,
    required this.repo,
    required this.verbIndex,
  });
  @override
  State<VerbConjugationPage> createState() => _VerbConjugationPageState();
}

class _VerbConjugationPageState extends State<VerbConjugationPage> {
  final SafeTtsController _tts = SafeTtsController();
  final Set<String> _favorites = <String>{};

  // Precomputed flat list for efficient ListView.builder (headers + cards).
  // Avoids materializing every card up front.
  late final List<_VerbListItem> _items;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _items = _buildItems();
  }

  List<_VerbListItem> _buildItems() {
    final groups = widget.verbIndex.groups;
    final ks = groups.keys.toList()..sort();
    final items = <_VerbListItem>[];
    items.add(const _HeaderItem());
    for (final g in ks) {
      items.add(_GroupHeaderItem(g));
      for (final infinitive in groups[g] ?? const <String>[]) {
        for (final v in widget.verbIndex.rowsFor(infinitive)) {
          items.add(_VerbCardItem(v));
        }
      }
    }
    return items;
  }

  Future<void> _loadFavorites() async {
    try {
      final saved = await widget.repo.loadAndMigrateFavoriteVerbs();
      if (mounted)
        setState(() {
          _favorites.addAll(saved);
        });
    } catch (_) {}
  }

  Future<void> _toggleFavorite(String infinitive) async {
    try {
      await widget.repo.toggleFavoriteVerb(infinitive);
      if (!mounted) return;
      setState(() {
        if (_favorites.contains(infinitive)) {
          _favorites.remove(infinitive);
        } else {
          _favorites.add(infinitive);
        }
      });
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _speak(String text) => _tts.speak(text);

  Widget _audioButton(String text) => IconButton(
        tooltip: 'استمع للنطق الألماني',
        onPressed: () => _speak(text),
        icon: const Icon(Icons.volume_up_outlined),
      );

  Widget _verbCard(BuildContext c, VerbConjugation v) {
    final key = '${v.infinitive}|${v.person}';
    final isFav = _favorites.contains(v.infinitive);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    v.infinitive,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                IconButton(
                  tooltip: isFav
                      ? 'إزالة الفعل من المفضلة'
                      : 'إضافة الفعل إلى قائمة الأفعال الدراسية',
                  onPressed: () => _toggleFavorite(v.infinitive),
                  icon: Icon(isFav ? Icons.star : Icons.star_border),
                ),
              ],
            ),
            Text(v.arabic, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(c).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${v.person} — ${v.personAr}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  _audioButton(v.form),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الحاضر: ${v.form}',
              style: const TextStyle(fontWeight: FontWeight.w700),
              textDirection: TextDirection.ltr,
            ),
            Text('المعنى: ${v.personAr} ${v.arabic}'),
            const SizedBox(height: 8),
            Text(
              'الماضي (Perfekt): ${v.past}',
              style: const TextStyle(fontWeight: FontWeight.w700),
              textDirection: TextDirection.ltr,
            ),
            Text('ترجمة الماضي: ${v.pastArabic}'),
            const Divider(height: 20),
            Text('مثال الحاضر', style: Theme.of(c).textTheme.labelLarge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    v.example,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                _audioButton(v.example),
              ],
            ),
            Text(v.exampleAr),
            const SizedBox(height: 10),
            Text('مثال الماضي', style: Theme.of(c).textTheme.labelLarge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    v.pastExample,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                _audioButton(v.pastExample),
              ],
            ),
            Text(v.pastExampleAr),
            const SizedBox(height: 6),
            Text('معرّف الدراسة: $key', style: Theme.of(c).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final uniqueVerbs = widget.verbIndex.infinitives.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأفعال والتصريف'),
        actions: [
          IconButton(
            tooltip: 'قائمة الأفعال المفضلة',
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => VerbFavoritesPage(
                  favorites: _favorites.toList(),
                  speak: _speak,
                  verbIndex: widget.verbIndex,
                ),
              ),
            ),
            icon: const Icon(Icons.star),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('المفضلة: ${_favorites.length}')),
          ),
        ],
      ),
      body: ListView.builder(
        // Performance: bound pre-build area beyond viewport.
        // Moderate value balances smoothness vs memory on complex verb cards
        // that contain multiple Text widgets, IconButtons, and nested layouts.
        cacheExtent: 300,
        addAutomaticKeepAlives: false,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          Widget child;
          if (item is _HeaderItem) {
            child = Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'كل ضمير مستقل: ich، du، er، sie (هي)، es، wir، ihr، sie (هم)، Sie. لكل تصريف نطق مستقل، ماضٍ، ومثال حاضر ومثال ماضٍ مع الترجمة. عدد الأفعال: $uniqueVerbs',
                ),
              ),
            );
          } else if (item is _GroupHeaderItem) {
            child = Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
              child: Text(
                item.group,
                style: Theme.of(c)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            );
          } else if (item is _VerbCardItem) {
            child = _verbCard(c, item.verb);
          } else {
            child = const SizedBox.shrink();
          }
          // Isolate repaints of complex verb cards during scroll.
          return RepaintBoundary(child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }
}

// Sealed-like item model for the builder (keeps the file self-contained).
abstract class _VerbListItem {}

class _HeaderItem extends _VerbListItem {
  const _HeaderItem();
}

class _GroupHeaderItem extends _VerbListItem {
  final String group;
  const _GroupHeaderItem(this.group);
}

class _VerbCardItem extends _VerbListItem {
  final VerbConjugation verb;
  const _VerbCardItem(this.verb);
}

class VerbFavoritesPage extends StatelessWidget {
  final List<String> favorites;
  final Future<void> Function(String) speak;
  final VerbIndex verbIndex;
  const VerbFavoritesPage({
    super.key,
    required this.favorites,
    required this.speak,
    required this.verbIndex,
  });
  @override
  Widget build(BuildContext c) {
    final selected = <VerbConjugation>[];
    for (final favorite in favorites) {
      selected.addAll(verbIndex.rowsFor(favorite));
    }
    return Scaffold(
      appBar: AppBar(title: Text('أفعال للدراسة (${favorites.length})')),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'لم تضف أفعالًا للمفضلة بعد. اضغط ⭐ بجانب الفعل لإضافته.',
              ),
            )
          : ListView.builder(
              // Same performance treatment for the favorites list.
              cacheExtent: 300,
              addAutomaticKeepAlives: false,
              padding: const EdgeInsets.all(12),
              itemCount: selected.length,
              itemBuilder: (context, index) {
                final v = selected[index];
                return RepaintBoundary(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  v.infinitive,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                              IconButton(
                                tooltip: 'نطق الفعل',
                                onPressed: () => speak(v.infinitive),
                                icon: const Icon(Icons.volume_up_outlined),
                              ),
                            ],
                          ),
                          Text(v.arabic),
                          const SizedBox(height: 8),
                          Text(
                            '${v.person} — ${v.form}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                            textDirection: TextDirection.ltr,
                          ),
                          Text(v.personAr),
                          const SizedBox(height: 6),
                          Text(
                            'الماضي: ${v.past}',
                            textDirection: TextDirection.ltr,
                          ),
                          Text(v.pastArabic),
                          const SizedBox(height: 8),
                          Text(
                            v.example,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            textDirection: TextDirection.ltr,
                          ),
                          Text(v.exampleAr),
                          const SizedBox(height: 6),
                          Text(
                            v.pastExample,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            textDirection: TextDirection.ltr,
                          ),
                          Text(v.pastExampleAr),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
