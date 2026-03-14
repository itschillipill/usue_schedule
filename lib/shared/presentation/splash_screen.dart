import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usue_schedule/core/constants.dart';
import 'package:usue_schedule/core/theme/theme.dart';

class SplashScreen extends StatelessWidget {
  final ValueListenable<({int progress, String message})> progress;
  const SplashScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
            body: ValueListenableBuilder(
          valueListenable: progress,
          builder: (context, value, child) => SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Spacer(),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/app_logo.png"),
                  ),
                  Text(Constants.appName.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium),
                  LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    value: value.progress / 100,
                  ),
                  Text("Инициализация приложения..."),
                  Spacer(),
                  Text("Версия ${Constants.version}")
                ],
              ),
            ),
          ),
        )));
  }
}
