import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/models/request_type.dart';
import 'package:usue_schedule/presentation/widgets/date_picker.dart';
import 'package:usue_schedule/presentation/widgets/day_view.dart';
import 'package:usue_schedule/presentation/widgets/load_view.dart';
import '../controlles/schedule_view_provider.dart';
import '../models/schedule_model.dart';
import 'export_schedule_screen.dart';
import 'widgets/build_empty_state.dart';
import 'widgets/error_view.dart';
import 'widgets/filter_button.dart';
import 'widgets/schedule_header.dart';
import 'widgets/week_view.dart';

class ShowScheduleScreen extends StatelessWidget {
  static Route<ScheduleModel> route({required ScheduleModel params}) {
    return MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider<ScheduleViewProvider>(
          create: (_) => ScheduleViewProvider(
                apiService: DependenciesScope.of(context).apiService,
                params: params,
              ),
          child: ShowScheduleScreen(params: params)),
    );
  }

  final ScheduleModel params;

  const ShowScheduleScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleViewProvider>();

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    actionsPadding: EdgeInsets.symmetric(horizontal: 4),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          params.queryValue,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          params.requestType.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      FilterButton(
                        selectedFilter: provider.selectedFilter,
                        availableGroups: provider.availableGroups,
                        availableTeachers: provider.availableTeachers,
                        requestType: params.requestType,
                        generatedColors: provider.groupColors,
                        toggleFilter: provider.toggleFilter,
                      ),
                      PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "export_schedule") {
                              Navigator.push(
                                  context,
                                  ExportScheduleScreen.route(
                                    params,
                                    provider.apiService.getSchedule,
                                  ));
                            }
                            if (value == "force_update_schedule") {
                              provider.loadSchedule(force: true);
                            }
                          },
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: "export_schedule",
                                    child: Text("Экспорт расписания")),
                                PopupMenuItem(
                                    value: "force_update_schedule",
                                    child: Text("Обновить с сервером")),
                              ],
                          child: Icon(Icons.more_vert)),
                    ],
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ScheduleHeaderDelegate(
                      isDayView: provider.isDayView,
                      selectedDate: provider.selectedDate,
                      selectedWeek: provider.selectedWeek,
                      navigatePrevious: () =>
                          provider.shiftDate(provider.isDayView ? -1 : -7),
                      navigateNext: () => provider.shiftDate(provider.isDayView ? 1 : 7),
                      toggleView: provider.toggleView,
                      showCalendar: DatePicker(
                              selectedDate: provider.selectedDate,
                              onDateSelected: provider.onDateSelected,
                              context: context)
                          .call,
                    ),
                  ),
                ],
            body: _buildBody(provider)),
      ),
    );
  }

  Widget _buildBody(ScheduleViewProvider provider) {
    if (provider.isLoading) return LoadView();
    if (provider.error != null) {
      return ErrorView(error: provider.error!, onRetry: provider.loadSchedule);
    }
    if (provider.lastResponse == null) {
      return const Center(child: Text('Загрузка данных...'));
    }

    final filteredData = switch (params.requestType) {
      RequestType.group => provider.lastResponse!.filterByTeacher(provider.selectedFilter),
      RequestType.teacher => provider.lastResponse!.filterByGroup(provider.selectedFilter),
      _ => provider.lastResponse!,
    };

    final emptyState = BuildEmptyState(
      isFiltered: provider.isFiltered,
      isDayView: provider.isDayView,
      clearFilters: provider.clearFilters,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: provider.isDayView
          ? DayView(
              data: filteredData,
              selectedDate: provider.selectedDate,
              groupColors: provider.groupColors,
              buildEmptyState: emptyState,
            )
          : WeekView(
              data: filteredData,
              selectedWeek: provider.selectedWeek,
              groupColors: provider.groupColors,
              buildEmptyState: emptyState,
            ),
    );
  }
}
