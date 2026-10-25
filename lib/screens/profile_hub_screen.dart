import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'language_manager_screen.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    child: const Icon(Icons.person_rounded,
                        size: 54, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text('المتعلم المثابر',
                      style: AppTypography.display
                          .copyWith(color: Colors.white, fontSize: 22)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppBaseGlassCard(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LanguageManagerScreen()));
              },
              child: const Row(
                children: <Widget>[
                  Icon(Icons.folder_special_rounded,
                      color: Color(0xFF10B981), size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('إدارة اللغات والتخزين (100 لغة)',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('تنزيل حزم اللغات والصوتيات دون اتصال',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white38, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
