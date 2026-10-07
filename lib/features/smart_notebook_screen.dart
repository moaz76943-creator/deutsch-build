import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NoteType {
  noun('اسم / Nomen', Color(0xFF1E88E5), Icons.menu_book_rounded),
  verb('فعل / Verb', Color(0xFFFB8C00), Icons.directions_run_rounded),
  sentence('جملة / Satz', Color(0xFF43A047), Icons.chat_bubble_outline_rounded),
  adjective('صفة / Adjektiv', Color(0xFF8E24AA), Icons.auto_awesome_rounded),
  grammar('قاعدة / Notiz', Color(0xFF546E7A), Icons.lightbulb_outline_rounded);

  final String label;
  final Color color;
  final IconData icon;
  const NoteType(this.label, this.color, this.icon);
}

class NoteItem {
  String id;
  String title;
  String content;
  String translation;
  NoteType type;
  DateTime updatedAt;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.translation,
    required this.type,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'translation': translation,
    'type': type.name,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory NoteItem.fromMap(Map<String, dynamic> map) => NoteItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    translation: map['translation'] ?? '',
    type: NoteType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => NoteType.noun,
    ),
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

class SmartNotebookScreen extends StatefulWidget {
  final String languageCode; // e.g. 'de-DE'

  const SmartNotebookScreen({super.key, this.languageCode = 'de-DE'});

  @override
  State<SmartNotebookScreen> createState() => _SmartNotebookScreenState();
}

class _SmartNotebookScreenState extends State<SmartNotebookScreen> {
  final FlutterTts _tts = FlutterTts();
  List<NoteItem> _notes = [];
  NoteType? _selectedFilter;
  String _searchQuery = '';
  static const String _storageKey = 'user_custom_smart_notes';

