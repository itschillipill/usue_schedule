import 'package:flutter/material.dart';

import '../../models/schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onDelete;

  const ScheduleCard({
    super.key,
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
