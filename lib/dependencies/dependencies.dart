import 'package:usue_schedule/features/schedule/controllers/schedule_cubit.dart';
import 'package:usue_schedule/features/settings/controllers/settings_cubit.dart';
import 'package:usue_schedule/features/schedule/services/api.dart';

class Dependencies {
  late final MyScheduleCubit scheduleCubit;
  late final SettingsCubit settingsCubit;
  late final ApiService apiService;
}
