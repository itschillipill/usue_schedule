import 'package:usue_schedule/controlles/schedule_cubit.dart';
import 'package:usue_schedule/controlles/settings_cubit.dart';
import 'package:usue_schedule/services/api.dart';

class Dependencies {
  late final MyScheduleCubit scheduleCubit;
  late final SettingsCubit settingsCubit;
  late final ApiService apiService;
}
