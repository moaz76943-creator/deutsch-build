class HospitalWayfindingSignageMapper {
  final Map<String, String> _signs = {'radiology': 'قسم الأشعة', 'emergency': 'طوارئ', 'pharmacy': 'صيدلية'};
  String getSign(String key) => _signs[key] ?? key;
}
