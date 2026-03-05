import 'package:flutter/material.dart';
import 'package:usue_schedule/features/schedule/models/request_type.dart';

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
    String? selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final items = requestType == RequestType.teacher
            ? [...availableGroups]
            : [...availableTeachers];

        // Если есть выбранный фильтр, ставим его первым
        if (selectedFilter != null && items.contains(selectedFilter)) {
          items.remove(selectedFilter);
          items.insert(0, selectedFilter!);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                requestType == RequestType.teacher
                    ? 'Фильтр по группам'
                    : 'Фильтр по учителям',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет доступных элементов'),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((item) {
                    final isSelected = selectedFilter == item;
                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (_) => Navigator.pop(context, item),
                      showCheckmark: false,
                      backgroundColor: Colors.grey[200],
                      selectedColor: generatedColors[item] ?? Colors.amber,
                      side: isSelected
                          ? const BorderSide(color: Colors.amber, width: 2)
                          : null,
                      avatar: requestType == RequestType.teacher
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: generatedColors[item],
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              if (selectedFilter != null)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, null),
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

    if (selected != null && selected != selectedFilter) {
      toggleFilter(filter: selected.isEmpty ? null : selected);
    }
  }
}
