import 'package:flutter/material.dart';
import 'package:usue_schedule/models/request_type.dart';

class FilterButton extends StatelessWidget {
  final String? selectedFilter;
  final List<String> availableGroups;
  final List<String> availableTeachers;
  final RequestType requestType;
  final Map<String, Color> generatedColors;
  final Function({required String? filter}) toggleFilter;

  const FilterButton({
    super.key,
    required this.selectedFilter,
    required this.availableGroups,
    required this.availableTeachers,
    required this.requestType,
    required this.generatedColors,
    required this.toggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.filter_list,
        color: (selectedFilter != null) ? Colors.amber : null,
      ),
      onPressed: () => _showFilter(context),
      tooltip: 'Фильтр',
    );
  }

  Future<void> _showFilter(BuildContext context) async {
    String? selected = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (requestType == RequestType.teacher) ...[
                Text(
                  'Фильтр по группам',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (availableGroups.isEmpty)
                  Text(
                    'Нет доступных групп',
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableGroups.map((group) {
                      final isSelected = selectedFilter == group;
                      return FilterChip(
                        label: Text(group),
                        selected: isSelected,
                        onSelected: (_) => Navigator.pop(context, group),
                        showCheckmark: false,
                        avatar: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: generatedColors[group],
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ] else ...[
                Text(
                  'Фильтр по учителям',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (availableTeachers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Нет доступных учителей',
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTeachers.map((t) {
                      final isSelected = selectedFilter == t;
                      return FilterChip(
                        label: Text(t),
                        selected: isSelected,
                        onSelected: (_) => Navigator.pop(context, t),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
              ],
              const SizedBox(height: 20),
              if (selectedFilter != null)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, ""),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Сбросить фильтр'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      toggleFilter(filter: selected.isEmpty ? null : selected);
    }
  }
}
