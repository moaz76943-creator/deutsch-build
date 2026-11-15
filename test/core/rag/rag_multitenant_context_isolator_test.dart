import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/rag/rag_multitenant_context_isolator.dart';

void main() {
  group('RagMultiTenantContextIsolator Suite', () {
    final isolator = RagMultiTenantContextIsolator();

    setUpAll(() {
      // 1. Shared public system record
      isolator.insertRecord(const TenantVectorRecord(
        recordId: 'shared_01',
        tenantId: 'SYSTEM',
        scope: CorpusScope.sharedSystemPublic,
        vector: [1.0, 0.0, 0.0, 0.0],
        text: 'قاعدة الفعل والفاعل العامة',
      ));

      // 2. Private record for Tenant A (Zaid)
      isolator.insertRecord(const TenantVectorRecord(
        recordId: 'priv_zaid_01',
        tenantId: 'user_zaid',
        scope: CorpusScope.learnerPrivateEncrypted,
        vector: [0.95, 0.05, 0.0, 0.0],
        text: 'ملاحظة خاصة بزيد: أخطأت في إعراب المفعول به',
      ));

      // 3. Private record for Tenant B (Fatima)
      isolator.insertRecord(const TenantVectorRecord(
        recordId: 'priv_fatima_01',
        tenantId: 'user_fatima',
        scope: CorpusScope.learnerPrivateEncrypted,
        vector: [0.98, 0.02, 0.0, 0.0],
        text: 'ملاحظة خاصة بفاطمة: مراجعة كان وأخواتها',
      ));
    });

    test('Query by Tenant A sees shared records and A private records, never B', () {
      final results = isolator.query(
        activeTenantId: 'user_zaid',
        queryVector: [1.0, 0.0, 0.0, 0.0],
      );

      final returnedIds = results.map((r) => r.record.recordId).toList();
      expect(returnedIds, contains('shared_01'));
      expect(returnedIds, contains('priv_zaid_01'));
      expect(returnedIds, isNot(contains('priv_fatima_01')));
    });

    test('Query by Tenant B sees shared records and B private records, never A', () {
      final results = isolator.query(
        activeTenantId: 'user_fatima',
        queryVector: [1.0, 0.0, 0.0, 0.0],
      );

      final returnedIds = results.map((r) => r.record.recordId).toList();
      expect(returnedIds, contains('shared_01'));
      expect(returnedIds, contains('priv_fatima_01'));
      expect(returnedIds, isNot(contains('priv_zaid_01')));
    });
  });
}
