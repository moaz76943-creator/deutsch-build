import 'package:flutter/material.dart';
import '../../services/user_customization_service.dart';
import '../../models/content.dart';

class ContextualExamplesDrawer extends StatefulWidget {
  final ContentItem item;
  final UserCustomizationService service;
  final VoidCallback onRefresh;

  const ContextualExamplesDrawer({
    super.key,
    required this.item,
    required this.service,
    required this.onRefresh,
  });

  static Future<void> show(BuildContext context, ContentItem item, UserCustomizationService service, VoidCallback onRefresh) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ContextualExamplesDrawer(item: item, service: service, onRefresh: onRefresh),
    );
  }

  @override
  State<ContextualExamplesDrawer> createState() => _ContextualExamplesDrawerState();
}

class _ContextualExamplesDrawerState extends State<ContextualExamplesDrawer> {
  final _germanController = TextEditingController();
  final _arabicController = TextEditingController();
  List<CustomExample> _customExamples = [];

  @override
  void initState() {
    super.initState();
    _loadCustomExamples();
  }

  Future<void> _loadCustomExamples() async {
    final examples = await widget.service.getCustomExamples(widget.item.id);
    if (mounted) {
      setState(() {
        _customExamples = examples;
      });
    }
  }

  Future<void> _addExample() async {
    final german = _germanController.text.trim();
    final arabic = _arabicController.text.trim();
    if (german.isNotEmpty && arabic.isNotEmpty) {
      await widget.service.addCustomExample(widget.item.id, german, arabic);
      _germanController.clear();
      _arabicController.clear();
      await _loadCustomExamples();
      widget.onRefresh();
    }
  }

  Future<void> _deleteExample(int id) async {
    await widget.service.deleteCustomExample(id);
    await _loadCustomExamples();
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أمثلة لـ ${widget.item.sourceText}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (widget.item.exampleText.isNotEmpty)
              ListTile(
                title: Text(widget.item.exampleText),
                subtitle: Text(widget.item.exampleTranslationText),
                leading: const Icon(Icons.bookmark),
              ),
            ..._customExamples.map((ex) => ListTile(
                  title: Text(ex.germanSentence),
                  subtitle: Text(ex.arabicSentence),
                  leading: const Icon(Icons.edit_note, color: Colors.blue),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteExample(ex.id),
                  ),
                )),
            const Divider(),
            TextField(
              controller: _germanController,
              decoration: const InputDecoration(labelText: 'مثال بالألمانية'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _arabicController,
              decoration: const InputDecoration(labelText: 'الترجمة بالعربية'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addExample,
              child: const Text('إضافة مثال مخصص'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showEditTranslationSheet(BuildContext context, ContentItem item, UserCustomizationService service, VoidCallback onRefresh) async {
  final arabicController = TextEditingController();
  final notesController = TextEditingController();

  final customData = await service.getCustomization(item.id);
  if (customData != null) {
    arabicController.text = customData.customArabicTranslation ?? '';
    notesController.text = customData.customNotes ?? '';
  }

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تعديل الترجمة لـ ${item.sourceText}', style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(
              controller: arabicController,
              decoration: const InputDecoration(labelText: 'ترجمة مخصصة'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات إضافية'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await service.resetTranslationOverride(item.id);
                    onRefresh();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('استعادة الافتراضي'),
                ),
                FilledButton(
                  onPressed: () async {
                    await service.saveTranslationOverride(item.id, arabicController.text, notesController.text);
                    onRefresh();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
