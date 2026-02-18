import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/models/request_type.dart';
import 'package:usue_schedule/presentation/widgets/day_view.dart';
import 'package:usue_schedule/presentation/widgets/filter_button.dart';
import 'package:usue_schedule/presentation/widgets/load_view.dart';
import '../core/theme/schedule_styles.dart';
import '../models/schedule_model.dart';
import '../models/schedule_response.dart';
import '../services/api.dart';
import 'widgets/build_empty_state.dart';
import 'widgets/date_picker.dart';
import 'widgets/error_view.dart';
import 'widgets/schedule_header.dart';
import 'widgets/week_view.dart';
import 'export_schedule_screen.dart';

class ShowScheduleScreen extends StatefulWidget {
  static Route<ScheduleModel> route({required ScheduleModel params}) {
    return MaterialPageRoute(
      builder: (_) => ShowScheduleScreen(params: params),
    );
  }

  final ScheduleModel params;

  const ShowScheduleScreen({super.key, required this.params});

  // ShowScheduleScreen tickerOf(BuildContext context){
  //   return context.findAncestorStateOfType<_ShowScheduleScreenState>()!._timeTicker;
  // }

  @override
  State<ShowScheduleScreen> createState() => _ShowScheduleScreenState();
}

class _ShowScheduleScreenState extends State<ShowScheduleScreen> {
  late final ApiService _apiService;
 // late final TimeTicker _timeTicker;

  DateTime _selectedDate = DateTime.now();
  DateTime _weekStart = DateTime.now();
  bool _isDayView = true;
  List<DateTime> _selectedWeek = [];

  String? _selectedGroupFilter;
  List<String> _availableGroups = [];
  String? _selectedTeacherFilter;
  List<String> _availableTeachers = [];
  final Map<String, Color> _groupColors = {};

  ScheduleResponse? _lastResponse;
  String? _error;
  bool _isLoading = false;

  StreamSubscription<ScheduleResponse?>? _subscription;

  bool get _isFiltered =>
      _selectedGroupFilter != null || _selectedTeacherFilter != null;

  @override
  void initState() {
    super.initState();
    _apiService =
        ApiService(cacheProvider: DependenciesScope.of(context).cacheProvider);
  //  _timeTicker = TimeTicker();
    _updateWeekDates();

    _subscription = _apiService.results.listen(
      (response) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (response != null) {
              _lastResponse = response;
              _error = null;
              _extractGroupsAndTeachersFromResponse(response);
            } else {
              _error = 'Ошибка при загрузке данных';
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = error.toString();
          });
        }
      },
    );
    _loadSchedule();
  }

  @override
  void dispose() {
    _subscription?.cancel();
  //  _timeTicker.dispose();
    super.dispose();
  }

  void _updateWeekDates() {
    _weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    _selectedWeek =
        List.generate(7, (index) => _weekStart.add(Duration(days: index)));
  }

  void _loadSchedule() {
    setState(() => _isLoading = true);

    final start = _isDayView ? _selectedDate : _selectedWeek.first;
    final end = _isDayView ? _selectedDate : _selectedWeek.last;

    final query = widget.params.requestType == RequestType.audience
        ? widget.params.queryValue.replaceAll(RegExp(r'[^0-9]'), '')
        : widget.params.queryValue;

    _apiService.search((start, end, widget.params.requestType, query));
  }

  void _extractGroupsAndTeachersFromResponse(ScheduleResponse response) {
    final groups = <String>{};
    final teachers = <String>{};

    for (var day in response.schedules) {
      for (var pair in day.pairs) {
        for (var schedulePair in pair.schedulePairs) {
          groups.add(schedulePair.cleanGroup);
          teachers.add(schedulePair.teacher);
        }
      }
    }

    _availableGroups = groups.toList()..sort();
    _availableTeachers = teachers.toList()..sort();
    _generateGroupColors();
  }

  void _generateGroupColors() {
    _groupColors
      ..clear()
      ..addEntries(
        _availableGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          return MapEntry(
              group,
              identical(group, _selectedGroupFilter)
                  ? Colors.amber.shade600
                  : ScheduleStyles.getGroupColor(index));
        }),
      );
  }

  void _onDateSelected(DateTime date) {
    _selectedDate = date;
    _updateWeekDates();
    _loadSchedule();
  }

  void _toggleView() {
    _isDayView = !_isDayView;
    _loadSchedule();
  }

  void _shiftDate(int days) {
    _selectedDate = _selectedDate.add(Duration(days: days));
    _updateWeekDates();
    _loadSchedule();
  }

  void _navigateToPrevious() => _shiftDate(_isDayView ? -1 : -7);
  void _navigateToNext() => _shiftDate(_isDayView ? 1 : 7);

  void _toggleFilter({required String? group, required String? teacher}) {
    _selectedGroupFilter = _selectedGroupFilter == group ? null : group;
    _selectedTeacherFilter = _selectedTeacherFilter == teacher ? null : teacher;
    _generateGroupColors();
    setState(() {});
  }

  void clearFilters() {
    setState(() {
      _selectedGroupFilter = null;
      _selectedTeacherFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar(
                actionsPadding: EdgeInsets.symmetric(horizontal: 4),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.params.queryValue,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.params.requestType.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                actions: [
                  FilterButton(
                    selectedGroupFilter: _selectedGroupFilter,
                    selectedTeacherFilter: _selectedTeacherFilter,
                    availableGroups: _availableGroups,
                    availableTeachers: _availableTeachers,
                    requestType: widget.params.requestType,
                    generatedColors: _groupColors,
                    toggleFilter: _toggleFilter,
                  ),
                  PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "export_schedule") {
                          Navigator.push(
                              context,
                              ExportScheduleScreen.route(
                                widget.params,
                                _apiService.getSchedule,
                              ));
                        }
                      },
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: "export_schedule",
                                child: Text("Экспорт расписания"))
                          ],
                      child: Icon(Icons.more_vert)),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: ScheduleHeaderDelegate(
                  isDayView: _isDayView,
                  selectedDate: _selectedDate,
                  selectedWeek: _selectedWeek,
                  navigatePrevious: _navigateToPrevious,
                  navigateNext: _navigateToNext,
                  toggleView: _toggleView,
                  showCalendar: DatePicker(
                          context: context,
                          selectedDate: _selectedDate,
                          onDateSelected: _onDateSelected)
                      .call,
                ),
              ),
            ];
          },
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return LoadView();
    if (_error != null) {
      return ErrorView(error: _error!, onRetry: _loadSchedule);
    }
    if (_lastResponse == null) {
      return const Center(child: Text('Загрузка данных...'));
    }

    final filteredData = _lastResponse!
        .filterResponseByGroup(_selectedGroupFilter)
        .filterResponseByTeacher(_selectedTeacherFilter);

    final emptyState = BuildEmptyState(
      isFiltered: _isFiltered,
      isDayView: _isDayView,
      clearFilters: clearFilters,
    );

    return _isDayView
        ? DayView(
            data: filteredData,
            isFiltered: _isFiltered,
            selectedDate: _selectedDate,
            groupColors: _groupColors,
            buildEmptyState: emptyState,
          )
        : WeekView(
            data: filteredData,
            selectedWeek: _selectedWeek,
            groupColors: _groupColors,
            buildEmptyState: emptyState,
          );
  }
}
