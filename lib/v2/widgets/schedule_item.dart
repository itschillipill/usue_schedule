import 'package:flutter/material.dart';
import 'package:usue_schedule/v2/core/theme/schedule_styles.dart';
import 'package:usue_schedule/v2/widgets/label_group.dart';
import '../models/schedule_pair.dart';

class ScheduleItem extends StatelessWidget {
  final SchedulePair schedulePair;
  final int pairNumber;
  final Color groupColor;
  final List<SchedulePair>? relatedPairs;

  const ScheduleItem({
    super.key,
    required this.schedulePair,
    required this.pairNumber,
    required this.groupColor,
    this.relatedPairs,
  });

  bool get hasMultipleGroups => (relatedPairs?.length ?? 0) > 1;

  List<String> get allGroups {
    if (!hasMultipleGroups) return [schedulePair.cleanGroup];

    final groups = <String>{};
    for (var pair in relatedPairs!) {
      groups.add(pair.cleanGroup);
    }
    return groups.toList()..sort();
  }

  List<String> get allTeachers {
    if (!hasMultipleGroups) return [schedulePair.teacher];
    final teachers = <String>{};
    for (var pair in relatedPairs!) {
      teachers.add(pair.teacher);
    }
    return teachers.toList()..sort();
  }

  List<String> get allSubgroups {
    if (!hasMultipleGroups) {
      return schedulePair.isSubgroup ? ['${schedulePair.subgroupNumber}'] : [];
    }

    final subgroups = <String>{};
    for (var pair in relatedPairs!) {
      if (pair.isSubgroup) {
        subgroups.add('${pair.subgroupNumber}');
      }
    }
    return subgroups.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedulePair.subject,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (allGroups.length > 1) ...[
                      const SizedBox(height: 4),
                      _buildGroupsChips(context),
                    ],
                  ],
                ),
              ),
              if (allGroups.length==1) _buildSingleGroupChip(),
            ],
          ),
          const SizedBox(height: 10),

          Row(
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
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  allTeachers.join(', '),
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
          const SizedBox(height: 4),

          // Аудитория и время
          Row(
            children: [
              Icon(
                Icons.meeting_room_outlined,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                schedulePair.audience,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (allGroups.length > 1)
                LabelGroup(pairs: relatedPairs!.length)
            ],
          ),

          if (schedulePair.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ScheduleStyles.lessonTypeDecoration(
                        schedulePair.lessonType),
                    child: Text(
                      schedulePair.lessonType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (allSubgroups.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 12,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Подгр. ${allSubgroups.join(', ')}',
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
            ),
        ],
      ),
    );
  }

  Widget _buildSingleGroupChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: groupColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: groupColor,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            schedulePair.cleanGroup,
            style: TextStyle(
              fontSize: 12,
              color: groupColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          spacing: 6,
          runSpacing: 2,
          children: allGroups.map((group) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: groupColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                group,
                style: TextStyle(
                  fontSize: 12,
                  color: groupColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}