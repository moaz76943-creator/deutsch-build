/// Sovereign UI Master Router - Direct High-Speed Navigation
class SovereignUiMasterRouter {
  static const String initialRoute = '/immersion';
  static final Map<String, String> routes = {
    '/immersion': 'ImmersionCanvasView',
    '/dialogue': 'RealLifeDialogueSimulator',
    '/grammar': 'InteractiveSentenceBuilder',
    '/srs': 'FsrsAdaptiveScheduler',
    '/lexicon': 'OfflineDictionaryViewer'
  };

  static bool isRouteActive(String route) => routes.containsKey(route);
}
