import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/srs/review_command_port.dart';
import 'flashcard_widget.dart';

/// The persistent session owner provides one globally unique, stable event ID
/// per review attempt. Never synthesize review IDs from timestamps in the UI.
class FlashcardReviewItem {
  final LexicalEntry entry;
  final String reviewEventId;
  final String semanticVersion;
  final int pairEpoch;
  final String facetKey;

  const FlashcardReviewItem({
    required this.entry,
    required this.reviewEventId,
    required this.semanticVersion,
    required this.pairEpoch,
    this.facetKey = 'lexeme',
  });

  bool get isValid =>
      entry.id.trim().isNotEmpty &&
      entry.sourceLocale.trim().isNotEmpty &&
      entry.targetLocale.trim().isNotEmpty &&
      entry.sourceLocale != entry.targetLocale &&
      reviewEventId.trim().isNotEmpty &&
      semanticVersion.trim().isNotEmpty &&
      pairEpoch >= 0 &&
      facetKey.trim().isNotEmpty;

  ReviewCommand command(ReviewRating rating) => ReviewCommand(
        reviewId: reviewEventId,
        sourceLanguageId: entry.sourceLocale,
        targetLanguageId: entry.targetLocale,
        semanticVersion: semanticVersion,
        cardId: entry.id,
        facetKey: facetKey,
        pairEpoch: pairEpoch,
        rating: rating,
        hinted: false,
      );
}

/// UI advances only after a durable ReviewCommandPort acknowledges the write.
/// If a process dies after DB commit but before UI advance, the owning session
/// must replay the SAME event ID, and the SQLite port deduplicates it.
class FlashcardSessionWidget extends StatefulWidget {
  final List<FlashcardReviewItem> items;
  final ReviewCommandPort reviewPort;

  const FlashcardSessionWidget({
    super.key,
    required this.items,
    required this.reviewPort,
  });

  @override
  State<FlashcardSessionWidget> createState() => _FlashcardSessionState();
}

class _FlashcardSessionState extends State<FlashcardSessionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flip;
  late List<FlashcardReviewItem> _queue;
  bool _flipped = false;
  bool _busy = false;
  String? _error;
  ReviewRating? _attemptedRating;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _queue = List<FlashcardReviewItem>.of(widget.items);
    _flip = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
  }

  @override
  void didUpdateWidget(covariant FlashcardSessionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items) ||
        !identical(oldWidget.reviewPort, widget.reviewPort)) {
      _generation++;
      _queue = List<FlashcardReviewItem>.of(widget.items);
      _busy = false;
      _flipped = false;
      _error = null;
      _attemptedRating = null;
      _flip.reset();
    }
  }

  @override
  void dispose() {
    _generation++;
    _flip.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_busy || _queue.isEmpty) return;
    setState(() {
      _flipped = !_flipped;
      if (_flipped) {
        _flip.forward();
      } else {
        _flip.reverse();
      }
    });
  }

  void _skip() {
    if (_busy || _queue.length < 2) return;
    setState(() {
      _queue.add(_queue.removeAt(0));
      _flipped = false;
      _error = null;
      _attemptedRating = null;
      _flip.reset();
    });
  }

  Future<void> _grade(ReviewRating rating) async {
    if (_busy || !_flipped || _queue.isEmpty) return;
    final item = _queue.first;
    if (!item.isValid) {
      setState(() => _error = 'بيانات البطاقة غير مكتملة');
      return;
    }

    if (_attemptedRating != null && _attemptedRating != rating) {
      setState(() => _error = 'لإعادة المحاولة اختر نفس التقييم');
      return;
    }
    final generation = _generation;
    setState(() {
      _attemptedRating = rating;
      _busy = true;
      _error = null;
    });

    try {
      await widget.reviewPort.submit(item.command(rating));
      if (!mounted || generation != _generation) return;
      _flip.reset();
      setState(() {
        _queue.removeAt(0);
        _flipped = false;
        _attemptedRating = null;
      });
      // "Hard" does not requeue the SAME event ID. A subsequent attempt
      // requires a distinct persistent event ID from the session owner.
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _error = 'تعذر حفظ المراجعة. حاول مجددًا.');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return const Center(child: Text('Session Complete!'));
    }
    final item = _queue.first;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Cards left: ${_queue.length}',
              textDirection: TextDirection.ltr),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FlashcardWidget(
            entry: item.entry,
            animation: _flip,
            onFlip: _busy ? null : _toggleFlip,
          ),
        )),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_error!,
                key: const Key('review-error'), textAlign: TextAlign.center),
          ),
        if (_flipped)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: _busy ||
                            (_attemptedRating != null &&
                                _attemptedRating != ReviewRating.hard)
                        ? null
                        : () => _grade(ReviewRating.hard),
                    child: const Text('Hard')),
                ElevatedButton(
                    onPressed: _busy ||
                            (_attemptedRating != null &&
                                _attemptedRating != ReviewRating.good)
                        ? null
                        : () => _grade(ReviewRating.good),
                    child: const Text('Good')),
                ElevatedButton(
                    onPressed: _busy ||
                            (_attemptedRating != null &&
                                _attemptedRating != ReviewRating.easy)
                        ? null
                        : () => _grade(ReviewRating.easy),
                    child: const Text('Easy')),
              ],
            ),
          )
        else
          TextButton(
              onPressed: _busy ? null : _skip, child: const Text('Skip')),
      ],
    );
  }
}
