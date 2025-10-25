import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/ai_provider.dart';
import 'text_input_panel.dart';
import 'node_graph_canvas.dart';
import '../../report/view/report_page.dart';

class MetaNotePage extends ConsumerStatefulWidget {
  const MetaNotePage({super.key});

  @override
  ConsumerState<MetaNotePage> createState() => _MetaNotePageState();
}

class _MetaNotePageState extends ConsumerState<MetaNotePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    final isLoading = aiState.isLoading;
    final hasError = aiState.hasError;
    final nodes = aiState.nodes;
    final edges = aiState.edges;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧠 MetaNote',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: '에디터'),
            Tab(icon: Icon(Icons.analytics), text: '리포트'),
          ],
        ),
        actions: [
          // 설정 버튼
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettings,
            tooltip: '설정',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditorTab(isLoading, hasError, nodes, edges),
          const ReportPage(),
        ],
      ),
    );
  }

  Widget _buildEditorTab(bool isLoading, bool hasError, nodes, edges) {
    return Column(
      children: [
        // 상태 표시 바
        if (hasError) _buildErrorBar(),
        if (isLoading) _buildLoadingBar(),
        if (nodes.isNotEmpty) _buildSuccessBar(),

        // 텍스트 입력 패널
        TextInputPanel(
          controller: _textController,
          onGenerate: _generateMindMap,
          isLoading: isLoading,
        ),

        // 그래프 영역
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NodeGraphCanvas(
                  nodes: nodes,
                  edges: edges,
                  onNodeTap: _onNodeTap,
                  onNodeLongPress: _onNodeLongPress,
                  onNodeDrag: _onNodeDrag,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBar() {
    final errorMessage = ref.watch(aiProvider).errorMessage ?? '알 수 없는 오류';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(aiProvider.notifier).clearError(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'AI가 텍스트를 분석하여 생각 지도를 생성하고 있습니다...',
            style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBar() {
    final summary = ref.watch(aiProvider).summary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green.shade50,
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary.isNotEmpty ? summary : '생각 지도가 생성되었습니다!',
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => ref.read(aiProvider.notifier).clearError(),
          ),
        ],
      ),
    );
  }

  void _generateMindMap() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('텍스트를 먼저 입력해주세요!', isError: true);
      return;
    }

    // AI 프로바이더를 통해 개념 추출 시작
    ref.read(aiProvider.notifier).generateConceptGraph(text);
  }

  void _onNodeTap(node) {
    // 노드 탭 시 상세 정보 표시는 NodeGraphCanvas에서 처리됨
    debugPrint('Node tapped: ${node.label}');
  }

  void _onNodeLongPress(node) {
    _showNodeEditDialog(node);
  }

  void _onNodeDrag(node, offset) {
    // 노드 드래그 시 위치 업데이트
    ref
        .read(aiProvider.notifier)
        .updateNodePosition(node.id, offset.dx, offset.dy);
  }

  void _showNodeEditDialog(node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('노드 편집: ${node.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('감정: ${node.emotion}'),
            Text('빈도: ${node.freq}'),
            Text('생성 시간: ${DateFormat('MM/dd HH:mm').format(node.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(aiProvider.notifier).removeNode(node.id);
              _showSnackBar('노드가 삭제되었습니다.');
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('사용법'),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('앱 정보'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('초기화'),
              onTap: () {
                Navigator.pop(context);
                _resetApp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MetaNote 사용법'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 텍스트 입력 후 "생각 지도 생성" 버튼을 누르세요.'),
              SizedBox(height: 8),
              Text('2. AI가 핵심 개념을 추출하여 노드 그래프로 표시합니다.'),
              SizedBox(height: 8),
              Text('3. 노드를 탭하면 상세 정보를 볼 수 있습니다.'),
              SizedBox(height: 8),
              Text('4. 노드를 드래그하여 위치를 조정할 수 있습니다.'),
              SizedBox(height: 8),
              Text('5. 노드를 길게 누르면 편집/삭제할 수 있습니다.'),
              SizedBox(height: 8),
              Text('6. 저장 버튼으로 생각 지도를 보관할 수 있습니다.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MetaNote',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.psychology, size: 48),
      children: const [
        Text('생각의 연결을 그리는 노트 앱'),
        SizedBox(height: 8),
        Text('AI가 텍스트에서 핵심 개념을 추출하여 시각적인 사고 지도를 만들어줍니다.'),
      ],
    );
  }

  void _resetApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 초기화'),
        content: const Text('현재 작업 중인 내용이 모두 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(aiProvider.notifier).reset();
              _textController.clear();
              _showSnackBar('앱이 초기화되었습니다.');
            },
            child: const Text('확인', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: Duration(seconds: isError ? 4 : 2),
        action: isError
            ? SnackBarAction(
                label: '닫기',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }
}
