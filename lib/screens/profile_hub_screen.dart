import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'offline_storage_screen.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  static const String _privacyPolicyUrl =
      'https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html';

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Deutsch بالعربي prioritizes your privacy. The app is offline-first.',
              ),
              const SizedBox(height: 12),
              const Text(
                'RECORD_AUDIO (optional): Used only for on-device pronunciation practice. Audio never leaves your device.',
              ),
              const SizedBox(height: 8),
              const Text(
                'No personal data is collected or shared. Uninstalling the app removes all local data.',
              ),
              const SizedBox(height: 16),
              const Text('Full policy:'),
              SelectableText(
                _privacyPolicyUrl,
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: Enable GitHub Pages on the deutsch-bilarabi-privacy repository for the public URL to be live (required for Play Console).',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

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
                        builder: (_) => const OfflineStorageScreen()));
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
            const SizedBox(height: 12),
            AppBaseGlassCard(
              onTap: () => _showPrivacyPolicy(context),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.privacy_tip_rounded,
                      color: Color(0xFF60A5FA), size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Privacy Policy',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('View data practices & Google Play compliance',
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
