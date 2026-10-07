import 'package:flutter/material.dart';
import '../content/contract/hundred_languages_registry.dart';

class LanguageSelectorScreen extends StatelessWidget {
  const LanguageSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار اللغة'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: HundredLanguagesRegistry.supportedLanguages.length,
          itemBuilder: (context, index) {
            final lang = HundredLanguagesRegistry.supportedLanguages[index];
            return ListTile(
              title: Text(lang.name),
              subtitle: Text(lang.nativeName),
              trailing: Text(lang.family),
            );
          },
        ),
      ),
    );
  }
}
