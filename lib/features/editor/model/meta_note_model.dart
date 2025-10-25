import 'package:hive/hive.dart';
import 'node_model.dart';
import 'edge_model.dart';

part 'meta_note_model.g.dart';

@HiveType(typeId: 2)
class MetaNoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<NodeModel> nodes;

  @HiveField(3)
  final List<EdgeModel> edges;

  @HiveField(4)
  final String rawText;

  @HiveField(5)
  final String? summary;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  MetaNoteModel({
    required this.id,
    required this.date,
    required this.nodes,
    required this.edges,
    required this.rawText,
    this.summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'edges': edges.map((edge) => edge.toJson()).toList(),
      'rawText': rawText,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MetaNoteModel.fromJson(Map<String, dynamic> json) {
    return MetaNoteModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      nodes: (json['nodes'] as List)
          .map((nodeJson) => NodeModel.fromJson(nodeJson))
          .toList(),
      edges: (json['edges'] as List)
          .map((edgeJson) => EdgeModel.fromJson(edgeJson))
          .toList(),
      rawText: json['rawText'],
      summary: json['summary'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // 통계 계산
  Map<String, int> get emotionCounts {
    final counts = <String, int>{};
    for (final node in nodes) {
      counts[node.emotion] = (counts[node.emotion] ?? 0) + 1;
    }
    return counts;
  }

  // 가장 빈번한 키워드들
  List<NodeModel> get topKeywords {
    final sortedNodes = List<NodeModel>.from(nodes);
    sortedNodes.sort((a, b) => b.freq.compareTo(a.freq));
    return sortedNodes.take(5).toList();
  }

  // 총 연결 수
  int get totalConnections => edges.length;

  // 복사본 생성
  MetaNoteModel copyWith({
    String? id,
    DateTime? date,
    List<NodeModel>? nodes,
    List<EdgeModel>? edges,
    String? rawText,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MetaNoteModel(
      id: id ?? this.id,
      date: date ?? this.date,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      rawText: rawText ?? this.rawText,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MetaNoteModel(id: $id, date: $date, nodes: ${nodes.length}, edges: ${edges.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MetaNoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
