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
      })> _cacheInfo = [];
  String _cacheSize = '0 B';
  bool _isLoading = true;
  final Set<String> _selectedModels = {};

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

      if (mounted) {
        MessageService.showSnackBar(
            'Удалено ${models.length} кэш${models.length > 1 ? 'ей' : 'а'}');
      }
    } catch (error, stackTrace) {
      MessageService.showErrorSnack('Ошибка удаления',
          error: error, stackTrace: stackTrace);
    } finally {
      await _loadCacheInfo();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "null";
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
      // Используем CustomScrollView для приятного эффекта схлопывания шапки
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_isLoading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
          else if (_cacheInfo.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else ...[
            _buildStatsSliver(),
            _buildCacheList(),
          ],
        ],
      ),
      // Кнопка удаления появляется только когда есть выбор
      floatingActionButton: _selectedModels.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _confirmDeleteSelected,
              label: Text('Удалить выбранное (${_selectedModels.length})'),
              icon: const Icon(Icons.delete_sweep),
              backgroundColor: Colors.redAccent,
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar.large(
      title: const Text('Управление кэшем'),
      actions: [
        if (_cacheInfo.isNotEmpty && _selectedModels.isEmpty)
          TextButton(
            onPressed: () {
              //
            },
            child:
                const Text('Очистить всё', style: TextStyle(color: Colors.red)),
          ),
        if (_selectedModels.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedModels.clear()),
          ),
      ],
    );
  }

  Widget _buildStatsSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatTile(_cacheSize, 'Объем'),
              _buildStatTile(_cacheInfo.length.toString(), 'Записей'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCacheList() {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100), // Чтобы FAB не перекрывал
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final info = _cacheInfo[index];
            final isSelected = _selectedModels.contains(info.model.cacheKey);

            // Добавляем Dismissible для быстрого удаления свайпом
            return Dismissible(
              key: Key(info.model.cacheKey),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _deleteModels([info.model]),
              child: ListTile(
                selected: isSelected,
                leading: CircleAvatar(
                  backgroundColor:
                      info.model.requestType.color.withValues(alpha: 0.1),
                  child: Icon(info.model.requestType.icon,
                      color: info.model.requestType.color, size: 20),
                ),
                title: Text(info.model.queryValue,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                    '${info.daysCount} дн. • ${_formatDate(info.model.lastUpdated)}'),
                trailing: _selectedModels.isNotEmpty
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSelect(info.model.cacheKey),
                      )
                    : null,
                onTap: () {
                  if (_selectedModels.isNotEmpty) {
                    _toggleSelect(info.model.cacheKey);
                  } else {
                    // Можно открыть детали или просто выбирать по тапу
                    _toggleSelect(info.model.cacheKey);
                  }
                },
                onLongPress: () => _toggleSelect(info.model.cacheKey),
              ),
            );
          },
          childCount: _cacheInfo.length,
        ),
      ),
    );
  }

  void _toggleSelect(String key) {
    setState(() {
      if (_selectedModels.contains(key)) {
        _selectedModels.remove(key);
      } else {
        _selectedModels.add(key);
      }
    });
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
}
