// Language Selector Screen - Post-V1 Expansion
// UI for listing available languages and managing their pack lifecycles

import 'package:flutter/material.dart';
import 'contract/content_contracts.dart';
import 'contract/language_pack_manager.dart';
import 'content_dashboard_screen.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  final LanguagePackManager _packManager = LanguagePackManager();
  
  final List<String> _supportedCodes = ['de', 'ar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Language Pack')),
      body: ListView.builder(
        itemCount: _supportedCodes.length,
        itemBuilder: (context, index) {
          final code = _supportedCodes[index];
          final langInfo = HundredLanguagesRegistry.getLanguage(code);
          final isActive = _packManager.isPackActive('pack_${code}_v1');

          return ListTile(
            title: Text(langInfo?.nativeName ?? code),
            subtitle: Text('Code: $code'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: isActive ? null : () async {
                    _packManager.registerPack('pack_${code}_v1');
                    await _packManager.activatePack('pack_${code}_v1');
                    setState(() {});
                  },
                  child: Text(isActive ? 'Active' : 'Activate'),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentDashboardScreen(activeLanguageCode: code),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
