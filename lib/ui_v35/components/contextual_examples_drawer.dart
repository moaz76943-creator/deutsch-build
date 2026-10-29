import 'package:flutter/material.dart';

class ContextualExamplesDrawer extends StatelessWidget {
  final List<String> examples;

  const ContextualExamplesDrawer({super.key, required this.examples});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أمثلة سياقية',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                if (examples.isEmpty)
                  const Text('لا توجد أمثلة متاحة.')
                else
                  ...examples.map(
                    (ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        ex,
                        style: const TextStyle(fontSize: 16),
                        textDirection: TextDirection.ltr,
                      ),
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