  // حالة التحكم بالصوت الحالي
  String? _currentlyPlayingId;
  int _currentIteration = 0;
  int _repeatTarget = 1;
  double _speechRate = 0.5;
  bool _isAudioCancelled = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List decoded = json.decode(raw);
      setState(() {
        _notes = decoded.map((e) => NoteItem.fromMap(e)).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_notes.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _speakLoop(NoteItem note) async {
    final text = note.content.isNotEmpty ? note.content : note.title;
    if (text.trim().isEmpty) return;

    setState(() {
      _currentlyPlayingId = note.id;
      _isAudioCancelled = false;
      _currentIteration = 0;
    });

    await _tts.setLanguage(widget.languageCode);
    await _tts.setSpeechRate(_speechRate);

    for (int i = 1; i <= _repeatTarget; i++) {
      if (_isAudioCancelled || !mounted) break;
      setState(() => _currentIteration = i);
      await _tts.speak(text);
      await Future.delayed(Duration(milliseconds: (1300 / _speechRate).round()));
      if (_isAudioCancelled || !mounted) break;
    }

    if (mounted) {
      setState(() {
        _currentlyPlayingId = null;
        _currentIteration = 0;
      });
    }
  }

  void _stopAudio() {
    _isAudioCancelled = true;
    _tts.stop();
    setState(() {
      _currentlyPlayingId = null;
      _currentIteration = 0;
    });
  }

  void _openNoteEditor({NoteItem? existingNote}) {
    final titleCtrl = TextEditingController(text: existingNote?.title ?? '');
    final contentCtrl = TextEditingController(text: existingNote?.content ?? '');
    final transCtrl = TextEditingController(text: existingNote?.translation ?? '');
    NoteType currentType = existingNote?.type ?? NoteType.noun;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existingNote == null ? 'إضافة بطاقة جديدة' : 'تعديل البطاقة',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // شريط اختيار نوع الملاحظة بالألوان
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: NoteType.values.map((t) {
                      final isSel = t == currentType;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          avatar: Icon(t.icon, size: 16, color: isSel ? Colors.white : t.color),
                          label: Text(t.label),
                          selected: isSel,
                          selectedColor: t.color,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setModalState(() => currentType = t),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'العنوان أو الكلمة الرئيسية',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'النص / الجملة / التصريفات بالألمانية',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: transCtrl,
                  decoration: InputDecoration(
                    labelText: 'الترجمة أو الملاحظة بالعربية',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentType.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('حفظ الملاحظة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final content = contentCtrl.text.trim();
                    if (title.isEmpty && content.isEmpty) return;

                    setState(() {
                      if (existingNote == null) {
                        _notes.insert(
                          0,
                          NoteItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            content: content,
                            translation: transCtrl.text.trim(),
                            type: currentType,
                            updatedAt: DateTime.now(),
                          ),
                        );
                      } else {
                        existingNote.title = title;
                        existingNote.content = content;
                        existingNote.translation = transCtrl.text.trim();
                        existingNote.type = currentType;
                        existingNote.updatedAt = DateTime.now();
                      }
                    });
                    _saveNotes();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notes.where((n) {
      final matchesFilter = _selectedFilter == null || n.type == _selectedFilter;
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.translation.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر الملاحظات الذكي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            onPressed: () => _openNoteEditor(),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط ضبط الصوت الدائم في الأعلى (السرعة والتكرار)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.speed_rounded, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Text('${_speechRate.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _speechRate,
                    min: 0.3,
                    max: 1.0,
                    divisions: 7,
                    onChanged: (v) => setState(() => _speechRate = v),
                  ),
                ),
                const Icon(Icons.repeat_rounded, size: 18, color: Colors.teal),
                const SizedBox(width: 4),
                DropdownButton<int>(
                  value: _repeatTarget,
                  underline: const SizedBox(),
                  items: List.generate(9, (i) => i + 1).map((val) {
                    return DropdownMenuItem(value: val, child: Text('$val مرات', style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _repeatTarget = val);
                  },
                ),
              ],
            ),
          ),
          // حقل البحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث في العناوين والكلمات...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // تصنيفات الأقسام
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('الكل'),
                  selected: _selectedFilter == null,
                  onSelected: (_) => setState(() => _selectedFilter = null),
                ),
                ...NoteType.values.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    avatar: Icon(t.icon, size: 14, color: _selectedFilter == t ? Colors.white : t.color),
                    label: Text(t.label.split(' / ').first),
                    selected: _selectedFilter == t,
                    selectedColor: t.color,
                    labelStyle: TextStyle(color: _selectedFilter == t ? Colors.white : Colors.black87),
                    onSelected: (_) => setState(() => _selectedFilter = t),
                  ),
                )),
              ],
            ),
          ),
          // قائمة البطاقات الفخمة
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('لا توجد ملاحظات مسجلة بعد'))
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (ctx, i) {
                      final note = filtered[i];
                      final isPlayingThis = _currentlyPlayingId == note.id;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: note.type.color.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ترويسة البطاقة
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: note.type.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(note.type.icon, size: 14, color: note.type.color),
                                        const SizedBox(width: 4),
                                        Text(
                                          note.type.label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: note.type.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    onPressed: () => _openNoteEditor(existingNote: note),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() => _notes.removeWhere((item) => item.id == note.id));
                                      _saveNotes();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // عنوان الملاحظة
                              if (note.title.isNotEmpty)
                                Text(
                                  note.title,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              // المحتوى المكتوب
                              if (note.content.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    note.content,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                ),
                              // الترجمة العربية
                              if (note.translation.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    note.translation,
                                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // شريط الأدوات بالأسفل (النطق التكراري والنسخ)
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isPlayingThis ? Colors.redAccent : note.type.color,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    ),
                                    icon: Icon(isPlayingThis ? Icons.stop_rounded : Icons.volume_up_rounded, size: 18),
                                    label: Text(
                                      isPlayingThis
                                          ? 'إيقاف ($_currentIteration/$_repeatTarget)'
                                          : 'استماع تكراري',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      if (isPlayingThis) {
                                        _stopAudio();
                                      } else {
                                        _speakLoop(note);
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'نسخ المحتوى',
                                    icon: const Icon(Icons.copy_rounded, size: 20),
                                    onPressed: () async {
                                      final text = '${note.title}\n${note.content}\n${note.translation}'.trim();
                                      await Clipboard.setData(ClipboardData(text: text));
                                      HapticFeedback.lightImpact();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('تم نسخ الملاحظة إلى الحافظة'),
                                            duration: const Duration(seconds: 1),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('ملاحظة سريعة'),
        onPressed: () => _openNoteEditor(),
      ),
    );
  }
}
