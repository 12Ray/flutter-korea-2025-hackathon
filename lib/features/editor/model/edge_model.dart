import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'edge_model.g.dart';

@HiveType(typeId: 1)
class EdgeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String from; // 시작 노드 ID

  @HiveField(2)
  final String to; // 끝 노드 ID

  @HiveField(3)
  final double weight; // 관계 강도 0.0 ~ 1.0

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? description; // 관계 설명 (선택사항)

  EdgeModel({
    required this.id,
    required this.from,
    required this.to,
    required this.weight,
    DateTime? createdAt,
    this.description,
  }) : createdAt = createdAt ?? DateTime.now();

  // 가중치에 따른 선 굵기 계산
  double get strokeWidth {
    return 1.0 + (weight * 5.0).clamp(0.0, 6.0);
  }

  // 가중치에 따른 색상 투명도
  Color get edgeColor {
    final opacity = (0.3 + weight * 0.7).clamp(0.0, 1.0);
    return Colors.grey.withValues(alpha: opacity);
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory EdgeModel.fromJson(Map<String, dynamic> json) {
    return EdgeModel(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      weight: json['weight']?.toDouble() ?? 0.5,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      description: json['description'],
    );
  }

  // 복사본 생성
  EdgeModel copyWith({
    String? id,
    String? from,
    String? to,
    double? weight,
    DateTime? createdAt,
    String? description,
  }) {
    return EdgeModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'EdgeModel(id: $id, from: $from, to: $to, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EdgeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
