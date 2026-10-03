import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/search_models.dart';
import '../domain/search_repositories.dart';

final class SearchState {
  const SearchState({
    this.query = const SearchQuery(),
    this.results = const <SearchResultItem>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final SearchQuery query;
  final List<SearchResultItem> results;
  final bool isLoading;
  final String? errorMessage;
}

class SearchController extends ChangeNotifier {
  SearchController({
    required SearchRepository repository,
    this.debounceDuration = const Duration(milliseconds: 260),
  }) : _repository = repository;

  final SearchRepository _repository;
  final Duration debounceDuration;

  Timer? _debounce;
  int _requestEpoch = 0;
  SearchState _state = const SearchState();

  SearchState get state => _state;

  void updateText(String text) {
    final epoch = ++_requestEpoch;
    _setState(
      SearchState(
        query: _state.query.copyWith(text: text),
        results: _state.results,
        isLoading: true,
      ),
    );
    _schedule(epoch);
  }

  void toggleFilter(SearchFilter filter) {
    final next = <SearchFilter>{..._state.query.filters};
    if (!next.add(filter)) next.remove(filter);
    final epoch = ++_requestEpoch;
    _setState(
      SearchState(
        query: _state.query.copyWith(
          filters: Set<SearchFilter>.unmodifiable(next),
        ),
        results: _state.results,
        isLoading: true,
      ),
    );
    _schedule(epoch, immediate: true);
  }

  Future<void> refresh() {
    final epoch = ++_requestEpoch;
    return _execute(epoch);
  }

  void _schedule(int epoch, {bool immediate = false}) {
    _debounce?.cancel();
    if (immediate || debounceDuration == Duration.zero) {
      unawaited(_execute(epoch));
      return;
    }
    _debounce = Timer(debounceDuration, () => unawaited(_execute(epoch)));
  }

  Future<void> _execute(int epoch) async {
    _debounce?.cancel();
    final query = _state.query;
    _setState(
      SearchState(
        query: query,
        results: _state.results,
        isLoading: true,
      ),
    );

    try {
      final results = await _repository.search(query);
      if (epoch != _requestEpoch) return;
      _setState(
        SearchState(
          query: query,
          results: results,
        ),
      );
    } catch (error) {
      if (epoch != _requestEpoch) return;
      _setState(
        SearchState(
          query: query,
          results: _state.results,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _setState(SearchState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _requestEpoch += 1;
    super.dispose();
  }
}
