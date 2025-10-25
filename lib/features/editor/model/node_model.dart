import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'node_model.g.dart';

@HiveType(typeId: 0)
class NodeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;

  @HiveField(2)
  double x;

  @HiveField(3)
  double y;

  @HiveField(4)
  final String emotion; // positive, neutral, negative

  @HiveField(5)
  final int freq; // 등장 횟수

  @HiveField(6)
  final DateTime createdAt;

  NodeModel({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.emotion,
    required this.freq,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 감정에 따른 색상 반환
  Color get emotionColor {
    switch (emotion.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
      default:
        return Colors.blue;
    }
  }

  // 빈도에 따른 노드 크기 계산
  double get nodeRadius {
    return 20.0 + (freq * 2.0).clamp(0.0, 20.0);
  }

  // 위치 업데이트
  void updatePosition(double newX, double newY) {
    x = newX;
    y = newY;
    save(); // Hive 자동 저장
  }

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'x': x,
      'y': y,
      'emotion': emotion,
      'freq': freq,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'],
      label: json['label'],
      x: json['x']?.toDouble() ?? 0.0,
      y: json['y']?.toDouble() ?? 0.0,
      emotion: json['emotion'] ?? 'neutral',
      freq: json['freq'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // 복사본 생성
  NodeModel copyWith({
    String? id,
    String? label,
    double? x,
    double? y,
    String? emotion,
    int? freq,
    DateTime? createdAt,
  }) {
    return NodeModel(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      emotion: emotion ?? this.emotion,
      freq: freq ?? this.freq,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NodeModel(id: $id, label: $label, emotion: $emotion, freq: $freq)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
