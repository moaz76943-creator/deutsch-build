import 'dart:math';

import 'package:flutter/material.dart';

class BubbleItem {
  final String id;
  final String text;
  final bool isGerman;
  final String matchingId;

  BubbleItem({
    required this.id,
    required this.text,
    required this.isGerman,
    required this.matchingId,
  });
}

class BubbleState {
  final BubbleItem item;
  double x;
  double y;
  double phase;
  bool isMatched;
  bool isSelected;

  BubbleState({
    required this.item,
    required this.x,
    required this.y,
    required this.phase,
    this.isMatched = false,
    this.isSelected = false,
  });
}

class SilentBubblePopper extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchVocabulary;
  final VoidCallback? onComplete;

  const SilentBubblePopper({
    super.key,
    required this.fetchVocabulary,
    this.onComplete,
  });

  @override
  State<SilentBubblePopper> createState() => _SilentBubblePopperState();
}

class _SilentBubblePopperState extends State<SilentBubblePopper>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  List<BubbleState> _bubbles = [];
  BubbleState? _selectedBubble;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    try {
      final entries = await widget.fetchVocabulary();
      List<Map<String, dynamic>> selectedEntries = [];

      if (entries.isEmpty || entries.length < 3) {
        // Fallback
        selectedEntries = [
          {'id': 'f1', 'german_text': 'Apfel', 'arabic_translation': 'تفاحة'},
          {'id': 'f2', 'german_text': 'Buch', 'arabic_translation': 'كتاب'},
          {'id': 'f3', 'german_text': 'Wasser', 'arabic_translation': 'ماء'},
          {'id': 'f4', 'german_text': 'Haus', 'arabic_translation': 'منزل'},
        ];
      } else {
        selectedEntries = List<Map<String, dynamic>>.from(entries)..shuffle();
        selectedEntries = selectedEntries.take(4).toList();
      }

      _generateBubbles(selectedEntries);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback on error
      final selectedEntries = [
        {'id': 'e1', 'german_text': 'Apfel', 'arabic_translation': 'تفاحة'},
        {'id': 'e2', 'german_text': 'Buch', 'arabic_translation': 'كتاب'},
        {'id': 'e3', 'german_text': 'Wasser', 'arabic_translation': 'ماء'},
      ];
      _generateBubbles(selectedEntries);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _generateBubbles(List<Map<String, dynamic>> entries) {
    final random = Random();
    List<BubbleState> newBubbles = [];

    for (var entry in entries) {
      final id = entry['id'] as String;

      newBubbles.add(
        BubbleState(
          item: BubbleItem(
            id: '${id}_de',
            text: entry['german_text'] as String,
            isGerman: true,
            matchingId: '${id}_ar',
          ),
          x: random.nextDouble(),
          y: random.nextDouble(),
          phase: random.nextDouble() * 2 * pi,
        ),
      );

      newBubbles.add(
        BubbleState(
          item: BubbleItem(
            id: '${id}_ar',
            text: entry['arabic_translation'] as String,
            isGerman: false,
            matchingId: '${id}_de',
          ),
          x: random.nextDouble(),
          y: random.nextDouble(),
          phase: random.nextDouble() * 2 * pi,
        ),
      );
    }

    newBubbles.shuffle();
    _bubbles = newBubbles;
  }

  void _handleBubbleTap(BubbleState tapped) {
    if (tapped.isMatched) return;

    setState(() {
      if (_selectedBubble == null) {
        tapped.isSelected = true;
        _selectedBubble = tapped;
      } else {
        if (_selectedBubble == tapped) {
          tapped.isSelected = false;
          _selectedBubble = null;
        } else if (_selectedBubble!.item.matchingId == tapped.item.id) {
          // Match found
          tapped.isMatched = true;
          _selectedBubble!.isMatched = true;
          _selectedBubble!.isSelected = false;
          _selectedBubble = null;

          _checkCompletion();
        } else {
          // Mismatch
          _selectedBubble!.isSelected = false;
          tapped.isSelected = true;
          _selectedBubble = tapped;
        }
      }
    });
  }

  void _checkCompletion() {
    if (_bubbles.every((b) => b.isMatched)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          if (widget.onComplete != null) {
            widget.onComplete!();
          } else {
            Navigator.of(context).pop();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Silent Popper',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w300, letterSpacing: 1.5),
              ),
            ),
            Text(
              'Match the words to pop the bubbles.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Stack(
                        children: _bubbles.where((b) => !b.isMatched).map((
                          bubble,
                        ) {
                          // Calculate position with float
                          final floatOffset = sin(
                                bubble.phase + _floatController.value * 2 * pi,
                              ) *
                              20;
                          final xPos = bubble.x * (constraints.maxWidth - 100);
                          final yPos =
                              bubble.y * (constraints.maxHeight - 100) +
                                  floatOffset;

                          return Positioned(
                            left: xPos.clamp(0.0, constraints.maxWidth - 100),
                            top: yPos.clamp(0.0, constraints.maxHeight - 100),
                            child: GestureDetector(
                              onTap: () => _handleBubbleTap(bubble),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bubble.isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.8),
                                  border: Border.all(
                                    color: bubble.isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.3),
                                    width: bubble.isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .shadow
                                          .withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Directionality(
                                      textDirection: bubble.item.isGerman
                                          ? TextDirection.ltr
                                          : TextDirection.rtl,
                                      child: Text(
                                        bubble.item.text,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: bubble.isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                          fontWeight: bubble.isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () {
                  if (widget.onComplete != null) {
                    widget.onComplete!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Skip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
