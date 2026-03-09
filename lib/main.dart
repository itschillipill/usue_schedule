import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'core/theme/theme.dart';
import 'features/settings/controlles/settings_cubit.dart';
import 'dependencies/widgets/intialization.dart';
import 'shared/presentation/app_gate.dart';
import 'shared/presentation/init_error_screen.dart';
import 'shared/presentation/splash_screen.dart';
import 'shared/services/message_service.dart';

void main() => runZonedGuarded(() async {
      final InitializationExecutor initialization = InitializationExecutor();
      runApp(
        DependenciesScope(
            splashScreen: const SplashScreen(),
            initialization: initialization(onError: $handleInitError),
            child: const App()),
      );
    },
        (error, stackTrace) =>
            SessionLogger.instance.onError("Main", error, stackTrace));

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = DependenciesScope.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => deps.scheduleCubit),
        BlocProvider(create: (_) => deps.settingsCubit),
      ],
      child: BlocSelector<SettingsCubit, SettingsState, ThemeMode>(
        selector: (state) => state.themeMode,
        builder: (context, themeMode) {
          return MaterialApp(
            navigatorKey: MessageService.navigatorKey,
            scaffoldMessengerKey: MessageService.scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: AppGate(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            locale: const Locale('ru'),
            supportedLocales: const [Locale('ru')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          );
        },
      ),
    );
  }
}

void $handleInitError(Object error, StackTrace stackTrace) async {
  SessionLogger.instance.onError("Initialization", error, stackTrace);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: InitializationErrorScreen(
        error: error,
        stackTrace: stackTrace,
      ),
    ),
  );
}
