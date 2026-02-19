import 'package:flutter/foundation.dart' show kDebugMode;

enum LogLevel {
  debug,
  info,
  warning,
  error;

  bool operator >=(LogLevel other) => index >= other.index;
  bool operator <=(LogLevel other) => index <= other.index;
}

class LoggerConfig {
 static const int printToConsole     = 1 << 0;
static const int captureStackTraces = 1 << 1;
static const int enableAnalytics    = 1 << 2;
static const int enableFileLogging  = 1 << 3;
static const int enableCrashReporting = 1 << 4;

static const int all =
    printToConsole |
    captureStackTraces |
    enableAnalytics |
    enableFileLogging |
    enableCrashReporting;
  
  final int bufferSize;
  final LogLevel minLevel;
  final int flags;

  const LoggerConfig({
    required this.flags,
    required this.bufferSize,
    required this.minLevel,
  });

  factory LoggerConfig.fromEnv(String env) {
    return switch (env.toLowerCase()) {
      "dev" => debugConfig,
      "staging" => stagingConfig,
      "prod" => prodConfig,
      _=> kDebugMode? debugConfig: prodConfig
    };
  }

  bool has(int flag)=> (flags & flag) != 0;

  static const LoggerConfig debugConfig = LoggerConfig(
    bufferSize: 5000,
    flags: LoggerConfig.all ^ LoggerConfig.enableAnalytics ^ LoggerConfig.enableCrashReporting,               
    minLevel: LogLevel.debug,
  );

  static const LoggerConfig stagingConfig = LoggerConfig(
    bufferSize: 2000,
    flags: LoggerConfig.all,
    minLevel: LogLevel.debug,
  );

  static const LoggerConfig prodConfig = LoggerConfig(
    bufferSize: 1000,
    flags: LoggerConfig.all ^ LoggerConfig.printToConsole ^ LoggerConfig.captureStackTraces, 
    minLevel: LogLevel.warning, 
  );
}
