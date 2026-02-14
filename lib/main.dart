import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'core/theme/theme.dart';
import 'cubit/settings_cubit.dart';
import 'dependencies/widgets/intialization.dart';
import 'pages/home_page.dart';
import 'pages/splash_screen.dart';

void main() => runZonedGuarded(()async{
  
  WidgetsFlutterBinding.ensureInitialized();
  final InitializationExecutor initialization = InitializationExecutor();
  runApp(
    DependenciesScope(
      splashScreen: const SplashScreen(),
      initialization: initialization(),
      child: const App()),
  );
  }, (error, stackTrace){
    // TODO: itschillipill/ log error
  });



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
    child: BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          home: HomePage(),
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