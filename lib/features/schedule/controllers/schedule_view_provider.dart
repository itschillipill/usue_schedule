import 'package:material_ui/material_ui.dart' show ChangeNotifier, Color;
import 'package:usue_schedule/core/api_exceptions.dart';
import 'package:usue_schedule/features/schedule/models/schedule_model.dart';
import 'package:usue_schedule/features/schedule/models/schedule_response.dart';
import 'package:usue_schedule/features/schedule/services/api.dart';

import '../models/schedule_type.dart';
import '../models/schedule_view_type.dart';

class ScheduleViewProvider extends ChangeNotifier {
  ScheduleViewProvider({
    required this.apiService,
    required this.params,
    required this.onUpdate,
    required this.gColors,
    required this.onSave,
    this.savedSchedule = true,
    this.initialViewType = ScheduleViewType.day,
  }) {
    _init();
  }

  final ApiService apiService;
  final Function(ScheduleModel model) onUpdate;
  final Function(ScheduleModel model) onSave;
  final ScheduleViewType initialViewType;
  final List<Color> gColors;
  ScheduleModel params;

  /// этот флаг устанавливает сохраненное ли расписание.
  late bool savedSchedule;

  /// режим отображения
  late ScheduleViewType _viewType;
  ScheduleViewType get viewType => _viewType;

  List<String> get _activeFilters => params.scheduleType == ScheduleType.group
      ? availableTeachers
      : availableGroups;

  bool get hasFilters => _activeFilters.isNotEmpty;
  List<String> get availableFilters => _activeFilters;

  bool _disposed = false;

  // допустимые границы дат
  late final DateTime minDate;
  late final DateTime maxDate;

  /// диапазон дат
  DateTime rangeStart = DateTime.now();
  DateTime rangeEnd = DateTime.now();

  /// фильтр
  String? selectedFilter;

  /// доступные параметры
  List<String> availableGroups = [];
  List<String> availableTeachers = [];

  /// цвета групп
  final Map<String, Color> groupColors = {};

  /// данные
  ScheduleResponse? _response;
  ScheduleResponse? cuttedResponse;

  /// состояние
  String? error;
  bool isLoading = false;

  bool get isFiltered => selectedFilter != null;

  /// Проверка возможности навигации (для UI)
  bool get canNavigateNext {
    switch (_viewType) {
      case ScheduleViewType.day:
        return rangeStart.add(const Duration(days: 1)).compareTo(maxDate) <= 0;
      case ScheduleViewType.week:
        return rangeStart.add(const Duration(days: 7)).compareTo(maxDate) <= 0;
      case ScheduleViewType.month:
        final nextMonth = DateTime(rangeStart.year, rangeStart.month + 1, 1);
        return nextMonth.compareTo(maxDate) <= 0;
      case ScheduleViewType.custom:
        return rangeEnd.compareTo(maxDate) < 0;
    }
  }

  bool get canNavigatePrevious {
    switch (_viewType) {
      case ScheduleViewType.day:
        return rangeStart
                .subtract(const Duration(days: 1))
                .compareTo(minDate) >=
            0;
      case ScheduleViewType.week:
        return rangeStart
                .subtract(const Duration(days: 7))
                .compareTo(minDate) >=
            0;
      case ScheduleViewType.month:
        final prevMonth = DateTime(rangeStart.year, rangeStart.month - 1, 1);
        // Сравниваем с началом месяца minDate
        final minMonth = DateTime(minDate.year, minDate.month, 1);
        return prevMonth.compareTo(minMonth) >= 0;
      case ScheduleViewType.custom:
        return rangeStart.compareTo(minDate) > 0;
    }
  }

