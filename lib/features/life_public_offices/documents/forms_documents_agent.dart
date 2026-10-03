import 'package:flutter/foundation.dart';

import 'documents_models.dart';
import 'forms_documents_phrase_bank.dart';

final class FormsDocumentsAgent extends ChangeNotifier {
  DocumentsTopic _topic = DocumentsTopic.all;
  String _query = '';

  DocumentsTopic get topic => _topic;
  String get query => _query;

  List<DocumentsPhrase> get allPhrases =>
      List<DocumentsPhrase>.unmodifiable(FormsDocumentsPhraseBank.all);

  List<DocumentsPhrase> get visiblePhrases {
    return List<DocumentsPhrase>.unmodifiable(
      FormsDocumentsPhraseBank.all.where((phrase) {
        final topicMatches =
            _topic == DocumentsTopic.all || phrase.topic == _topic;
        return topicMatches && phrase.matches(_query);
      }),
    );
  }

  String get officialNoteDe =>
      'Form, Beglaubigung, Vollmacht und Nachreichfrist können je nach Behörde und Verfahren unterschiedlich sein. Anforderungen immer bei der zuständigen Stelle bestätigen.';

  String get officialNoteAr =>
      'قد تختلف صيغة التصديق والوكالة ومهلة استكمال المستندات حسب الدائرة ونوع الإجراء. أكّد المتطلبات دائمًا لدى الجهة المختصة.';

  void setTopic(DocumentsTopic value) {
    if (_topic == value) return;
    _topic = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_topic == DocumentsTopic.all && _query.isEmpty) return;
    _topic = DocumentsTopic.all;
    _query = '';
    notifyListeners();
  }
}
