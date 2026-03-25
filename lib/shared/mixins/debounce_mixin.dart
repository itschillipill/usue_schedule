import 'dart:async';

import 'package:dio/dio.dart';

mixin DebouncedRequestMixin {
  Timer? _debounceTimer;
  CancelToken? _activeCancelToken;

  /// Выполняет асинхронную операцию с задержкой и отменой предыдущей.
  Future<T> debouncedRequest<T>({
    required Duration delay,
    required Future<T> Function(CancelToken token) action,
  }) {
    // Отменяем предыдущий запрос
    _activeCancelToken?.cancel("New request issued");
    _debounceTimer?.cancel();

    final completer = Completer<T>();

    _debounceTimer = Timer(delay, () async {
      final currentToken = CancelToken();
      _activeCancelToken = currentToken;

      try {
        final result = await action(currentToken);
        if (!completer.isCompleted) completer.complete(result);
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      } finally {
        if (_activeCancelToken == currentToken) {
          _activeCancelToken = null;
        }
      }
    });

    return completer.future;
  }

  void disposeDebounce() {
    _debounceTimer?.cancel();
    _activeCancelToken?.cancel();
  }
}
