import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/gemini_service.dart';
import '../model/node_model.dart';
import '../model/edge_model.dart';

// Gemini 서비스 프로바이더 (지연 로딩)
final geminiServiceProvider = Provider<GeminiService?>((ref) {
  try {
    return GeminiService();
  } catch (e) {
    // API 키가 없을 때는 null 반환
    return null;
  }
});

// AI 생성 상태
enum AIGenerationState { idle, loading, success, error }

// AI 생성 결과를 담는 클래스
class AIGenerationResult {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final String summary;
  final String originalText;
  final AIGenerationState state;
  final String? errorMessage;

  const AIGenerationResult({
    this.nodes = const [],
    this.edges = const [],
    this.summary = '',
    this.originalText = '',
    this.state = AIGenerationState.idle,
    this.errorMessage,
  });

  AIGenerationResult copyWith({
    List<NodeModel>? nodes,
    List<EdgeModel>? edges,
    String? summary,
    String? originalText,
    AIGenerationState? state,
    String? errorMessage,
  }) {
    return AIGenerationResult(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      summary: summary ?? this.summary,
      originalText: originalText ?? this.originalText,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => state == AIGenerationState.loading;
  bool get hasError => state == AIGenerationState.error;
  bool get isSuccess => state == AIGenerationState.success;
  bool get isEmpty => nodes.isEmpty && edges.isEmpty;
}

// AI Provider 클래스
class AIProvider extends StateNotifier<AIGenerationResult> {
  final GeminiService? _geminiService;

  AIProvider(this._geminiService) : super(const AIGenerationResult());

  /// 텍스트에서 개념을 추출하고 그래프 생성
  Future<void> generateConceptGraph(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(
        state: AIGenerationState.error,
        errorMessage: '텍스트를 입력해주세요.',
      );
      return;
    }

    if (_geminiService == null) {
      state = state.copyWith(
        state: AIGenerationState.error,
        errorMessage: 'Gemini API 키가 설정되지 않았습니다.\n환경변수 GEMINI_API_KEY를 설정해주세요.',
      );
      return;
    }

    try {
      // 로딩 상태로 변경
      state = state.copyWith(
        state: AIGenerationState.loading,
        errorMessage: null,
      );

      // Gemini API 호출
      final result = await _geminiService.extractConcepts(text);

      // 성공 상태로 변경
      state = AIGenerationResult(
        nodes: result.nodes,
        edges: result.edges,
        summary: result.summary,
        originalText: result.originalText,
        state: AIGenerationState.success,
      );
    } catch (e) {
      // 에러 상태로 변경
      state = state.copyWith(
        state: AIGenerationState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 노드 위치 업데이트
  void updateNodePosition(String nodeId, double x, double y) {
    final updatedNodes = state.nodes.map((node) {
      if (node.id == nodeId) {
        return node.copyWith(x: x, y: y);
      }
      return node;
    }).toList();

    state = state.copyWith(nodes: updatedNodes);
  }

  /// 노드 제거
  void removeNode(String nodeId) {
    final updatedNodes = state.nodes
        .where((node) => node.id != nodeId)
        .toList();
    final updatedEdges = state.edges
        .where((edge) => edge.from != nodeId && edge.to != nodeId)
        .toList();

    state = state.copyWith(nodes: updatedNodes, edges: updatedEdges);
  }

  /// 엣지 추가
  void addEdge(EdgeModel edge) {
    final updatedEdges = [...state.edges, edge];
    state = state.copyWith(edges: updatedEdges);
  }

  /// 엣지 제거
  void removeEdge(String edgeId) {
    final updatedEdges = state.edges
        .where((edge) => edge.id != edgeId)
        .toList();
    state = state.copyWith(edges: updatedEdges);
  }

  /// 상태 초기화
  void reset() {
    state = const AIGenerationResult();
  }

  /// 에러 클리어
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(state: AIGenerationState.idle, errorMessage: null);
    }
  }
}

// AI Provider 인스턴스
final aiProvider = StateNotifierProvider<AIProvider, AIGenerationResult>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return AIProvider(geminiService);
});

// 편의 프로바이더들
final currentNodesProvider = Provider<List<NodeModel>>((ref) {
  return ref.watch(aiProvider).nodes;
});

final currentEdgesProvider = Provider<List<EdgeModel>>((ref) {
  return ref.watch(aiProvider).edges;
});

final isAILoadingProvider = Provider<bool>((ref) {
  return ref.watch(aiProvider).isLoading;
});

final aiErrorProvider = Provider<String?>((ref) {
  return ref.watch(aiProvider).errorMessage;
});

final aiSummaryProvider = Provider<String>((ref) {
  return ref.watch(aiProvider).summary;
});
