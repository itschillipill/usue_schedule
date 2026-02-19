import 'package:flutter/foundation.dart' show debugPrint;

import 'log_config.dart';

abstract class MyObserver {
  void onCreate(String name);
  void onClose(String name);
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  });
  void log(String name, String message);
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String category;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extra;

  LogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.error,
    this.stackTrace,
    this.extra,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final time = timestamp.toIso8601String();
    final levelStr = level.name.toUpperCase();
    final extraStr = extra != null && extra!.isNotEmpty
        ? '\n${extra!.entries.map((e) => '${e.key} : ${e.value}').join(',\n')}'
        : '';

    if (error != null) {
      final stack = stackTrace?.toString() ?? '';
      return '[$time][$levelStr] |$category| $message$extraStr -> $error\n$stack';
    }
    return '[$time][$levelStr] |$category| $message$extraStr';
  }
}

class SessionLogger implements MyObserver {
  static SessionLogger? _instance;
  final LoggerConfig _config;
  final List<LogEntry> _logs = [];

  SessionLogger._internal(this._config);

  factory SessionLogger({
    LoggerConfig? config,
  }) {
    _instance ??= SessionLogger._internal(
      config ?? LoggerConfig.debugConfig,
    );

    return _instance!;
  }

  static SessionLogger get instance {
    return _instance ??= SessionLogger();
  }

  void _log(LogEntry entry) {
    if (entry.level.index < _config.minLevel.index) {
      return;
    }
    if (_logs.length >= _config.bufferSize) {
      _logs.removeAt(0);
    }
    _logs.add(entry);

    if (_config.has(LoggerConfig.printToConsole)) {
      debugPrint(entry.toString());
    }
  }

  @override
  void onCreate(String name) {
    _log(LogEntry(
      level: LogLevel.info,
      category: 'LIFECYCLE',
      message: 'Created',
      extra: {'name': name},
    ));
  }

  @override
  void onClose(String name) {
    _log(LogEntry(
      level: LogLevel.info,
      category: 'LIFECYCLE',
      message: 'Closed',
      extra: {'name': name},
    ));
  }

  @override
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  }) {
    _log(LogEntry(
      level: LogLevel.error,
      category: name,
      message: message ?? 'Error occurred',
      error: error,
      stackTrace:
          _config.has(LoggerConfig.captureStackTraces) ? stackTrace : null,
    ));
  }

  @override
  void log(String name, String message) {
    _log(LogEntry(
      level: LogLevel.debug,
      category: name,
      message: message,
    ));
  }

  void debug(String category, String message, {Map<String, dynamic>? extra}) {
    _log(LogEntry(
      level: LogLevel.debug,
      category: category,
      message: message,
      extra: extra,
    ));
  }

  void info(String category, String message, {Map<String, dynamic>? extra}) {
    _log(LogEntry(
      level: LogLevel.info,
      category: category,
      message: message,
      extra: extra,
    ));
  }

  void warning(String category, String message, {Object? error}) {
    _log(LogEntry(
      level: LogLevel.warning,
      category: category,
      message: message,
      error: error,
    ));
  }

  void error(String category, String message,
      {Object? error, StackTrace? stackTrace}) {
    _log(LogEntry(
      level: LogLevel.error,
      category: category,
      message: message,
      error: error,
      stackTrace: stackTrace,
    ));
  }

  // Для BLoC
  void onTransition<T>(String name, T oldState, T newState) {
    _log(LogEntry(
      level: LogLevel.debug,
      category: name,
      message: 'State changed',
      extra: {
        'oldState': oldState.toString(),
        'newState': newState.toString(),
      },
    ));
  }

  // Управление логами
  List<LogEntry> getLogs() => List.unmodifiable(_logs);

  List<LogEntry> getLogsByLevel(LogLevel level) =>
      _logs.where((log) => log.level == level).toList();

  List<LogEntry> getLogsByCategory(String category) =>
      _logs.where((log) => log.category == category).toList();

  void clearLogs() => _logs.clear();
}
