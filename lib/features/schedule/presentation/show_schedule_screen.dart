import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/core/api_exceptions.dart';
import 'package:usue_schedule/core/theme/theme.dart';
import 'package:usue_schedule/features/schedule/models/schedule_type.dart';
import 'package:usue_schedule/features/schedule/widgets/day_view.dart';
import 'package:usue_schedule/features/schedule/widgets/load_view.dart';
import 'package:usue_schedule/shared/services/message_service.dart';
import 'package:usue_schedule/shared/widgets/border_box.dart';

import '../../export/services/export_service.dart';
import '../../export/widgets/filter_selector.dart';
import '../controllers/schedule_view_provider.dart';
import '../models/schedule_view_type.dart';

import '../widgets/build_empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/custom_range_view.dart';
import '../../settings/settings_screen.dart';

class ShowScheduleScreen extends StatelessWidget {
  const ShowScheduleScreen({
    super.key,
    required this.contentOpacity,
    required this.onSwitch,
  });

  final VoidCallback onSwitch;
  final double contentOpacity;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleViewProvider>();
    return Scaffold(
      body: Visibility(
        visible: contentOpacity > 0.15,
        child: Opacity(
          opacity: contentOpacity,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      _buildAppBar(context, provider),
                      _buildHeader(context, provider),
                      if (provider.cuttedResponse?.exception
                          case ApiException exception
                          when provider.cuttedResponse?.isFromCache == true)
                        _buildWarning(exception, context.backgroundColor)
                    ],
                    body: DecoratedBox(
                      decoration: BoxDecoration(color: context.backgroundColor),
                      child: _buildBody(provider),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: provider.savedSchedule
          ? null
          : Visibility(
              visible: contentOpacity > 0.25,
              child: FilledButton(
                onPressed: provider.onSaveSchedule,
                child: Text("Coхранить"),
              )),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, ScheduleViewProvider provider) {
    return SliverAppBar(
      leading: provider.savedSchedule
          ? IconButton(
              onPressed: onSwitch,
              icon: const Icon(Icons.list_rounded),
              tooltip: 'К списку расписаний',
            )
          : null,
      floating: true,
      snap: true,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 4),
      titleSpacing: 0,
      title: Text(
        provider.params.queryValue,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(provider.viewType.icon),
          tooltip: 'Режим отображения',
          onPressed: () => _showViewTypeBottomSheet(context, provider),
        ),
        if (provider.params.scheduleType != ScheduleType.audience)
          Badge(
            smallSize: 10,
            padding: EdgeInsets.zero,
            backgroundColor: (provider.groupColors[provider.selectedFilter] ??
                context.primaryColor),
            isLabelVisible: (provider.selectedFilter != null),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: (provider.selectedFilter != null)
                    ? (provider.groupColors[provider.selectedFilter] ??
                        Theme.of(context).colorScheme.primary)
                    : null,
              ),
              onPressed: () async {
                final filter = await FilterSelector.show(context, provider,
                    filter: provider.selectedFilter);
                if (filter != null) {
                  provider.toggleFilter(filter: filter.isEmpty ? null : filter);
                }
              },
              tooltip: 'Фильтр',
            ),
          ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Настройки',
        ),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          tooltip: 'Дополнительно',
          onSelected: (value) {
            switch (value) {
              case "force_update_schedule":
                provider.loadSchedule(force: true);
                break;

              case "download_schedule":
                if (provider.cuttedResponse case final r?) {
                  final filtredData = r.schedules.where(
                    (s) => s.pairs.any((p) => p.schedulePairs.isNotEmpty),
                  );
                  if (filtredData.isEmpty) {
                    MessageService.showSnackBar(
                        "На этот период расписание не найдено");
                  } else {
                    ExportService.exportSchedule(context, provider);
                  }
                  break;
                }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "force_update_schedule",
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text("Обновить с сервером"),
                ],
              ),
            ),
            PopupMenuItem(
              value: "download_schedule",
              child: Row(
                children: [
                  Icon(Icons.download_outlined, size: 18),
                  SizedBox(width: 8),
                  Text("Скачать расписание"),
                ],
              ),
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.more_vert),
          ),
        ),
      ],
    );
  }

  SliverAppBar upperAppBar(
      BuildContext context, ScheduleViewProvider provider) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: onSwitch,
        icon: const Icon(Icons.list_rounded),
        tooltip: 'К списку расписаний',
      ),
      floating: true,
      snap: true,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 4),
      titleSpacing: 0,
      title: Text(
        provider.params.queryValue,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(provider.viewType.icon),
          tooltip: 'Режим отображения',
          onPressed: () => _showViewTypeBottomSheet(context, provider),
        ),
        if (provider.params.scheduleType != ScheduleType.audience)
          Badge(
            smallSize: 10,
            padding: EdgeInsets.zero,
            backgroundColor: (provider.groupColors[provider.selectedFilter] ??
                context.primaryColor),
            isLabelVisible: (provider.selectedFilter != null),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: (provider.selectedFilter != null)
                    ? (provider.groupColors[provider.selectedFilter] ??
                        Theme.of(context).colorScheme.primary)
                    : null,
              ),
              onPressed: () async {
                final filter = await FilterSelector.show(context, provider,
                    filter: provider.selectedFilter);
                if (filter != null) {
                  provider.toggleFilter(filter: filter.isEmpty ? null : filter);
                }
              },
              tooltip: 'Фильтр',
            ),
          ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Настройки',
        ),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          tooltip: 'Дополнительно',
          onSelected: (value) {
            switch (value) {
              case "force_update_schedule":
                provider.loadSchedule(force: true);
                break;

              case "download_schedule":
                if (provider.cuttedResponse case final r?) {
                  final filtredData = r.schedules.where(
                    (s) => s.pairs.any((p) => p.schedulePairs.isNotEmpty),
                  );
                  if (filtredData.isEmpty) {
                    MessageService.showSnackBar(
                        "На этот период расписание не найдено");
                  } else {
                    ExportService.exportSchedule(context, provider);
                  }
                  break;
                }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "force_update_schedule",
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text("Обновить с сервером"),
                ],
              ),
            ),
            PopupMenuItem(
              value: "download_schedule",
              child: Row(
                children: [
                  Icon(Icons.download_outlined, size: 18),
                  SizedBox(width: 8),
                  Text("Скачать расписание"),
                ],
              ),
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.more_vert),
          ),
        ),
      ],
    );
  }

  Future<void> _showViewTypeBottomSheet(
      BuildContext context, ScheduleViewProvider provider) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Режим отображения',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...ScheduleViewType.values.map((type) {
                final isSelected = provider.viewType == type;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected
                      ? context.primaryColor.withValues(alpha: 0.1)
                      : null,
                  leading: Icon(
                    type.icon,
                    color: isSelected ? context.primaryColor : null,
                  ),
                  title: Text(
                    type.text,
                    style: isSelected
                        ? TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          )
                        : const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: context.primaryColor)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      provider.setViewType(type, date: DateTime.now());
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
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
          showCalendar: DatePicker(
              context: context,
              viewType: provider.viewType,
              rangeStart: provider.rangeStart,
              rangeEnd: provider.rangeEnd,
              onDateSelected: provider.setDate,
              onDateRangeSelected: provider.setCustomRange,
              borders: (provider.minDate, provider.maxDate)).call),
    );
  }

  SliverToBoxAdapter _buildWarning(
      ApiException exception, Color backgroundColor) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: BorderBox(
            borderColor: Colors.orange,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exception.message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Текущее расписание может быть устаревшим.",
                        style: TextStyle(fontSize: 14),
                      ),
                      if (exception.tip case String tip
                          when tip.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tip,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

    if (provider.cuttedResponse == null) {
      return const Center(child: Text('Загрузка данных...'));
    }

    final filteredData = provider.cuttedResponse!
        .getFiltredData(provider.params.scheduleType, provider.selectedFilter)
        .schedules;

    final emptyState = BuildEmptyState(
      isFiltered: provider.isFiltered,
      isDayView: provider.viewType == ScheduleViewType.day,
      clearFilters: provider.clearFilters,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: switch (provider.viewType) {
        ScheduleViewType.day => DayView(
            data: filteredData,
            selectedDate: provider.rangeStart,
            buildEmptyState: emptyState,
          ),
        _ => CustomRangeView(
            data: filteredData,
            rangeStart: provider.rangeStart,
            rangeEnd: provider.rangeEnd,
            buildEmptyState: emptyState,
          )
      },
    );
  }
}

class ScheduleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ScheduleViewType viewType;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final VoidCallback navigatePrevious;
  final VoidCallback navigateNext;
  final VoidCallback showCalendar;

  ScheduleHeaderDelegate({
    required this.viewType,
    required this.rangeStart,
    required this.rangeEnd,
    required this.navigatePrevious,
    required this.navigateNext,
    required this.showCalendar,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isCustom = viewType == ScheduleViewType.custom;
    final isDayView = viewType == ScheduleViewType.day;

    String titleText = switch (viewType) {
      ScheduleViewType.day =>
        DateFormat('dd MMMM yyyy', 'ru').format(rangeStart),
      ScheduleViewType.month ||
      ScheduleViewType.week =>
        '${DateFormat('dd MMM', 'ru').format(rangeStart)} — ${DateFormat('dd MMM yyyy', 'ru').format(rangeEnd)}',
      ScheduleViewType.custom =>
        '${DateFormat('dd.MM.yy', 'ru').format(rangeStart)} — ${DateFormat('dd.MM.yy', 'ru').format(rangeEnd)}'
    };

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (!isCustom)
            IconButton.filledTonal(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: navigatePrevious,
              tooltip: isDayView ? 'Предыдущий день' : 'Предыдущий период',
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              padding: EdgeInsets.zero,
            ),
          if (!isCustom) const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: showCalendar,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.4)),
                  color: theme.cardColor.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 15, color: primaryColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isCustom) const SizedBox(width: 6),
          if (!isCustom)
            IconButton.filledTonal(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: navigateNext,
              tooltip: isDayView ? 'Следующий день' : 'Следующий период',
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant ScheduleHeaderDelegate oldDelegate) => true;
}

