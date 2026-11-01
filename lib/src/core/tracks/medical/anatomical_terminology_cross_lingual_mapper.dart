class AnatomicalTerminologyCrossLingualMapper {
  final Map<String, Map<String, String>> _anatomy = {
    'heart': {'ar': 'قلب', 'tr': 'kalp', 'id': 'jantung'},
    'lungs': {'ar': 'رئتان', 'tr': 'akciğerler', 'id': 'paru-paru'},
  };
  String? translate(String organ, String targetLang) => _anatomy[organ]?[targetLang];
}
