import 'package:usue_schedule/controlles/schedule_cubit.dart';
import 'package:usue_schedule/controlles/settings_cubit.dart';

import '../controlles/cache_provider.dart';

class Dependencies {
  late final MyScheduleCubit scheduleCubit;
  late final SettingsCubit settingsCubit;
  late final CacheProvider cacheProvider;
}
