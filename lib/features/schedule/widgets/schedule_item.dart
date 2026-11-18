import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/features/schedule/models/schedule_pair.dart';

import '../controllers/schedule_view_provider.dart';
import '../models/schedule_type.dart';

class ScheduleItem extends StatelessWidget {
  final List<SchedulePair> pairs;
  final bool hasTitle;
  final bool isLast;

  const ScheduleItem({
    super.key,
    required this.pairs,
    required this.hasTitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ScheduleViewProvider>();
    final ScheduleType scheduleType = provider.params.scheduleType;

    final bool showTeacher = scheduleType != ScheduleType.teacher;
    final bool showGroup = scheduleType != ScheduleType.group;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
          RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              children: [
                if (pairs.audience.isNotEmpty) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        size: 14,
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: pairs.audience,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
                if (pairs.audience.isNotEmpty && showTeacher)
                  TextSpan(
                    text: ' • ',
                    style: TextStyle(color: theme.hintColor),
                  ),
                if (showTeacher)
                  TextSpan(
                    text: pairs.teachers.join(', '),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (showGroup || pairs.subgroups.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (pairs.hasMultipleGroups)
                  ...pairs.map(
                    (e) {
                      return _buildChip(
                        text: e.cleanGroup,
                        color: provider.groupColors[pairs.first.cleanGroup] ??
                            theme.colorScheme.primary,
                      );
                    },
                  )
                else if (showGroup)
                  _buildChip(
                    text: pairs.first.cleanGroup,
                    color: provider.groupColors[pairs.first.cleanGroup] ??
                        theme.colorScheme.primary,
                  ),
                if (pairs.subgroups.isNotEmpty)
                  _buildChip(
                    text: 'Подгр. ${pairs.subgroups.join(', ')}',
                    color: Colors.purple,
                    icon: Icons.account_tree_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
