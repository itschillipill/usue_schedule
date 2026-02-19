import 'dart:async' show TimeoutException, FutureOr;

import 'package:flutter/material.dart';
import 'package:usue_schedule/core/utils/logger/session_logger.dart';

class MessageServise {
  static String name="MessageServise";

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _loadingOverlay;

  static void _showLoading({String? message}) {
    if (_loadingOverlay != null) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlayState = navigatorKey.currentState?.overlay;

    _loadingOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withValues(alpha: 0.6),
            dismissible: false,
          ),
          Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null)
                      Text(message,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState?.insert(_loadingOverlay!);
  }

  static void _hideLoading() {
    if (_loadingOverlay == null) return;
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  static FutureOr<void> showLoading<T>({
    String? message,
    required Future<T> Function() fn,
    void Function(T value)? onSuccess,
    void Function(Object e, StackTrace? stacktrace)? onError,
    Duration delay = const Duration(milliseconds: 500),
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _showLoading(message: message);

    try {
      T result = await fn().timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
            'Операция превысила время ожидания $timeout'),
      );

      await Future.delayed(delay);

      if (result != null) {
        onSuccess?.call(result);
      }
    } catch (e, stackTrace) {
      SessionLogger.instance.error(name, "Error in showLoading", error: e, stackTrace: stackTrace);
      onError?.call(e, stackTrace);
    } finally {
      _hideLoading();
    }
  }
}
