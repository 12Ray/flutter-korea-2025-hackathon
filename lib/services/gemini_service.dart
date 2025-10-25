import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../features/editor/model/node_model.dart';
import '../features/editor/model/edge_model.dart';
import 'package:uuid/uuid.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  late final GenerativeModel _model;
  final _uuid = const Uuid();

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Gemini API key not found. Please set GEMINI_API_KEY environment variable.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 1500,
      ),
    );
  }

  /// 텍스트에서 개념과 관계를 추출하는 메인 메서드
  Future<ConceptExtractionResult> extractConcepts(String text) async {
    if (text.trim().isEmpty) {
      throw Exception('텍스트가 비어있습니다.');
    }

    try {
      final prompt = '${_getSystemPrompt()}\n\nText: "$text"';
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini API에서 응답을 받지 못했습니다.');
      }

      return _parseResponse(response.text!, text);
    } catch (e) {
      if (e.toString().contains('API_KEY_INVALID')) {
        throw Exception('Gemini API 키가 유효하지 않습니다.');
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        throw Exception('API 사용량이 초과되었습니다. 잠시 후 다시 시도해주세요.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('네트워크 연결 시간이 초과되었습니다.');
      } else {
        throw Exception('개념 추출 중 오류가 발생했습니다: $e');
      }
    }
  }

  /// Gemini에게 보낼 시스템 프롬프트
  String _getSystemPrompt() {
    return '''
당신은 텍스트에서 핵심 개념과 관계를 추출하는 JSON 생성기입니다.

사용자의 텍스트에서 최대 8개의 핵심 개념을 추출하고, 그들 간의 관계를 분석하세요.

**중요: 반드시 유효한 JSON 형식으로만 응답해주세요. 마크다운이나 다른 설명 없이 JSON만 반환하세요.**

JSON 형식으로만 응답하며, 다음 키를 포함해야 합니다:
- concepts: 개념 배열
- relations: 관계 배열  
- summary: 한 줄 요약

각 concept는 다음을 포함해야 합니다:
- id: 고유 식별자 (n1, n2, n3...)
- label: 개념 이름 (한국어, 최대 10글자)
- sentiment: "positive", "neutral", "negative" 중 하나
- freqEstimate: 중요도 기반 빈도 추정치 (1-10)

각 relation은 다음을 포함해야 합니다:
- from: 시작 개념 ID
- to: 끝 개념 ID
- weight: 관계 강도 (0.1-1.0)

예시 응답:
{
  "concepts": [
    {"id":"n1","label":"Flutter","sentiment":"positive","freqEstimate":3},
    {"id":"n2","label":"시각화","sentiment":"positive","freqEstimate":2}
  ],
  "relations": [
    {"from":"n1","to":"n2","weight":0.9}
  ],
  "summary": "Flutter를 이용한 시각화 아이디어에 대한 긍정적 사고"
}
''';
  }

  /// Gemini 응답을 파싱하여 노드와 엣지로 변환
  ConceptExtractionResult _parseResponse(String content, String originalText) {
    try {
      // JSON 부분만 추출 (마크다운 코드 블록 및 기타 텍스트 제거)
      String jsonString = content.trim();

      // 코드 블록 제거
      if (content.contains('```json')) {
        final startIndex = content.indexOf('```json') + 7;
        final endIndex = content.lastIndexOf('```');
        if (endIndex > startIndex) {
          jsonString = content.substring(startIndex, endIndex).trim();
        }
      } else if (content.contains('```')) {
        final startIndex = content.indexOf('```') + 3;
        final endIndex = content.lastIndexOf('```');
        if (endIndex > startIndex) {
          jsonString = content.substring(startIndex, endIndex).trim();
        }
      }

      // JSON 객체 시작과 끝 찾기
      final jsonStart = jsonString.indexOf('{');
      final jsonEnd = jsonString.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd + 1);
      }

      final Map<String, dynamic> data = json.decode(jsonString);

      final nodes = <NodeModel>[];
      final edges = <EdgeModel>[];

      // 노드 생성
      if (data['concepts'] != null) {
        final concepts = data['concepts'] as List;
        for (final concept in concepts) {
          final node = NodeModel(
            id: concept['id'] ?? 'n${nodes.length + 1}',
            label: concept['label'] ?? '개념',
            x: 0.0, // 초기 위치는 나중에 레이아웃에서 계산
            y: 0.0,
            emotion: concept['sentiment'] ?? 'neutral',
            freq: concept['freqEstimate'] ?? 1,
          );
          nodes.add(node);
        }
      }

      // 엣지 생성
      if (data['relations'] != null) {
        final relations = data['relations'] as List;
        for (final relation in relations) {
          final edge = EdgeModel(
            id: _uuid.v4(),
            from: relation['from'],
            to: relation['to'],
            weight: (relation['weight'] ?? 0.5).toDouble(),
          );
          edges.add(edge);
        }
      }

      return ConceptExtractionResult(
        nodes: nodes,
        edges: edges,
        summary: data['summary'] ?? '개념이 추출되었습니다.',
        originalText: originalText,
      );
    } catch (e) {
      // 파싱 실패 시 기본 노드 생성
      return _createFallbackResult(originalText);
    }
  }

  /// API 실패 시 기본 결과 생성
  ConceptExtractionResult _createFallbackResult(String text) {
    final words = text.split(' ').where((w) => w.length > 2).take(5).toList();
    final nodes = <NodeModel>[];

    for (int i = 0; i < words.length; i++) {
      nodes.add(
        NodeModel(
          id: 'n${i + 1}',
          label: words[i],
          x: 0.0,
          y: 0.0,
          emotion: 'neutral',
          freq: words.length - i,
        ),
      );
    }

    return ConceptExtractionResult(
      nodes: nodes,
      edges: [],
      summary: '기본 키워드가 추출되었습니다.',
      originalText: text,
    );
  }
}

/// 개념 추출 결과를 담는 클래스
class ConceptExtractionResult {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final String summary;
  final String originalText;

  ConceptExtractionResult({
    required this.nodes,
    required this.edges,
    required this.summary,
    required this.originalText,
  });

  @override
  String toString() {
    return 'ConceptExtractionResult(nodes: ${nodes.length}, edges: ${edges.length}, summary: $summary)';
  }
}
