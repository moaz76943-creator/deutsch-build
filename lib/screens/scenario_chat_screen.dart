import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class ScenarioChatScreen extends StatefulWidget {
  const ScenarioChatScreen({super.key});

  @override
  State<ScenarioChatScreen> createState() => _ScenarioChatScreenState();
}

class _ScenarioChatScreenState extends State<ScenarioChatScreen> {
  final List<Map<String, String>> _scenarios = [
    {
      "title": "طلب قهوة في المقهى",
      "subtitle": "تعلم كيف تطلب مشروبك المفضل وتدفع الحساب",
      "level": "مبتدئ (A1)",
      "icon": "☕"
    },
    {
      "title": "في المطار وبوابة السفر",
      "subtitle": "التعامل مع موظف التذاكر والبحث عن البوابة",
      "level": "متوسط (A2)",
      "icon": "✈️"
    },
    {
      "title": "عند الطبيب وفي الصيدلية",
      "subtitle": "شرح الأعراض وطلب الأدوية المناسبة",
      "level": "متقدم (B1)",
      "icon": "💊"
    },
    {
      "title": "التسوق وشراء الملابس",
      "subtitle": "السؤال عن المقاسات والأسعار والمساومة",
      "level": "مبتدئ (A1)",
      "icon": "🛍️"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سيناريوهات الحياة اليومية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'تدرب على مواقف حقيقية من الحياة اليومية لكل لغة',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _scenarios.length,
                    itemBuilder: (context, index) {
                      final item = _scenarios[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: AppBaseGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: <Widget>[
                              Text(
                                item['icon']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item['title']!,
                                      style: AppTypography.display.copyWith(color: Colors.white, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['subtitle']!,
                                      style: AppTypography.body.copyWith(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['level']!,
                                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
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
