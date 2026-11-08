import 'package:flutter/material.dart';

import '../services/streak_milestones_engine.dart';

class MilestoneBadgesPage extends StatefulWidget {
  final int currentStreak;
  final StreakMilestonesEngine engine;

  const MilestoneBadgesPage({
    super.key,
    required this.currentStreak,
    required this.engine,
  });

  @override
  State<MilestoneBadgesPage> createState() => _MilestoneBadgesPageState();
}

class _MilestoneBadgesPageState extends State<MilestoneBadgesPage> {
  Set<String> unlockedBadges = {};
  bool loading = true;
  late final List<_BadgeListItem> _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await widget.engine.checkAndUnlockMilestones(widget.currentStreak);
    final unlocked = await widget.engine.getUnlockedMilestones();
    if (mounted) {
      setState(() {
        unlockedBadges = unlocked;
        _items = _buildItems();
        loading = false;
      });
    }
  }

  List<_BadgeListItem> _buildItems() {
    final items = <_BadgeListItem>[];
    items.add(const _HeaderItem());
    items.add(const _TitleItem());
    for (final badge in StreakMilestonesEngine.availableBadges) {
      items.add(_BadgeItem(badge));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إنجازات الاستمرارية')),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          if (item is _HeaderItem) {
            return Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الاستمرارية الحالية: ${widget.currentStreak} أيام',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            );
          } else if (item is _TitleItem) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                'الشارات',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            );
          } else if (item is _BadgeItem) {
            final badge = item.badge;
            final isUnlocked = unlockedBadges.contains(badge.id);
            return Card(
              color: isUnlocked
                  ? null
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: Icon(
                  isUnlocked ? Icons.stars : Icons.lock_outline,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                  size: 32,
                ),
                title: Text(
                  badge.title,
                  style: TextStyle(
                    fontWeight:
                        isUnlocked ? FontWeight.w800 : FontWeight.normal,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  badge.description,
                  style: TextStyle(color: isUnlocked ? null : Colors.grey),
                ),
                trailing: isUnlocked
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

abstract class _BadgeListItem {}

class _HeaderItem extends _BadgeListItem {
  const _HeaderItem();
}

class _TitleItem extends _BadgeListItem {
  const _TitleItem();
}

class _BadgeItem extends _BadgeListItem {
  final dynamic badge; // Adjust type if Badge model is known; kept flexible
  const _BadgeItem(this.badge);
}
