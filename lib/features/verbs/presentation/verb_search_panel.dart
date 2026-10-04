import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/adaptive_glass_surface.dart';
import '../application/verb_conjugation_engine.dart';
import '../domain/verb_conjugation_models.dart';

class VerbSearchPanel extends StatefulWidget {
  const VerbSearchPanel({
    super.key,
    required this.engine,
    required this.onSelected,
    this.limit = 20,
    this.searchHint = 'Verb suchen…',
  });

  final VerbConjugationEngine engine;
  final ValueChanged<VerbConjugation> onSelected;
  final int limit;
  final String searchHint;

  @override
  State<VerbSearchPanel> createState() => _VerbSearchPanelState();
}

class _VerbSearchPanelState extends State<VerbSearchPanel> {
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;
  List<VerbSearchHit> _hits = const <VerbSearchHit>[];
  bool _loading = false;
  int _generation = 0;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    _debounce?.cancel();
    final query = raw.trim();
    final generation = ++_generation;

    if (query.isEmpty) {
      setState(() {
        _hits = const <VerbSearchHit>[];
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    _debounce = Timer(const Duration(milliseconds: 160), () async {
      try {
        final hits = await widget.engine.search(
          query,
          limit: widget.limit,
        );
        if (!mounted || generation != _generation) return;
        setState(() {
          _hits = hits;
          _loading = false;
        });
      } on Object {
        if (!mounted || generation != _generation) return;
        setState(() {
          _hits = const <VerbSearchHit>[];
          _loading = false;
          _error = 'verb_search_unavailable';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveGlassSurface(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_error != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Search is temporarily unavailable.'),
          ),
        if (_hits.isNotEmpty)
          ListView.separated(
            padding: const EdgeInsets.only(top: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hits.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final hit = _hits[index];
              return ListTile(
                title: Text(hit.verb.infinitive),
                subtitle: Text(hit.verb.meaning),
                trailing: Text(
                  (hit.score * 100).round().toString() + '%',
                ),
                onTap: () => widget.onSelected(hit.verb),
              );
            },
          ),
        ],
      ),
    );
  }
}
