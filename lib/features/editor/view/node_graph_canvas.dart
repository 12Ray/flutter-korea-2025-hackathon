import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../model/node_model.dart';
import '../model/edge_model.dart';

class NodeGraphCanvas extends ConsumerStatefulWidget {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final Function(NodeModel)? onNodeTap;
  final Function(NodeModel)? onNodeLongPress;
  final Function(NodeModel, Offset)? onNodeDrag;

  const NodeGraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.onNodeTap,
    this.onNodeLongPress,
    this.onNodeDrag,
  });

  @override
  ConsumerState<NodeGraphCanvas> createState() => _NodeGraphCanvasState();
}

class _NodeGraphCanvasState extends ConsumerState<NodeGraphCanvas>
    with TickerProviderStateMixin {
  NodeModel? _draggedNode;
  Offset? _dragOffset;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

    // 노드 위치 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNodePositions();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NodeGraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nodes.length != oldWidget.nodes.length) {
      _initializeNodePositions();
    }
  }

  void _initializeNodePositions() {
    if (widget.nodes.isEmpty) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 원형 배치
    for (int i = 0; i < widget.nodes.length; i++) {
      final angle = (2 * math.pi * i) / widget.nodes.length;
      final radius = math.min(size.width, size.height) * 0.3;

      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      widget.nodes[i].x = x;
      widget.nodes[i].y = y;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onPanStart: (details) => _onPanStart(details),
        onPanUpdate: (details) => _onPanUpdate(details),
        onPanEnd: (details) => _onPanEnd(details),
        onTapUp: (details) => _onTapUp(details),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: NodeGraphPainter(
                nodes: widget.nodes,
                edges: widget.edges,
                draggedNode: _draggedNode,
                dragOffset: _dragOffset,
                pulseScale: _pulseAnimation.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.scatter_plot, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                '생각 지도가 여기에 표시됩니다',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '위에 텍스트를 입력하고\n"생각 지도 생성"을 눌러보세요',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final node = _getNodeAtPosition(details.localPosition);
    if (node != null) {
      setState(() {
        _draggedNode = node;
        _dragOffset = details.localPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggedNode != null) {
      setState(() {
        _dragOffset = details.localPosition;
        _draggedNode!.x = details.localPosition.dx;
        _draggedNode!.y = details.localPosition.dy;
      });

      if (widget.onNodeDrag != null) {
        widget.onNodeDrag!(_draggedNode!, details.localPosition);
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _draggedNode = null;
      _dragOffset = null;
    });
  }

  void _onTapUp(TapUpDetails details) {
    final node = _getNodeAtPosition(details.localPosition);
    if (node != null && widget.onNodeTap != null) {
      widget.onNodeTap!(node);
      _showNodeTooltip(node, details.localPosition);
    }
  }

  NodeModel? _getNodeAtPosition(Offset position) {
    for (final node in widget.nodes) {
      final distance = math.sqrt(
        math.pow(position.dx - node.x, 2) + math.pow(position.dy - node.y, 2),
      );
      if (distance <= node.nodeRadius) {
        return node;
      }
    }
    return null;
  }

  void _showNodeTooltip(NodeModel node, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 100,
        top: position.dy - 80,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: node.emotionColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      node.emotion,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '빈도: ${node.freq}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // 3초 후 자동 제거
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class NodeGraphPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final List<EdgeModel> edges;
  final NodeModel? draggedNode;
  final Offset? dragOffset;
  final double pulseScale;

  NodeGraphPainter({
    required this.nodes,
    required this.edges,
    this.draggedNode,
    this.dragOffset,
    this.pulseScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 엣지 그리기
    _drawEdges(canvas);

    // 노드 그리기
    _drawNodes(canvas);
  }

  void _drawEdges(Canvas canvas) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in edges) {
      try {
        final fromNode = nodes.firstWhere((n) => n.id == edge.from);
        final toNode = nodes.firstWhere((n) => n.id == edge.to);

        edgePaint
          ..strokeWidth = edge.strokeWidth
          ..color = edge.edgeColor;

        // 곡선 그리기
        final path = Path();
        path.moveTo(fromNode.x, fromNode.y);

        // 제어점 계산 (곡선 효과)
        final midX = (fromNode.x + toNode.x) / 2;
        final midY = (fromNode.y + toNode.y) / 2;
        final controlX = midX + (fromNode.y - toNode.y) * 0.1;
        final controlY = midY + (toNode.x - fromNode.x) * 0.1;

        path.quadraticBezierTo(controlX, controlY, toNode.x, toNode.y);
        canvas.drawPath(path, edgePaint);

        // 화살표 그리기
        _drawArrow(canvas, fromNode, toNode, edgePaint);
      } catch (e) {
        // 노드를 찾을 수 없는 경우 무시
        continue;
      }
    }
  }

  void _drawArrow(Canvas canvas, NodeModel from, NodeModel to, Paint paint) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final angle = math.atan2(dy, dx);

    final arrowLength = 15.0;
    final arrowAngle = 0.3;

    // 노드 경계에서 시작하도록 조정
    final nodeRadius = to.nodeRadius;
    final endX = to.x - nodeRadius * math.cos(angle);
    final endY = to.y - nodeRadius * math.sin(angle);

    final arrowPath = Path();
    arrowPath.moveTo(endX, endY);
    arrowPath.lineTo(
      endX - arrowLength * math.cos(angle - arrowAngle),
      endY - arrowLength * math.sin(angle - arrowAngle),
    );
    arrowPath.moveTo(endX, endY);
    arrowPath.lineTo(
      endX - arrowLength * math.cos(angle + arrowAngle),
      endY - arrowLength * math.sin(angle + arrowAngle),
    );

    canvas.drawPath(arrowPath, paint);
  }

  void _drawNodes(Canvas canvas) {
    for (final node in nodes) {
      final isDragged = draggedNode == node;
      final scale = isDragged ? 1.2 : (node.freq > 3 ? pulseScale : 1.0);
      final radius = node.nodeRadius * scale;

      // 그림자
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(node.x + 2, node.y + 2), radius, shadowPaint);

      // 노드 배경
      final nodePaint = Paint()
        ..color = node.emotionColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(node.x, node.y), radius, nodePaint);

      // 노드 테두리
      final borderPaint = Paint()
        ..color = node.emotionColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(node.x, node.y), radius, borderPaint);

      // 텍스트
      _drawNodeText(canvas, node, radius);

      // 빈도 표시 (작은 원)
      if (node.freq > 1) {
        _drawFrequencyIndicator(canvas, node, radius);
      }
    }
  }

  void _drawNodeText(Canvas canvas, NodeModel node, double radius) {
    final textSpan = TextSpan(
      text: node.label,
      style: TextStyle(
        color: Colors.white,
        fontSize: (radius * 0.3).clamp(10.0, 16.0),
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: radius * 1.8);

    final textOffset = Offset(
      node.x - textPainter.width / 2,
      node.y - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void _drawFrequencyIndicator(Canvas canvas, NodeModel node, double radius) {
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final indicatorRadius = radius * 0.3;
    final indicatorX = node.x + radius * 0.7;
    final indicatorY = node.y - radius * 0.7;

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      indicatorRadius,
      indicatorPaint,
    );

    // 빈도 숫자
    final freqTextSpan = TextSpan(
      text: '${node.freq}',
      style: TextStyle(
        color: node.emotionColor,
        fontSize: indicatorRadius * 1.2,
        fontWeight: FontWeight.bold,
      ),
    );

    final freqTextPainter = TextPainter(
      text: freqTextSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    freqTextPainter.layout();

    final freqTextOffset = Offset(
      indicatorX - freqTextPainter.width / 2,
      indicatorY - freqTextPainter.height / 2,
    );

    freqTextPainter.paint(canvas, freqTextOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
