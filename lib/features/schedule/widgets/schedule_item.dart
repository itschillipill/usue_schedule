import 'package:flutter/material.dart';
import 'package:usue_schedule/core/theme/schedule_styles.dart';
import 'package:usue_schedule/features/schedule/models/schedule_pair.dart';
import 'package:usue_schedule/features/schedule/widgets/label_group.dart';

class ScheduleItem extends StatelessWidget {
  final List<SchedulePair> pairs;
  final Map<String, Color> groupColors;

  const ScheduleItem(
      {super.key, required this.groupColors, required this.pairs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      pairs.first.subject,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (pairs.hasMultipleGroups) _buildGroupsChips(context),
                  ],
                ),
              ),
              if (!pairs.hasMultipleGroups)
                _buildSingleGroupChip(pairs.first.cleanGroup),
            ],
          ),

          Row(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              Expanded(
                child: Text(
                  pairs.teachers.join(', '),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),

          // Аудитория и время
          Row(
            spacing: 2,
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              Text(
                pairs.audience,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (pairs.hasMultipleGroups) LabelGroup(pairs: pairs.length)
            ],
          ),

          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration:
                    ScheduleStyles.lessonTypeDecoration(pairs.first.lessonType),
                child: Text(
                  pairs.first.lessonType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (pairs.subgroups.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Icon(
                        Icons.account_tree_outlined,
                        size: 12,
                        color: Colors.purple,
                      ),
                      Text(
                        'Подгр. ${pairs.subgroups.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleGroupChip(String group) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (groupColors[group] ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        group,
        style: TextStyle(
          fontSize: 12,
          color: groupColors[group] ?? Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGroupsChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            Text(
              'Группы:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          runSpacing: 3,
          children: pairs.groups.map(_buildSingleGroupChip).toList(),
        ),
      ],
    );
  }
}
