import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/features/schedule/models/request_type.dart';
import 'package:usue_schedule/features/schedule/widgets/date_picker.dart';
import 'package:usue_schedule/features/schedule/widgets/day_view.dart';
import 'package:usue_schedule/features/schedule/widgets/load_view.dart';

import '../controllers/schedule_view_provider.dart';
import '../models/schedule_model.dart';
import '../models/schedule_view_type.dart';

import '../../export/presentation/export_schedule_screen.dart';
import '../widgets/build_empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/filter_button.dart';
import '../widgets/schedule_header.dart';
import '../widgets/custom_range_view.dart';

class ShowScheduleScreen extends StatelessWidget {
  static Route<ScheduleModel> route({required ScheduleModel params}) {
    return MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ScheduleViewProvider(
          apiService: DependenciesScope.of(context).apiService,
          params: params,
        ),
        child: ShowScheduleScreen(params: params),
      ),
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
            _buildAppBar(context, provider),
            _buildHeader(context, provider),
          ],
          body: _buildBody(provider),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, ScheduleViewProvider provider) {
    return SliverAppBar(
      floating: true,
      snap: true,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(params.queryValue, style: const TextStyle(fontSize: 16)),
          Text(
            params.requestType.text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                ),
              );
            }

            if (value == "force_update_schedule") {
              provider.loadSchedule(force: true);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "export_schedule",
              child: Text("Экспорт расписания"),
            ),
            PopupMenuItem(
              value: "force_update_schedule",
              child: Text("Обновить с сервером"),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  SliverPersistentHeader _buildHeader(
      BuildContext context, ScheduleViewProvider provider) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: ScheduleHeaderDelegate(
        viewType: provider.viewType,
        rangeStart: provider.rangeStart,
        rangeEnd: provider.rangeEnd,
        navigatePrevious: provider.navigatePrevious,
        navigateNext: provider.navigateNext,
        onViewTypeChanged: provider.setViewType,
        showCalendar: () async {
          if (provider.viewType == ScheduleViewType.custom) {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialEntryMode: DatePickerEntryMode.inputOnly,
              initialDateRange: DateTimeRange(
                start: provider.rangeStart,
                end: provider.rangeEnd,
              ),
            );

            if (range != null) {
              provider.setCustomRange(range.start, range.end);
            }
          } else {
            DatePicker(
              selectedDate: provider.rangeStart,
              onDateSelected: provider.onDateSelected,
              context: context,
            ).call();
          }
        },
      ),
    );
  }

  Widget _buildBody(ScheduleViewProvider provider) {
    if (provider.isLoading) return const LoadView();

    if (provider.error != null) {
      return ErrorView(
        error: provider.error!,
        onRetry: provider.loadSchedule,
      );
    }

    if (provider.lastResponse == null) {
      return const Center(child: Text('Загрузка данных...'));
    }

    final filteredData = switch (params.requestType) {
      RequestType.group =>
        provider.lastResponse!.filterByTeacher(provider.selectedFilter),
      RequestType.teacher =>
        provider.lastResponse!.filterByGroup(provider.selectedFilter),
      _ => provider.lastResponse!,
    };

    final emptyState = BuildEmptyState(
      isFiltered: provider.isFiltered,
      isDayView: provider.viewType == ScheduleViewType.day,
      clearFilters: provider.clearFilters,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: provider.viewType == ScheduleViewType.day
          ? DayView(
              data: filteredData,
              selectedDate: provider.rangeStart,
              groupColors: provider.groupColors,
              buildEmptyState: emptyState,
            )
          : CustomRangeView(
              data: filteredData,
              rangeStart: provider.rangeStart,
              rangeEnd: provider.rangeEnd,
              groupColors: provider.groupColors,
              buildEmptyState: emptyState,
            ),
    );
  }
}
