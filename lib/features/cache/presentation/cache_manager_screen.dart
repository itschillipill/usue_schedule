import 'package:flutter/material.dart';
import 'package:usue_schedule/features/cache/provider/cache_provider.dart';
import 'package:usue_schedule/shared/services/message_service.dart';
import '../../schedule/models/schedule_model.dart';

class CacheManagerScreen extends StatefulWidget {
  static route(CacheProvider cacheProvider) => MaterialPageRoute(
      builder: (_) => CacheManagerScreen(
            cacheProvider: cacheProvider,
          ));

  final CacheProvider cacheProvider;
  const CacheManagerScreen({super.key, required this.cacheProvider});

  @override
  State<CacheManagerScreen> createState() => _CacheManagerScreenState();
}

class _CacheManagerScreenState extends State<CacheManagerScreen> {
  List<ScheduleModel> _cachedModels = [];
  Map<String, int> _daysCount = {};
  Map<String, DateTime> _lastUpdated = {};
  String _cacheSize = '0 B';
  bool _isLoading = true;
  Set<String> _selectedModels = {}; // для множественного выбора

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() => _isLoading = true);

    try {
      final available = await widget.cacheProvider.getAvailableCache();
      final models = <ScheduleModel>[];
      final daysCount = <String, int>{};
      final lastUpdated = <String, DateTime>{};

      for (var entry in available.entries) {
        for (var model in entry.value) {
          if (!models.contains(model)) {
            models.add(model);
            // Получаем количество дней для модели
            final days =
                await widget.cacheProvider.getAvailableDaysForModel(model);
            daysCount[model.cacheKey] = days;
            lastUpdated[model.cacheKey] = entry.key;
          }
        }
      }

      // Сортируем по дате последнего обновления (новые сверху)
      models.sort((a, b) {
        final aTime =
            lastUpdated[a.cacheKey] ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            lastUpdated[b.cacheKey] ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      _cacheSize = await widget.cacheProvider.getCacheSizeFormatted();
      setState(() {
        _cachedModels = models;
        _daysCount = daysCount;
        _lastUpdated = lastUpdated;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      MessageService.showErrorSnack('Ошибка загрузки кэша',
          error: error, stackTrace: stackTrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteModel(List<ScheduleModel> models) async {
    _selectedModels.clear();
    await widget.cacheProvider.clearModelsCache(models);

    await _loadCacheInfo().then((_) {
      MessageService.showSnackBar('Удалено ${models.length} кэшей');
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'никогда';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'только что';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление кэшем'),
        actions: [
          if (_selectedModels.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => MessageService.confirmAction(
                title: 'Удалить выбранное',
                message: 'Удалить кэш для ${_selectedModels.length} элементов?',
                onOk: () async {
                  final models = _cachedModels
                      .where(
                        (m) => _selectedModels.contains(m.cacheKey),
                      )
                      .toList();
                  await _deleteModel(models);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (_selectedModels.length == _cachedModels.length) {
                    _selectedModels.clear();
                  } else {
                    _selectedModels =
                        _cachedModels.map((m) => m.cacheKey).toSet();
                  }
                });
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCacheInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cachedModels.isEmpty
              ? _buildEmptyState()
              : _buildCacheList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storage_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Кэш пуст',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь появятся сохраненные расписания',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCacheInfo,
            icon: const Icon(Icons.refresh),
            label: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheList() {
    return Column(
      children: [
        // Статистика
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.storage,
                value: _cachedModels.length.toString(),
                label: 'Расписаний',
                color: Colors.blue,
              ),
              _buildStatItem(
                icon: Icons.calendar_month,
                value: _daysCount.values.fold(0, (a, b) => a + b).toString(),
                label: 'Дней',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.data_usage,
                value: _cacheSize,
                label: 'Объем',
                color: Colors.orange,
              ),
            ],
          ),
        ),

        // Список кэшированных моделей
        Expanded(
          child: ListView.builder(
            itemCount: _cachedModels.length,
            itemBuilder: (context, index) {
              final model = _cachedModels[index];
              final isSelected = _selectedModels.contains(model.cacheKey);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: model.requestType.color, width: 2)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок с иконкой и типом
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: model.requestType.color
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              model.requestType.icon,
                              color: model.requestType.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.queryValue,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  model.requestType.text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            fillColor: isSelected
                                ? WidgetStateProperty.all(
                                    model.requestType.color)
                                : null,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedModels.add(model.cacheKey);
                                } else {
                                  _selectedModels.remove(model.cacheKey);
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Информация о кэше
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.calendar_today,
                            text: '${_daysCount[model.cacheKey] ?? 0} дней',
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.access_time,
                            text: _formatDate(_lastUpdated[model.cacheKey]),
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Кнопки действий
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedModels.isEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                spacing: 8,
                                children: [
                                  // TextButton.icon(
                                  //   onPressed: () => _deleteOldForModel(model),
                                  //   icon: const Icon(Icons.delete_sweep, size: 18),
                                  //   label: const Text('Удалить старые'),
                                  //   style: TextButton.styleFrom(
                                  //     foregroundColor: Colors.orange.shade700,
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _deleteModel([model]),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Удалить'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        foregroundColor: Colors.red.shade700,
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
