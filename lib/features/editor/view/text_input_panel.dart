import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextInputPanel extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final VoidCallback onGenerate;
  final bool isLoading;

  const TextInputPanel({
    super.key,
    required this.controller,
    required this.onGenerate,
    this.isLoading = false,
  });

  @override
  ConsumerState<TextInputPanel> createState() => _TextInputPanelState();
}

class _TextInputPanelState extends ConsumerState<TextInputPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTextInput(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.edit_note,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '생각을 자유롭게 적어보세요',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'AI가 핵심 개념을 추출하여 연결 관계를 시각화합니다',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextField(
        controller: widget.controller,
        maxLines: 5,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          hintText:
              '예: 오늘은 Flutter로 AI 앱을 만들어보려고 한다. 노드 그래프로 생각을 시각화하면 재밌을 것 같다. 사용자가 텍스트를 입력하면 Gemini가 핵심 개념을 추출하고...',
          hintMaxLines: 3,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (text) {
          setState(() {}); // suffixIcon 업데이트를 위해
        },
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton.icon(
          onPressed: widget.isLoading || widget.controller.text.trim().isEmpty
              ? null
              : () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onGenerate();
                },
          icon: widget.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(widget.isLoading ? '생성 중...' : '생각 지도 생성'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