class DatePicker {
  DatePicker({
    required this.context,
    required this.viewType,
    required this.rangeStart,
    required this.rangeEnd,
    required this.borders,
    this.onDateSelected,
    this.onDateRangeSelected,
  });

  final BuildContext context;
  final ScheduleViewType viewType;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final (DateTime, DateTime) borders;
  final ValueChanged<DateTime>? onDateSelected;
  final void Function(DateTime start, DateTime end)? onDateRangeSelected;

  Future<void> call() async {
    switch (viewType) {
      case ScheduleViewType.custom:
        final range = await showDateRangePicker(
          context: context,
          firstDate: borders.$1,
          lastDate: borders.$2,
          initialEntryMode: DatePickerEntryMode.input,
          initialDateRange: DateTimeRange(start: rangeStart, end: rangeEnd),
        );
        if (range != null) {
          onDateRangeSelected?.call(range.start, range.end);
        }
        break;

      case ScheduleViewType.day:
        final date = await _showCalendarBottomSheet(borders.$1, borders.$2);
        if (date != null) {
          onDateSelected?.call(date);
        }
        break;
      default:
        break;
    }
  }

  Future<DateTime?> _showCalendarBottomSheet(
      DateTime minDate, DateTime maxDate) {
    return showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Выберите дату',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, DateTime.now()),
                    child: const Text("Сегодня"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              CalendarDatePicker(
                initialDate: rangeStart,
                firstDate: minDate,
                lastDate: maxDate,
                currentDate: DateTime.now(),
                onDateChanged: (newDate) => Navigator.pop(context, newDate),
              ),
            ],
          ),
        );
      },
    );
  }
}
