class DictionaryItem {
  final String id;
  final String germanWord;
  final String arabicMeaning;
  final String category;

  const DictionaryItem({
    required this.id,
    required this.germanWord,
    required this.arabicMeaning,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'germanWord': germanWord,
        'arabicMeaning': arabicMeaning,
        'category': category,
      };
}
