import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/privacy/microphone_disclosure.dart';
import '../design_system/design_system.dart';
import 'language_manager_screen.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  static const String _privacyPolicyUrl =
      'https://deutsch-bilarabi-privacy.netlify.app/privacy.html';

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
            const SizedBox(height: 16),
            AppBaseGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('حول التطبيق',
                      style: AppTypography.title.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    kMicrophoneDisclosureText,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(kPrivacyPolicyUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Text(kPrivacyPolicyUrl),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
