import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usue_schedule/features/settings/controlles/settings_cubit.dart';
import 'package:usue_schedule/core/logger/session_logger.dart';
import 'package:usue_schedule/features/schedule/services/api.dart';

import '../features/cache/provider/cache_provider.dart';
import '../features/schedule/controllers/schedule_cubit.dart';
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
      SessionLogger.instance.debug("Initialization", step.$1);
    }
    return dependencies;
  }
}

List<(String, _InitializationStep)> get _initializationSteps => [
      ("Platform initialization", (_) => $platformInit()),
      (
        ("Initialization"),
        (deps) async {
          final prefs = await SharedPreferences.getInstance();

          deps.scheduleCubit = MyScheduleCubit(prefs: prefs);
          deps.settingsCubit = SettingsCubit(prefs: prefs);
          deps.apiService =
              ApiService(cacheProvider: kIsWeb ? null : CacheProvider());
        }
      ),
      //("Fake Waiting",(_)=> Future.delayed(Duration(seconds: 2)))
    ];
