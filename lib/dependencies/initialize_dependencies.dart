import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/cubit/settings_cubit.dart';

import '../cubit/schedule.dart';
import 'dependencies.dart';
import 'platform/initialization_vm.dart'
    if (dart.library.html) 'platform/initialization_js.dart';

typedef _InitializationStep = FutureOr<void> Function(
    Dependencies dependencies);

mixin InitializeDependencies {
  Future<Dependencies> $initializeDependencies({
    void Function(int progress, String message)? onProgress,
  }) async {
    final totalSteps = _initializationSteps.length;
    final dependencies = Dependencies();
    for (var currentStep = 0; currentStep < totalSteps; currentStep++) {
      final step = _initializationSteps[currentStep];
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.$1);
      await step.$2(dependencies);
    }
    return dependencies;
  }
}

List<(String, _InitializationStep)> get _initializationSteps => [
      ("Platform initialization", (_) => $platformInit()),
      (
        ("Cubits initialization"),
        (deps) async {
          final prefs = await SharedPreferences.getInstance();

          deps.scheduleCubit = MyScheduleCubit(prefs: prefs);
          deps.settingsCubit = SettingsCubit(prefs: prefs);
        }
      ),
      //("Fake Waiting",(_)=> Future.delayed(Duration(seconds: 2)))
    ];
