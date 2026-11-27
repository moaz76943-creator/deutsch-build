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
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final badges = StreakMilestonesEngine.availableBadges;

    return Scaffold(
      appBar: AppBar(title: const Text('إنجازات الاستمرارية')),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        // Performance: bound pre-build area beyond viewport.
        // Moderate value balances smoothness vs memory on badge cards.
        cacheExtent: 300,
        // Disable keep-alives for pure display items to lower memory.
        addAutomaticKeepAlives: false,
        itemCount: 3 + badges.length, // header card, spacer+title, badges
        itemBuilder: (context, index) {
          if (index == 0) {
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
          }
          if (index == 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'الشارات',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
              ],
            );
          }
          final badgeIndex = index - 2;
          final badge = badges[badgeIndex];
          final isUnlocked = unlockedBadges.contains(badge.id);
          return RepaintBoundary(
            child: Card(
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
            ),
          );
        },
      ),
    );
  }
}
