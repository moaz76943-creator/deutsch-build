import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Instruction command in a binary delta patch stream.
enum PatchOpCode { copyFromBase, insertNewBytes }

/// Delta instruction block.
class DeltaInstruction {
  final PatchOpCode op;
  final int offset;
  final int length;
  final Uint8List? data;

  DeltaInstruction.copy({required this.offset, required this.length})
      : op = PatchOpCode.copyFromBase,
        data = null;

  DeltaInstruction.insert({required this.data})
      : op = PatchOpCode.insertNewBytes,
        offset = 0,
        length = data!.length;
}

/// Applies space-efficient byte-level copy/insert delta streams to update offline packs.
/// Verifies target SHA-256 before finalizing to guarantee atomic corruption-free upgrades.
class BinaryDeltaPatchApplier {
  /// Apply delta instructions to base byte array and verify checksum.
  static Uint8List applyPatch({
    required Uint8List baseBytes,
    required List<DeltaInstruction> instructions,
    required String expectedTargetSha256,
  }) {
    final buffer = BytesBuilder(copy: false);

    for (final inst in instructions) {
      if (inst.op == PatchOpCode.copyFromBase) {
        if (inst.offset + inst.length > baseBytes.length) {
          throw RangeError('Patch instruction exceeds base byte bounds: ${inst.offset} + ${inst.length}');
        }
        buffer.add(baseBytes.sublist(inst.offset, inst.offset + inst.length));
      } else if (inst.op == PatchOpCode.insertNewBytes) {
        buffer.add(inst.data!);
      }
    }

    final targetBytes = buffer.toBytes();
    final actualHash = sha256.convert(targetBytes).toString();

    if (actualHash != expectedTargetSha256) {
      throw StateError(
        'Patch checksum verification failed: Expected $expectedTargetSha256 but got $actualHash',
      );
    }

    return targetBytes;
  }
}
