import '../design_system/design_system.dart';

class OfflineStorageScreen extends StatefulWidget {
  const OfflineStorageScreen({super.key});

  @override
  State<OfflineStorageScreen> createState() => _OfflineStorageScreenState();
}

class _OfflineStorageScreenState extends State<OfflineStorageScreen> {
  // محاكاة لحالة الحزم (سيتم ربطها بقاعدة البيانات لاحقاً)
  final List<Map<String, dynamic>> _packs = [
    {'code': 'de', 'name': 'الألمانية (A1-B1)', 'size': '24 MB', 'status': 'installed'},
    {'code': 'en', 'name': 'الإنجليزية (A1-B2)', 'size': '38 MB', 'status': 'available'},
    {'code': 'fr', 'name': 'الفرنسية (A1-A2)', 'size': '19 MB', 'status': 'downloading', 'progress': 0.45},
    {'code': 'es', 'name': 'الإسبانية (A1)', 'size': '12 MB', 'status': 'available'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التخزين واللغات (100 لغة)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: <Widget>[
              AppBaseGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('الذاكرة المستخدمة', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: <Widget>[
                          Expanded(flex: 30, child: Container(height: 12, color: const Color(0xFF2563EB))),
                          Expanded(flex: 70, child: Container(height: 12, color: Colors.white24)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('المساحة الإجمالية للحزم المثبتة: 24 ميغابايت', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('حزم اللغات المتاحة (On-Demand SQLite)', style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              ..._packs.map((pack) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppBaseGlassCard(
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          child: Text(pack['code'].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(pack['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              if (pack['status'] == 'downloading')
                                LinearProgressIndicator(
                                  value: pack['progress'],
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                                )
                              else
                                Text(pack['size'], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        _buildActionButton(pack),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> pack) {
    switch (pack['status']) {
      case 'installed':
        return const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28);
      case 'downloading':
        return Text('${(pack['progress'] * 100).toInt()}%', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold));
      case 'available':
      default:
        return IconButton(
          icon: const Icon(Icons.cloud_download_rounded, color: Color(0xFF38BDF8), size: 28),
          onPressed: () {
            // سيتم ربطها بدالة التحميل الحقيقية لاحقاً
            setState(() {
              pack['status'] = 'downloading';
              pack['progress'] = 0.1;
            });
          },
        );
    }
  }
}
