import 'package:material_ui/material_ui.dart';
import 'package:usue_schedule/core/page_transition/app_page_route.dart';
import 'package:usue_schedule/features/schedule/widgets/schedule_card.dart';
import '../models/schedule_type.dart';
import '../models/schedule_model.dart';
import '../services/schedule_search_service.dart';
import '../widgets/s.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen._();

  static Route<ScheduleModel> route() {
    return AppPageRoute.build(
        page: (_) => AddScheduleScreen._(),
        transition: PageTransitionType.slideFromBottom);
  }

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _controller = TextEditingController();
  final _searchService = ScheduleSearchService();

  ScheduleType scheduleType = ScheduleType.group;

  @override
  void dispose() {
    _controller.dispose();
    _searchService.dispose();
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 14,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ScheduleType>(
                      value: scheduleType,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ScheduleType.values.map((type) {
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
                      }).toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          scheduleType = value;
                          _controller.clear();
                        });
                      },
                    ),
                  ),
                ),

                // Поле поиска
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Начните вводить название...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _controller.clear,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    _searchService.search(
                      ScheduleModel(
                        scheduleType: scheduleType,
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
                    return S((
                      Icons.search_outlined,
                      "Начните поиск",
                      "Введите название в поле выше"
                    ));
                  }

                  if (items.isEmpty) {
                    return S((
                      Icons.search_off_outlined,
                      "Ничего не найдено",
                      "Попробуйте другой запрос или проверьте подключение к интернету и VPN"
                    ));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return ScheduleCard(
                        scheduleModel: item,
                        onTap: () => Navigator.pop(context, item),
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
}
