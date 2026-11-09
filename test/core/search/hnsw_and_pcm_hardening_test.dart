import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_bilarabi/src/core/semantic_search/hnsw_vector_indexer.dart';
import 'package:deutsch_bilarabi/src/core/voice/synthesis/streaming_chunked_pcm_synthesis_pipe.dart';

void main() {
  group('PERF-001/002 HNSW Indexer Hardening Tests', () {
    test('strictly rejects invalid vector dimensions', () {
      final indexer = HNSWVectorIndexer(dimension: 4);
      final invalidVector = Float32List.fromList([1.0, 2.0]);
      expect(() => indexer.insert('node_1', invalidVector), throwsArgumentError);
      expect(() => indexer.query(invalidVector), throwsArgumentError);
    });

    test('correctly clusters and queries closest vectors', () {
      final indexer = HNSWVectorIndexer(dimension: 3);
      indexer.insert('doc_a', Float32List.fromList([1.0, 0.0, 0.0]));
      indexer.insert('doc_b', Float32List.fromList([0.0, 1.0, 0.0]));
      indexer.insert('doc_c', Float32List.fromList([0.9, 0.1, 0.0]));

      final results = indexer.query(Float32List.fromList([1.0, 0.0, 0.0]), topK: 2);
      expect(results.first.key, equals('doc_a'));
      expect(results[1].key, equals('doc_c'));
    });
  });

  group('P1-08 Streaming Chunked PCM Pipe Bounds Tests', () {
    test('enforces FIFO dequeue and byte count accuracy', () {
      final pipe = StreamingChunkedPCMSynthesisPipe(maxQueuedBytes: 1024);
      final chunk1 = Uint8List.fromList([1, 2, 3, 4]);
      final chunk2 = Uint8List.fromList([5, 6, 7, 8]);
      pipe.pushChunk(chunk1);
      pipe.pushChunk(chunk2);

      expect(pipe.queuedBytes, equals(8));
      expect(pipe.queuedChunks, equals(2));

      final dequeued1 = pipe.dequeueChunk();
      expect(dequeued1, equals(chunk1));
      expect(pipe.queuedBytes, equals(4));

      final dequeued2 = pipe.dequeueChunk();
      expect(dequeued2, equals(chunk2));
      expect(pipe.queuedBytes, equals(0));
      expect(pipe.isEmpty, isTrue);
    });

    test('fails closed with StateError on buffer overflow', () {
      final pipe = StreamingChunkedPCMSynthesisPipe(maxQueuedBytes: 8);
      pipe.pushChunk(Uint8List.fromList([1, 2, 3, 4]));
      expect(
        () => pipe.pushChunk(Uint8List.fromList([5, 6, 7, 8, 9, 10])),
        throwsStateError,
      );
    });
  });
}
