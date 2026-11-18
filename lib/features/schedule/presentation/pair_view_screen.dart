import 'package:material_ui/material_ui.dart';
import 'package:usue_schedule/core/theme/theme.dart';
import 'package:usue_schedule/features/schedule/models/pair.dart';
import 'package:usue_schedule/features/schedule/models/schedule_type.dart';
import 'package:usue_schedule/features/schedule/models/schedule_pair.dart';

class PairViewScreen extends StatelessWidget {
  const PairViewScreen({super.key, required this.pair});

  final Pair pair;

  static Route<Pair> route({required Pair pair}) {
    return MaterialPageRoute(
      builder: (context) => PairViewScreen(pair: pair),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final groupedPairs = <String, List<SchedulePair>>{};
    for (final sp in pair.schedulePairs) {
      final key = '${sp.subject}|${sp.lessonType}|${sp.audience}';
      groupedPairs.putIfAbsent(key, () => []).add(sp);
    }
    final lessons = groupedPairs.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${pair.number} пара'),
        scrolledUnderElevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                pair.pairTime,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList.separated(
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 28),
              itemBuilder: (context, index) {
                return _LessonSection(
                  pairs: lessons[index],
                  index: index + 1,
                  total: lessons.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.pairs,
    required this.index,
    required this.total,
  });

  final List<SchedulePair> pairs;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final first = pairs.first;

    final teachers = _unique(pairs.map((p) => p.teacher));
    final groups = _unique(pairs.map((p) => p.cleanGroup));
    final audiences = _unique(pairs.map((p) => p.audience));
    final subgroups = _unique(
      pairs
          .where((p) => p.subgroupNumber != null)
          .map((p) => '${p.subgroupNumber} п/гр.'),
    );

    final typeColor = context.lessonTypeColor(first.lessonType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (total > 1) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                first.lessonType,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          first.subject,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.25,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),

        if (audiences.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.location_on_outlined,
            text: audiences.length > 1 ? 'Аудитории' : 'Аудитория',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: audiences
                .map((a) => _Chip(
                      text: a.isEmpty ? 'Не указана' : a,
                      icon: Icons.meeting_room_outlined,
                      color: ScheduleType.audience.color,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        if (teachers.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.person_outline,
            text: teachers.length > 1 ? 'Преподаватели' : 'Преподаватель',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: teachers
                .map((t) => _Chip(
                      text: t.isEmpty ? 'Не указан' : t,
                      icon: Icons.person,
                      color: ScheduleType.teacher.color,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        if (groups.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.groups_outlined,
            text: groups.length > 1 ? 'Группы' : 'Группа',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: groups
                .map((g) => _Chip(
                      text: g,
                      icon: Icons.school_outlined,
                      color: ScheduleType.group.color,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        if (subgroups.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.call_split_outlined,
            text: 'Подгруппы',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subgroups
                .map((s) => _Chip(
                      text: s,
                      icon: Icons.filter_alt_outlined,
                      color: scheme.onSurfaceVariant,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // ─── Комментарий ────────────────────────────────────────
        if (first.comment.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.info_outline,
            text: 'Примечание',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    first.comment,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (index < total)
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  static List<String> _unique(Iterable<String> src) {
    final seen = <String>{};
    final out = <String>[];
    for (final s in src) {
      if (seen.add(s)) out.add(s);
    }
    return out;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
