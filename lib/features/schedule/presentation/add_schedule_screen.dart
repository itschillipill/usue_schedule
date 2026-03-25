import 'package:flutter/material.dart';
import 'package:usue_schedule/core/page_transition/app_page_route.dart';
import 'package:usue_schedule/features/schedule/widgets/schedule_card.dart';
import '../models/request_type.dart';
import '../models/schedule_model.dart';
import '../services/schedule_search_service.dart';

class AddScheduleScreen extends StatefulWidget {
  static Route<ScheduleModel> route() {
    return AppPageRoute.build(
        page: (_) => AddScheduleScreen._(),
        transition: PageTransitionType.slideFromBottom);
  }

  const AddScheduleScreen._();

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _controller = TextEditingController();
  final _searchService = ScheduleSearchService();
  final _focusNode = FocusNode();

  RequestType requestType = RequestType.group;
  ScheduleModel? selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchService.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Добавить расписание",
            style: Theme.of(context).textTheme.bodyMedium),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[600]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(context, selected),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Добавить",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RequestType>(
                      value: requestType,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: RequestType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            spacing: 10,
                            children: [
                              Icon(
                                type.icon,
                                color: type.color,
                              ),
                              Text(type.text),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          requestType = value;
                          _controller.clear();
                          selected = null;
                        });
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Поле поиска
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Начните вводить название...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              selected = null;
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    selected = null;
                    setState(() {});
                    _searchService.search(
                      ScheduleModel(
                        requestType: requestType,
                        queryValue: value.trim(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Результаты поиска
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                color: Theme.of(context).cardColor,
              ),
              child: ValueListenableBuilder<List<ScheduleModel>>(
                valueListenable: _searchService.resultsNotifier,
                builder: (context, items, _) {
                  if (_controller.text.isEmpty) {
                    return _buildEmptyState();
                  }

                  if (items.isEmpty) {
                    return _buildNoResults();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selected == item;

                      return ScheduleCard(
                        scheduleModel: item,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selected = item;
                            _controller.text = item.queryValue;
                          });
                          _focusNode.unfocus();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Начните поиск",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Введите название в поле выше",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Ничего не найдено",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Попробуйте другой запрос или проверьте подключение к интернету и VPN",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
