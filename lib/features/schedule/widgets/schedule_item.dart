import 'package:flutter/material.dart';
import 'package:usue_schedule/features/schedule/models/schedule_pair.dart';
import 'package:usue_schedule/features/schedule/widgets/label_group.dart';

class ScheduleItem extends StatelessWidget {
  final List<SchedulePair> pairs;
  final Map<String, Color> groupColors;
  final bool hasTitle;
  final bool isLast;

  const ScheduleItem({
    super.key,
    required this.groupColors,
    required this.pairs,
    required this.hasTitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          if (hasTitle)
            Text(
              pairs.first.subject.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          if (pairs.hasMultipleGroups) _buildGroupsChips(pairs.length),
          Wrap(
            spacing: 5,
            children: [
              _buildIconText(
                  context, Icons.meeting_room_outlined, pairs.audience),
              _buildIconText(
                  context, Icons.person_outline, pairs.teachers.join(', ')),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              if (!pairs.hasMultipleGroups)
                _buildSingleGroupChip(pairs.first.cleanGroup),
              if (pairs.subgroups.isNotEmpty)
                _buildSubgroupBadge(pairs.subgroups.join(', ')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).hintColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubgroupBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Подгруппы: $text',
        style: const TextStyle(
            fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
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

  Widget _buildGroupsChips(int pairsCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        LabelGroup(pairs: pairsCount),
        const SizedBox(height: 4),
        Wrap(
          spacing: 2,
          runSpacing: 3,
          children: pairs.groups.map(_buildSingleGroupChip).toList(),
        ),
      ],
    );
  }
}