  /// инициализация
  void _init() {
    final now = DateTime.now();
    minDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 60));
    maxDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 90));

    // устанавливаем параметры по умолчанию (с проверкой на границы)
    setViewType(initialViewType, date: now);
  }

  /// загрузка расписания
  Future<void> loadSchedule({bool force = false}) async {
    force = force || params.needsUpdate();

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response =
          (!force && _response?.hasRange(rangeStart, rangeEnd) == true)
              ? _response
              : await apiService.fetch(
                  startDate: rangeStart,
                  endDate: rangeEnd,
                  scheduleModel: params,
                  forceUpdate: force,
                  saveSchedule: savedSchedule,
                  onUpdateModel: updateParams,
                );

      if (response case final r?) {
        _response = r;
        cuttedResponse = r.cut(rangeStart, rangeEnd);
        _extractParamsFrom(cuttedResponse!);
      }
    } on ApiException catch (e) {
      error = [e.message, e.tip].whereType<String>().join('\n');
    } catch (_) {
      error = "Неизвестная ошибка";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateParams(ScheduleModel model) {
    params = model;
    onUpdate(model);
  }

  void onSaveSchedule() {
    if (_response != null) apiService.saveCachedSchedule(params, _response!);
    updateParams(params.update());
    onSave(params);
    savedSchedule = true;
    notifyListeners();
  }

  /// клиппинг даты по границам min/max
  DateTime _clampDate(DateTime date) {
    if (date.isBefore(minDate)) return minDate;
    if (date.isAfter(maxDate)) return maxDate;
    return date;
  }

  /// DAY RANGE
  void _setDayRange(DateTime date) {
    final clamped = _clampDate(date);
    rangeStart = DateTime(clamped.year, clamped.month, clamped.day);
    rangeEnd = rangeStart;
  }

  /// WEEK RANGE
  void _setWeekRange(DateTime date) {
    final clamped = _clampDate(date);
    final start = clamped.subtract(Duration(days: clamped.weekday - 1));
    final end = start.add(const Duration(days: 6));

    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);
  }

  /// MONTH RANGE
  void _setMonthRange(DateTime date) {
    final clamped = _clampDate(date);
    final start = DateTime(clamped.year, clamped.month, 1);
    final end = DateTime(clamped.year, clamped.month + 1, 0);

    rangeStart = DateTime(start.year, start.month, start.day);
    rangeEnd = DateTime(end.year, end.month, end.day);
  }

  /// CUSTOM RANGE
  void setCustomRange(DateTime start, DateTime end) {
    final clampedStart = _clampDate(start);
    final clampedEnd = _clampDate(end);

    rangeStart =
        DateTime(clampedStart.year, clampedStart.month, clampedStart.day);
    rangeEnd = DateTime(clampedEnd.year, clampedEnd.month, clampedEnd.day);

    loadSchedule();
  }

  /// переключение режима
  void setViewType(ScheduleViewType type, {DateTime? date}) {
    _viewType = type;
    setDate(date ?? rangeStart, load: false);
    loadSchedule();
  }

  /// установка даты
  void setDate(DateTime date, {bool load = true}) {
    final fn = switch (_viewType) {
      ScheduleViewType.day => _setDayRange,
      ScheduleViewType.week => _setWeekRange,
      ScheduleViewType.month => _setMonthRange,
      _ => (_) {}
    };

    fn(date);

    if (load) {
      loadSchedule();
    }
  }

  /// навигация вперед
  void navigateNext() {
    if (!canNavigateNext) return;

    switch (_viewType) {
      case ScheduleViewType.day:
        _setDayRange(rangeStart.add(const Duration(days: 1)));
        break;

      case ScheduleViewType.week:
        _setWeekRange(rangeStart.add(const Duration(days: 7)));
        break;

      case ScheduleViewType.month:
        _setMonthRange(DateTime(rangeStart.year, rangeStart.month + 1, 1));
        break;

      default:
        break;
    }

    loadSchedule();
  }

  /// навигация назад
  void navigatePrevious() {
    if (!canNavigatePrevious) return;

    switch (_viewType) {
      case ScheduleViewType.day:
        _setDayRange(rangeStart.subtract(const Duration(days: 1)));
        break;

      case ScheduleViewType.week:
        _setWeekRange(rangeStart.subtract(const Duration(days: 7)));
        break;

      case ScheduleViewType.month:
        _setMonthRange(DateTime(rangeStart.year, rangeStart.month - 1, 1));
        break;

      default:
        break;
    }

    loadSchedule();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// фильтр
  void toggleFilter({required String? filter}) {
    selectedFilter = filter;
    notifyListeners();
  }

  void clearFilters() {
    selectedFilter = null;
    notifyListeners();
  }

  /// извлечение параметров
  void _extractParamsFrom(ScheduleResponse response) {
    availableGroups = response.getAllGroups();
    availableTeachers = response.getAllTeachers();
    _generateGroupColors();
  }

  /// генерация цветов
  void _generateGroupColors() {
    groupColors.clear();
    for (var (index, group) in availableGroups.indexed) {
      groupColors[group] = gColors[index % gColors.length];
    }
  }
}
