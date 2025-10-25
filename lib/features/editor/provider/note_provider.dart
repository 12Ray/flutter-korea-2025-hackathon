import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../model/meta_note_model.dart';
import '../model/node_model.dart';
import '../model/edge_model.dart';

// UUID 생성기 프로바이더
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// Hive Box 프로바이더
final metaNoteBoxProvider = Provider<Box<MetaNoteModel>>((ref) {
  return Hive.box<MetaNoteModel>('metanotes');
});

// Note Provider 클래스
class NoteProvider extends StateNotifier<AsyncValue<List<MetaNoteModel>>> {
  final Box<MetaNoteModel> _box;
  final Uuid _uuid;

  NoteProvider(this._box, this._uuid) : super(const AsyncValue.loading()) {
    _loadNotes();
  }

  /// 모든 노트 로드
  void _loadNotes() {
    try {
      final notes = _box.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = AsyncValue.data(notes);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 새 노트 저장
  Future<void> saveNote({
    required List<NodeModel> nodes,
    required List<EdgeModel> edges,
    required String rawText,
    String? summary,
  }) async {
    try {
      final note = MetaNoteModel(
        id: _uuid.v4(),
        date: DateTime.now(),
        nodes: nodes,
        edges: edges,
        rawText: rawText,
        summary: summary,
      );

      await _box.put(note.id, note);
      _loadNotes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 노트 업데이트
  Future<void> updateNote(
    String noteId, {
    List<NodeModel>? nodes,
    List<EdgeModel>? edges,
    String? rawText,
    String? summary,
  }) async {
    try {
      final existingNote = _box.get(noteId);
      if (existingNote == null) {
        throw Exception('노트를 찾을 수 없습니다.');
      }

      final updatedNote = existingNote.copyWith(
        nodes: nodes ?? existingNote.nodes,
        edges: edges ?? existingNote.edges,
        rawText: rawText ?? existingNote.rawText,
        summary: summary ?? existingNote.summary,
        updatedAt: DateTime.now(),
      );

      await _box.put(noteId, updatedNote);
      _loadNotes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 노트 삭제
  Future<void> deleteNote(String noteId) async {
    try {
      await _box.delete(noteId);
      _loadNotes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 특정 날짜의 노트들 가져오기
  List<MetaNoteModel> getNotesForDate(DateTime date) {
    return state.value?.where((note) {
          return note.date.year == date.year &&
              note.date.month == date.month &&
              note.date.day == date.day;
        }).toList() ??
        [];
  }

  /// 검색
  List<MetaNoteModel> searchNotes(String query) {
    if (query.trim().isEmpty) return state.value ?? [];

    final lowerQuery = query.toLowerCase();
    return state.value?.where((note) {
          return note.rawText.toLowerCase().contains(lowerQuery) ||
              note.summary?.toLowerCase().contains(lowerQuery) == true ||
              note.nodes.any(
                (node) => node.label.toLowerCase().contains(lowerQuery),
              );
        }).toList() ??
        [];
  }

  /// 통계 데이터 생성
  NoteStatistics getStatistics() {
    final notes = state.value ?? [];
    if (notes.isEmpty) {
      return const NoteStatistics();
    }

    final totalNotes = notes.length;
    final totalNodes = notes.fold<int>(
      0,
      (sum, note) => sum + note.nodes.length,
    );
    final totalEdges = notes.fold<int>(
      0,
      (sum, note) => sum + note.edges.length,
    );

    // 감정 분포 계산
    final emotionCounts = <String, int>{};
    for (final note in notes) {
      for (final node in note.nodes) {
        emotionCounts[node.emotion] = (emotionCounts[node.emotion] ?? 0) + 1;
      }
    }

    // 인기 키워드 계산
    final keywordCounts = <String, int>{};
    for (final note in notes) {
      for (final node in note.nodes) {
        keywordCounts[node.label] = (keywordCounts[node.label] ?? 0) + 1;
      }
    }

    final topKeywords = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return NoteStatistics(
      totalNotes: totalNotes,
      totalNodes: totalNodes,
      totalEdges: totalEdges,
      emotionDistribution: emotionCounts,
      topKeywords: topKeywords.take(10).toList(),
      averageNodesPerNote: totalNotes > 0 ? totalNodes / totalNotes : 0,
      averageEdgesPerNote: totalNotes > 0 ? totalEdges / totalNotes : 0,
    );
  }

  /// 최근 노트들
  List<MetaNoteModel> getRecentNotes([int limit = 5]) {
    final notes = state.value ?? [];
    return notes.take(limit).toList();
  }
}

// 통계 데이터 클래스
class NoteStatistics {
  final int totalNotes;
  final int totalNodes;
  final int totalEdges;
  final Map<String, int> emotionDistribution;
  final List<MapEntry<String, int>> topKeywords;
  final double averageNodesPerNote;
  final double averageEdgesPerNote;

  const NoteStatistics({
    this.totalNotes = 0,
    this.totalNodes = 0,
    this.totalEdges = 0,
    this.emotionDistribution = const {},
    this.topKeywords = const [],
    this.averageNodesPerNote = 0,
    this.averageEdgesPerNote = 0,
  });
}

// Note Provider 인스턴스
final noteProvider =
    StateNotifierProvider<NoteProvider, AsyncValue<List<MetaNoteModel>>>((ref) {
      final box = ref.watch(metaNoteBoxProvider);
      final uuid = ref.watch(uuidProvider);
      return NoteProvider(box, uuid);
    });

// 편의 프로바이더들
final notesProvider = Provider<List<MetaNoteModel>>((ref) {
  return ref.watch(noteProvider).value ?? [];
});

final recentNotesProvider = Provider<List<MetaNoteModel>>((ref) {
  final noteNotifier = ref.watch(noteProvider.notifier);
  return noteNotifier.getRecentNotes();
});

final noteStatisticsProvider = Provider<NoteStatistics>((ref) {
  final noteNotifier = ref.watch(noteProvider.notifier);
  return noteNotifier.getStatistics();
});

// 검색 프로바이더
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultProvider = Provider<List<MetaNoteModel>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final noteNotifier = ref.watch(noteProvider.notifier);
  return noteNotifier.searchNotes(query);
});

// 선택된 날짜 프로바이더
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final notesForSelectedDateProvider = Provider<List<MetaNoteModel>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final noteNotifier = ref.watch(noteProvider.notifier);
  return noteNotifier.getNotesForDate(selectedDate);
});
