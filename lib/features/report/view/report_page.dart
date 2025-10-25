import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../editor/provider/ai_provider.dart';
import '../../editor/model/node_model.dart';
import '../../editor/model/edge_model.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiProvider);

    if (aiState.nodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 생성된 생각 지도가 없습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '에디터에서 텍스트를 입력하고 생각 지도를 생성해보세요!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentSessionCard(aiState),
          const SizedBox(height: 24),
          _buildEmotionChart(aiState.nodes),
          const SizedBox(height: 24),
          _buildTopKeywords(aiState.nodes),
          const SizedBox(height: 24),
          _buildNodeDetails(aiState.nodes, aiState.edges),
        ],
      ),
    );
  }

  Widget _buildCurrentSessionCard(aiState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 현재 세션 통계',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.scatter_plot,
                title: '노드 수',
                value: '${aiState.nodes.length}개',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.linear_scale,
                title: '연결 수',
                value: '${aiState.edges.length}개',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        if (aiState.summary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(aiState.summary),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionChart(List<NodeModel> nodes) {
    if (nodes.isEmpty) {
      return _buildEmptyChart('감정 분포', '아직 생성된 노드가 없습니다.');
    }

    // 감정 분포 계산
    final emotionCounts = <String, int>{};
    for (final node in nodes) {
      emotionCounts[node.emotion] = (emotionCounts[node.emotion] ?? 0) + 1;
    }

    final emotionColors = {
      'positive': Colors.green,
      'neutral': Colors.blue,
      'negative': Colors.red,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '😊 감정 분포',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: emotionCounts.entries.map((entry) {
                    final emotion = entry.key;
                    final count = entry.value;
                    final total = emotionCounts.values.fold<int>(
                      0,
                      (sum, val) => sum + val,
                    );
                    final percentage = (count / total * 100).toStringAsFixed(1);

                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: '$percentage%',
                      color: emotionColors[emotion] ?? Colors.grey,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: emotionCounts.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: emotionColors[entry.key] ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.key} (${entry.value})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopKeywords(List<NodeModel> nodes) {
    if (nodes.isEmpty) {
      return _buildEmptyChart('키워드 분석', '아직 생성된 키워드가 없습니다.');
    }

    // 키워드 빈도 계산
    final keywordCounts = <String, int>{};
    for (final node in nodes) {
      keywordCounts[node.label] = (keywordCounts[node.label] ?? 0) + 1;
    }

    final sortedKeywords = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔥 키워드 분석',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: sortedKeywords.take(5).map((entry) {
                final maxCount = sortedKeywords.isNotEmpty
                    ? sortedKeywords.first.value
                    : 1;
                final progress = entry.value / maxCount;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.value}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNodeDetails(List<NodeModel> nodes, List<EdgeModel> edges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '� 노드 상세정보',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...nodes.map(
          (node) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getEmotionColor(node.emotion),
                child: Text(
                  '${node.freq}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                node.label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('감정: ${node.emotion} • 빈도: ${node.freq}'),
              trailing: Icon(
                _getEmotionIcon(node.emotion),
                color: _getEmotionColor(node.emotion),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'positive':
        return Icons.sentiment_satisfied;
      case 'negative':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Widget _buildEmptyChart(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(message, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
