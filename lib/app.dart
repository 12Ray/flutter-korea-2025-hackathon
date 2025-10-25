import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'features/editor/view/meta_note_page.dart';
import 'features/editor/model/node_model.dart';
import 'features/editor/model/edge_model.dart';
import 'features/editor/model/meta_note_model.dart';

class MetaNoteApp extends ConsumerStatefulWidget {
  const MetaNoteApp({super.key});

  @override
  ConsumerState<MetaNoteApp> createState() => _MetaNoteAppState();
}

class _MetaNoteAppState extends ConsumerState<MetaNoteApp> {
  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    // Hive 초기화는 main.dart에서 이미 완료됨

    // 어댑터 등록 (한번만 등록)
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(NodeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(EdgeModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(MetaNoteModelAdapter());
      }
    } catch (e) {
      debugPrint('Hive adapter registration error: $e');
    }

    // 박스 열기
    try {
      await Hive.openBox<MetaNoteModel>('metanotes');
      await Hive.openBox('settings');
    } catch (e) {
      debugPrint('Hive box opening error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MetaNotePage(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // 시스템 글꼴 크기 무시
          ),
          child: child!,
        );
      },
    );
  }
}

/// 전역 에러 핸들러
class ErrorBoundary extends ConsumerWidget {
  final Widget child;
  final String fallbackMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackMessage = '문제가 발생했습니다.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}

/// 로딩 위젯
class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = '로딩 중...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// 에러 위젯
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ],
        ),
      ),
    );
  }
}
