import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/schedule_styles.dart';
import '../cubit/schedule.dart';
import '../models/schedule_model.dart';
import '../widgets/borde_box.dart';
import 'add_schedule_page.dart';
import 'show_schedule_page.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyScheduleCubit, MyScheduleState>(
      builder: (context, state) {
        final mySchedules = state.schedules;
        final scheduleCubit = context.read<MyScheduleCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Расписание занятий",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: DecoratedBox(
            decoration: ScheduleStyles.linearBackgroundDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mySchedules.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Расписаний пока нет",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Добавьте первое расписание",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      "Мои расписания",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: mySchedules.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final schedule = mySchedules[index];
                        return OpenContainer(
                            closedColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            closedElevation: 0,
                            closedBuilder: (context, action) => BorderBox(
                                  child: _ScheduleCard(
                                    schedule: schedule,
                                    onDelete: () =>
                                        scheduleCubit.removeSchedule(schedule),
                                  ),
                                ),
                            openBuilder: (context, action) =>
                                ShowSchedulePage(params: schedule));
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final newSchedule = await Navigator.push(
                context,
                AddSchedulePage.route(),
              );
              if (newSchedule == null) return;
              scheduleCubit.addSchedule(newSchedule);
            },
            icon: Icon(Icons.add, size: 24),
            label: Text(
              "Добавить",
            ),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 15,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            schedule.requestType.icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                schedule.queryValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(schedule.requestType.text,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
