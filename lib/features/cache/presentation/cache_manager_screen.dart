import 'package:material_ui/material_ui.dart';
import 'package:usue_schedule/features/cache/provider/cache_provider.dart';
import 'package:usue_schedule/shared/services/message_service.dart';
import '../../schedule/models/schedule_model.dart';

class CacheManagerScreen extends StatefulWidget {
  const CacheManagerScreen(
      {super.key, required this.cacheProvider, required this.onDelete});

  static route(CacheProvider cacheProvider,
          Future<void> Function(List<ScheduleModel> model) onDelete) =>
      MaterialPageRoute(
          builder: (_) => CacheManagerScreen(
              cacheProvider: cacheProvider, onDelete: onDelete));

  final CacheProvider cacheProvider;
  final Future<void> Function(List<ScheduleModel> model) onDelete;

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
  Set<String> selectedModels = {};

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
      await widget.onDelete(models).then(
          (_) async => await widget.cacheProvider.clearModelsCache(models));

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
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          if (_isLoading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
          else if (_cacheInfo.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
          else ...[
            _buildStatsSliver(),
            _buildCacheList(),
          ],
        ],
      ),
      floatingActionButton: selectedModels.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _confirmDeleteSelected,
              label: Text('Удалить (${selectedModels.length})'),
              icon: const Icon(Icons.delete_sweep),
              backgroundColor: Colors.redAccent,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        leading: selectedModels.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => selectedModels.clear()),
              )
            : null,
        title: const Text('Управление кэшем'),
        actions: [
          if (_cacheInfo.isNotEmpty && selectedModels.isEmpty)
            TextButton(
              onPressed: _confirmClearAll,
              child: const Text('Очистить всё',
                  style: TextStyle(color: Colors.red)),
            ),
        ],
      );

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
            children: [
              Expanded(child: _buildStatTile(_cacheSize, 'Объем')),
              Container(
                width: 1,
                height: 32,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.4),
              ),
              Expanded(
                  child:
                      _buildStatTile(_cacheInfo.length.toString(), 'Записей')),
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
            fontSize: 20,
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
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList.separated(
        itemCount: _cacheInfo.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 72,
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final info = _cacheInfo[index];
          final isSelected = selectedModels.contains(info.model.cacheKey);

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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor:
                    info.model.scheduleType.color.withValues(alpha: 0.1),
                child: Icon(info.model.scheduleType.icon,
                    color: info.model.scheduleType.color, size: 20),
              ),
              title: Text(
                info.model.queryValue,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${info.daysCount} дн.  •  ${_formatDate(info.model.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              trailing: selectedModels.isNotEmpty
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelect(info.model.cacheKey),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
              onTap: () => _toggleSelect(info.model.cacheKey),
              onLongPress: () => _toggleSelect(info.model.cacheKey),
            ),
          );
        },
      ),
    );
  }

  void _toggleSelect(String key) {
    setState(() {
      if (selectedModels.contains(key)) {
        selectedModels.remove(key);
      } else {
        selectedModels.add(key);
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
            const SizedBox(height: 20),
            Text(
              'Кэш пуст',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь появятся сохраненные расписания',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: _loadCacheInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSelected() => MessageService.confirmAction(
        title: 'Удалить выбранное',
        message: 'Удалить кэш для ${selectedModels.length} элементов?',
        onOk: () async {
          final models = _cacheInfo
              .where((info) => selectedModels.contains(info.model.cacheKey))
              .map((info) => info.model)
              .toList();
          await _deleteModels(models);
          selectedModels.clear();
        },
      );

  void _confirmClearAll() => MessageService.confirmAction(
        title: 'Очистить весь кэш',
        message: 'Удалить все сохранённые расписания (${_cacheInfo.length})?',
        onOk: () =>
            _deleteModels(_cacheInfo.map((info) => info.model).toList()),
      );
}
