import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuditChainBlock {
  final int index;
  final String timestampIso;
  final String eventType;
  final String payloadJson;
  final String previousHash;
  final String blockHash;

  const AuditChainBlock({
    required this.index,
    required this.timestampIso,
    required this.eventType,
    required this.payloadJson,
    required this.previousHash,
    required this.blockHash,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'timestampIso': timestampIso,
    'eventType': eventType,
    'payloadJson': payloadJson,
    'previousHash': previousHash,
    'blockHash': blockHash,
  };

  factory AuditChainBlock.fromJson(Map<String, dynamic> json) => AuditChainBlock(
    index: json['index'] as int,
    timestampIso: json['timestampIso'] as String,
    eventType: json['eventType'] as String,
    payloadJson: json['payloadJson'] as String,
    previousHash: json['previousHash'] as String,
    blockHash: json['blockHash'] as String,
  );
}

class AuditChainVerificationResult {
  final bool isValid;
  final int? brokenAtIndex;
  final String message;

  const AuditChainVerificationResult({
    required this.isValid,
    this.brokenAtIndex,
    required this.message,
  });
}

/// سجل تدقيق وبصمة تسلسلية مشفرة لضمان نزاهة إنجازات ومراجعات التعلم (Study 66)
/// يربط كل حدث تدريبي أو إنجاز بهاش SHA-256 مشتق من الحدث السابق، مما يمنع التلاعب بأثر رجعي
class CryptoAuditChain {
  static const String genesisHash = '0000000000000000000000000000000000000000000000000000000000000000';

  final List<AuditChainBlock> _blocks = [];

  List<AuditChainBlock> get blocks => List.unmodifiable(_blocks);

  int get length => _blocks.length;

  /// إضافة حدث تدقيق جديد للسلسلة
  AuditChainBlock appendEvent({
    required String eventType,
    required Map<String, dynamic> payload,
    DateTime? timestamp,
  }) {
    final index = _blocks.length;
    final timestampIso = (timestamp ?? DateTime.now()).toUtc().toIso8601String();
    final payloadJson = jsonEncode(payload);
    final previousHash = _blocks.isEmpty ? genesisHash : _blocks.last.blockHash;

    final blockHash = computeBlockHash(
      index: index,
      timestampIso: timestampIso,
      eventType: eventType,
      payloadJson: payloadJson,
      previousHash: previousHash,
    );

    final block = AuditChainBlock(
      index: index,
      timestampIso: timestampIso,
      eventType: eventType,
      payloadJson: payloadJson,
      previousHash: previousHash,
      blockHash: blockHash,
    );

    _blocks.add(block);
    return block;
  }

  /// حساب هاش الكتلة المحدد
  static String computeBlockHash({
    required int index,
    required String timestampIso,
    required String eventType,
    required String payloadJson,
    required String previousHash,
  }) {
    final raw = '$index:$timestampIso:$eventType:$payloadJson:$previousHash';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// التحقق التام من سلامة السلسلة وعدم التلاعب بأي معاملة سابقة
  static AuditChainVerificationResult verifyChain(List<AuditChainBlock> chain) {
    if (chain.isEmpty) {
      return const AuditChainVerificationResult(
        isValid: true,
        message: 'السلسلة فارغة وسليمة.',
      );
    }

    String expectedPrevHash = genesisHash;

    for (var i = 0; i < chain.length; i++) {
      final block = chain[i];

      // 1. التحقق من تسلسل الفهرس
      if (block.index != i) {
        return AuditChainVerificationResult(
          isValid: false,
          brokenAtIndex: i,
          message: 'خطأ في تسلسل الفهرس عند الكتلة $i: المتوقع $i ووجد ${block.index}',
        );
      }

      // 2. التحقق من تطابق رابط الهاش السابق
      if (block.previousHash != expectedPrevHash) {
        return AuditChainVerificationResult(
          isValid: false,
          brokenAtIndex: i,
          message: 'انقطاع رابط الهاش التسلسلي عند الكتلة $i.',
        );
      }

      // 3. إعادة حساب هاش الكتلة للتحقق من عدم تعديل البيانات
      final recalculated = computeBlockHash(
        index: block.index,
        timestampIso: block.timestampIso,
        eventType: block.eventType,
        payloadJson: block.payloadJson,
        previousHash: block.previousHash,
      );

      if (block.blockHash != recalculated) {
        return AuditChainVerificationResult(
          isValid: false,
          brokenAtIndex: i,
          message: 'تلاعب في بيانات الكتلة $i: الهاش المحسوب لا يطابق المسجل.',
        );
      }

      expectedPrevHash = block.blockHash;
    }

    return const AuditChainVerificationResult(
      isValid: true,
      message: 'سلسلة التدقيق سليمة 100% وموثقة تشفيرياً.',
    );
  }
}
