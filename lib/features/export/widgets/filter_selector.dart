import 'package:flutter/material.dart';
import 'package:usue_schedule/features/schedule/models/request_type.dart';

import '../../schedule/controllers/schedule_view_provider.dart';

class FilterSelector {
  static Future<String?> show(
      BuildContext context, ScheduleViewProvider provider,
      {String? filter}) async {
    return await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSelectionSheet(
        availableFilters: provider.availableFilters,
        requestType: provider.params.requestType,
        generatedColors: provider.groupColors,
        selectedFilter: filter,
      ),
    );
  }
}

class _FilterSelectionSheet extends StatefulWidget {
  final List<String> availableFilters;
  final RequestType requestType;
  final Map<String, Color> generatedColors;
  final String? selectedFilter;

  const _FilterSelectionSheet({
    required this.availableFilters,
    required this.requestType,
    required this.generatedColors,
    this.selectedFilter,
  });

  @override
  State<_FilterSelectionSheet> createState() => _FilterSelectionSheetState();
}

class _FilterSelectionSheetState extends State<_FilterSelectionSheet> {
  String? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredFilters = [];

  @override
  void initState() {
    super.initState();
    _filteredFilters = widget.availableFilters;
    _selectedFilter = widget.selectedFilter;
    _searchController.addListener(_filterFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFilters = widget.availableFilters
          .where((filter) => filter.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGroup = widget.requestType == RequestType.group;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height * 0.75;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: availableHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              spacing: 5,
              children: [
                Icon(
                  !isGroup ? Icons.group : Icons.person,
                  color: theme.primaryColor,
                ),
                Expanded(
                  child: Text(
                    !isGroup ? 'Выберите группу' : 'Выберите преподавателя',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  if (_filteredFilters.isNotEmpty) ...[
                    _buildSortedFilters(theme),
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ничего не найдено',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                        context, widget.selectedFilter == null ? null : ""),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.selectedFilter != null
                        ? "Сбросить"
                        : "Без фильтра"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (_selectedFilter != null && _selectedFilter!.isNotEmpty)
                            ? () => Navigator.pop(context, _selectedFilter)
                            : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Применить фильтр',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortedFilters(ThemeData theme) {
    final sortedFilters = List<String>.from(_filteredFilters);

    if (_selectedFilter != null && sortedFilters.contains(_selectedFilter)) {
      sortedFilters.remove(_selectedFilter);
      sortedFilters.sort((a, b) => a.compareTo(b));
      sortedFilters.insert(0, _selectedFilter!);
    } else {
      sortedFilters.sort((a, b) => a.compareTo(b));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Wrap(
          key: ValueKey(_selectedFilter),
          spacing: 8,
          runSpacing: 8,
          children: sortedFilters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor:
                  widget.generatedColors[filter] ?? theme.primaryColor,
              checkmarkColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: !isSelected
                      ? (widget.generatedColors[filter] ?? Colors.transparent)
                      : Colors.transparent,
                ),
              ),
            );
          }).toList()),
    );
  }
}
