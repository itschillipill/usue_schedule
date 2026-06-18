import 'dart:async';

mixin DebouncedRequestMixin {
  Timer? _debounceTimer;

  /// Выполняет асинхронную операцию с задержкой и отменой предыдущей.
  Future<T> debouncedRequest<T>({
    required Duration delay,
    required Future<T> Function() action,
  }) {
    _debounceTimer?.cancel();

    final completer = Completer<T>();

    _debounceTimer = Timer(delay, () async {
      try {
        final result = await action();
        if (!completer.isCompleted) completer.complete(result);
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  void disposeDebounce() {
    _debounceTimer?.cancel();
  }
}
