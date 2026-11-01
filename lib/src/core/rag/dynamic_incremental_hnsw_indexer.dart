import 'dart:math' as math;
import 'package:collection/collection.dart';

enum HnswDistanceMetric { cosine, euclidean }

class HnswNode {
  final int id;
  final List<double> vector;
  final int maxLayer;
  final String label;
  final List<List<int>> friends;
  bool isDeleted;

  HnswNode({required this.id, required this.vector, required this.maxLayer, required this.label, this.isDeleted = false})
      : friends = List.generate(maxLayer + 1, (_) => <int>[]);
}

class HnswCandidate {
  final int nodeId;
  final double distance;
  const HnswCandidate({required this.nodeId, required this.distance});
}

class DynamicIncrementalHnswIndexer {
  final int dimension;
  final int m;
  final int m0;
  final Map<int, HnswNode> _nodes = {};
  int? _entryPointId;
  int _maxLayer = 0;

  DynamicIncrementalHnswIndexer({required this.dimension, this.m = 16, int? m0}) : m0 = m0 ?? (m * 2);

  int get nodeCount => _nodes.values.where((n) => !n.isDeleted).length;

  double distance(List<double> v1, List<double> v2) {
    double dot = 0.0, n1 = 0.0, n2 = 0.0;
    for (int i = 0; i < dimension; i++) {
      dot += v1[i] * v2[i]; n1 += v1[i] * v1[i]; n2 += v2[i] * v2[i];
    }
    if (n1 == 0.0 || n2 == 0.0) return 1.0;
    return 1.0 - (dot / (math.sqrt(n1) * math.sqrt(n2))).clamp(-1.0, 1.0);
  }

  void insert({required int id, required List<double> vector, required String label}) {
    final newNode = HnswNode(id: id, vector: List.from(vector), maxLayer: 0, label: label);
    if (_entryPointId == null) {
      _entryPointId = id;
      _nodes[id] = newNode;
      return;
    }
    _nodes[id] = newNode;
    _nodes[_entryPointId!]?.friends[0].add(id);
    newNode.friends[0].add(_entryPointId!);
  }

  List<HnswCandidate> searchKNN({required List<double> query, required int k}) {
    final list = _nodes.values.where((n) => !n.isDeleted).map((n) {
      return HnswCandidate(nodeId: n.id, distance: distance(query, n.vector));
    }).toList();
    list.sort((a, b) => a.distance.compareTo(b.distance));
    return list.take(k).toList();
  }
}
