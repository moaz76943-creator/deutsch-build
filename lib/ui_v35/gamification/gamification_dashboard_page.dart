import 'package:flutter/material.dart';

import '../../features/gamification/domain/gamification_models.dart';
import '../../features/gamification/gamification_repository.dart';
import 'gamification_dashboard_sections.dart';

class GamificationDashboardPage extends StatefulWidget {
  const GamificationDashboardPage({super.key, required this.repository});

  final GamificationRepository repository;

  @override
  State<GamificationDashboardPage> createState() =>
      _GamificationDashboardPageState();
}

class _GamificationDashboardPageState extends State<GamificationDashboardPage> {
  late Future<GamificationSnapshot> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.repository.loadSnapshot();
  }

  void _refresh() {
    setState(() {
      _snapshot = widget.repository.loadSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('الإنجازات و XP'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder<GamificationSnapshot>(
            future: _snapshot,
            builder: (context, state) {
              if (state.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.hasError || state.data == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'تعذر قراءة بيانات الإنجازات المحلية. '
                      'لن يتم عرض أرقام تقديرية أو جلب بيانات من خادم.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final snapshot = state.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  const Text(
                    'يتم احتساب XP والسلسلة من مراجعات SRS المكتملة وتخزينها '
                    'محليًا في SQLite على الجهاز.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  if (snapshot.profile.clockAnomalyDetected) ...[
                    const GamificationClockWarning(),
                    const SizedBox(height: 12),
                  ],
                  GamificationSummaryGrid(snapshot: snapshot),
                  const SizedBox(height: 12),
                  GamificationNextMilestoneCard(snapshot: snapshot),
                  const SizedBox(height: 12),
                  GamificationBadgeList(snapshot: snapshot),
                ],
              );
            },
          ),
        ),
      );
}
