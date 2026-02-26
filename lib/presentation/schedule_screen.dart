import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/schedule_styles.dart';
import '../controlles/schedule_cubit.dart';
import 'show_schedule_screen.dart';
import 'widgets/schedule_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyScheduleCubit, MyScheduleState>(
      builder: (context, state) {
        final mySchedules = state.schedules;
        final scheduleCubit = context.read<MyScheduleCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Мои расписания",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            centerTitle: true,
          ),
          body: DecoratedBox(
            decoration: ScheduleStyles.linearBackgroundDecoration(context),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (mySchedules.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Расписаний пока нет",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Добавьте свое первое расписание",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                      itemCount: mySchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = mySchedules[index];
                        return ScheduleCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              ShowScheduleScreen.route(params: schedule),
                            );
                          },
                          scheduleModel: schedule,
                          onDelete: () =>
                              scheduleCubit.removeSchedule(schedule),
                        );
                      }),
                ),
            ]),
          ),
        );
      },
    );
  }
}
