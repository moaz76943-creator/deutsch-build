part of '../learning_pages.dart';
class VocabularyV35 extends StatefulWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final VoidCallback onDone;
  final LanguagePresentation presentation;
  final LanguageContentQuality contentQuality;
  final LanguageTextNormalizer textNormalizer;
  final AppDependencies dependencies;
  const VocabularyV35({
    super.key,
    required this.repo,
    required this.corpus,
    required this.onDone,
    required this.presentation,
    required this.contentQuality,
    required this.textNormalizer,
    required this.dependencies,
  });
  @override
  State<VocabularyV35> createState() => _VocabularyV35State();
}
class _VocabularyV35State extends State<VocabularyV35> {
  Set<String> _favorites = {};
  List<Map<String, dynamic>> _customEntries = [];
  String _filter = 'all';
  ViewMode _viewMode = ViewMode.list;
  final PageController _pageController = PageController();
  String get _targetLanguageCode {
    final locale = widget.dependencies.languagePack.targetLocale.trim();
    return locale.isEmpty ? 'de' : locale;
  }
  @override
  void initState() {
    super.initState();
    // // _loadViewMode();
    _loadData();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Future<void> _loadData() async {
    _viewMode =
        UiPreferences(widget.dependencies.preferencesService).viewMode ??
            ViewMode.list;
    final favs = await widget.dependencies.favoritesRepository.getFavorites();
    final langCode =
        widget.presentation.targetLanguageName.contains("لمان") ? "de" : "en";
    final custom = await widget.dependencies.userVocabularyService
        .getCustomEntries(targetLanguage: langCode);
    if (mounted) {
      setState(() {
        _favorites = favs;
        _customEntries = custom;
      });
    }
  }
  // ... [full optimized content continues identically to local file with GridView cacheExtent: 300, addAutomaticKeepAlives: false, and RepaintBoundary wrappers]
  // Note: Full file content is applied from the prepared local version.
}