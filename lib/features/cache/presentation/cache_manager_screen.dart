import 'package:flutter/material.dart';
import 'package:usue_schedule/features/cache/provider/cache_provider.dart';
import 'package:usue_schedule/shared/services/message_service.dart';
import '../../schedule/models/schedule_model.dart';

class CacheManagerScreen extends StatefulWidget {
  static route(CacheProvider cacheProvider,
          Future<void> Function(List<ScheduleModel> model) onDelete) =>
      MaterialPageRoute(
          builder: (_) => CacheManagerScreen(
              cacheProvider: cacheProvider, onDelete: onDelete));

  final CacheProvider cacheProvider;
  final Future<void> Function(List<ScheduleModel> model) onDelete;

  const CacheManagerScreen(
      {super.key, required this.cacheProvider, required this.onDelete});

  @override
  State<CacheManagerScreen> createState() => _CacheManagerScreenState();
}

class _CacheManagerScreenState extends State<CacheManagerScreen> {
  List<
      ({
        ScheduleModel model,
        int daysCount,
        DateTime lastUpdated,
      })> _cacheInfo = [];
  String _cacheSize = '0 B';
  bool _isLoading = true;
  Set<String> _selectedModels = {};

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() => _isLoading = true);

    try {
      final cacheInfo = await widget.cacheProvider.getCacheInfo();

      _cacheInfo = cacheInfo.info;
      _cacheSize = cacheInfo.formattedSize;
    } catch (error, stackTrace) {
      MessageService.showErrorSnack('Ошибка загрузки кэша',
          error: error, stackTrace: stackTrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteModels(List<ScheduleModel> models) async {
    if (models.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await widget.onDelete(models);
      await widget.cacheProvider.clearModelsCache(models);
      await _loadCacheInfo();

      if (mounted) {
        MessageService.showSnackBar(
            'Удалено ${models.length} кэш${models.length > 1 ? 'ей' : 'а'}');
      }
    } catch (error, stackTrace) {
      MessageService.showErrorSnack('Ошибка удаления',
          error: error, stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${_declension(difference.inDays, "день", "дня", "дней")} назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${_declension(difference.inHours, "час", "часа", "часов")} назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${_declension(difference.inMinutes, "минуту", "минуты", "минут")} назад';
    } else {
      return 'только что';
    }
  }

  String _declension(int number, String one, String two, String five) {
    if (number % 10 == 1 && number % 100 != 11) return one;
    if (number % 10 >= 2 &&
        number % 10 <= 4 &&
        (number % 100 < 10 || number % 100 >= 20)) {
      return two;
    }
    return five;
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
              onPressed: () => _confirmDeleteSelected(),
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectAll,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCacheInfo,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cacheInfo.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildStatsBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _cacheInfo.length,
            itemBuilder: (context, index) => _buildCacheItem(_cacheInfo[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final totalDays = _cacheInfo.fold(0, (sum, info) => sum + info.daysCount);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            value: _cacheInfo.length.toString(),
            label: 'Расписаний',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.calendar_month,
            value: totalDays.toString(),
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
    );
  }

  Widget _buildCacheItem(
      ({ScheduleModel model, int daysCount, DateTime lastUpdated}) info) {
    final isSelected = _selectedModels.contains(info.model.cacheKey);
    final color = info.model.requestType.color;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            info.model.requestType.icon,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.model.queryValue,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                info.model.requestType.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          icon: Icons.calendar_today,
                          text:
                              '${info.daysCount} ${_declension(info.daysCount, "день", "дня", "дней")}',
                          color: Colors.grey.shade700,
                        ),
                        _buildInfoChip(
                          icon: Icons.access_time,
                          text: _formatDate(info.lastUpdated),
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ])),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Checkbox(
                    value: isSelected,
                    fillColor:
                        isSelected ? WidgetStateProperty.all(color) : null,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedModels.add(info.model.cacheKey);
                        } else {
                          _selectedModels.remove(info.model.cacheKey);
                        }
                      });
                    },
                  ),
                  if (_selectedModels.isEmpty)
                    IconButton(
                      onPressed: () => _deleteModels([info.model]),
                      icon: const Icon(Icons.delete_outline),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                    ),
                ],
              )
            ],
          )),
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

  void _confirmDeleteSelected() {
    final count = _selectedModels.length;
    MessageService.confirmAction(
      title: 'Удалить выбранное',
      message: 'Удалить кэш для $count элементов?',
      onOk: () async {
        final models = _cacheInfo
            .where((info) => _selectedModels.contains(info.model.cacheKey))
            .map((info) => info.model)
            .toList();
        await _deleteModels(models);
        _selectedModels.clear();
      },
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedModels.length == _cacheInfo.length) {
        _selectedModels.clear();
      } else {
        _selectedModels = _cacheInfo.map((info) => info.model.cacheKey).toSet();
      }
    });
  }
}
