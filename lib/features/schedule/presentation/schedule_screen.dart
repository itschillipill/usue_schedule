// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart' show SystemNavigator;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:usue_schedule/core/theme/theme.dart';
import 'package:usue_schedule/dependencies/widgets/dependencies_scope.dart';
import 'package:usue_schedule/features/schedule/widgets/s.dart';

import '../controllers/schedule_cubit.dart';
import '../controllers/schedule_view_provider.dart';
import '../models/schedule_model.dart';
import '../../../shared/services/message_service.dart';
import 'add_schedule_screen.dart';
import 'show_schedule_screen.dart';
import '../widgets/schedule_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  String query = "";
  bool isTextFieldVisible = false;
  late MyScheduleCubit scheduleCubit;

  static const duration = Duration(milliseconds: 300);
  static const fromRadius = BorderRadius.all(Radius.circular(20));
  static const toRadius = BorderRadius.zero;

  final Map<int, GlobalKey> _cardKeys = {};
  final _addButtonKey = GlobalKey();

  RenderBox get _overlayBox {
    final overlay = Overlay.of(context);
    return overlay.context.findRenderObject()! as RenderBox;
  }

  @override
  void initState() {
    super.initState();
    scheduleCubit = DependenciesScope.of(context).scheduleCubit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (scheduleCubit.state.current case final current?) {
        openSchedule(current, skipAnim: true);
      }
    });
  }

  Rect _addButtonRect() {
    final renderObject =
        _addButtonKey.currentContext!.findRenderObject()! as RenderBox;

    final globalTopLeft = renderObject.localToGlobal(Offset.zero);
    final localTopLeft = _overlayBox.globalToLocal(globalTopLeft);

    return localTopLeft & renderObject.size;
  }

  Rect _cardRect(ScheduleModel item) {
    final cardContext = _cardKeys[item.hashCode]?.currentContext;

    if (cardContext == null) {
      throw StateError(
        'Card $item is not mounted. '
        'Make sure the card is visible in the list.',
      );
    }

    final box = cardContext.findRenderObject()! as RenderBox;

    final globalTopLeft = box.localToGlobal(Offset.zero);
    final localTopLeft = _overlayBox.globalToLocal(globalTopLeft);

    return localTopLeft & box.size;
  }

  Rect _tryGetCardRect(ScheduleModel item, Rect fallback) {
    try {
      final cardContext = _cardKeys[item.hashCode]?.currentContext;
      if (cardContext != null) {
        final box = cardContext.findRenderObject() as RenderBox?;
        if (box != null && box.attached) {
          final globalTopLeft = box.localToGlobal(Offset.zero);
          final localTopLeft = _overlayBox.globalToLocal(globalTopLeft);
          return localTopLeft & box.size;
        }
      }
    } catch (_) {}
    return fallback;
  }

  void openSchedule(ScheduleModel item,
      {bool skipAnim = false, Rect? initialRect}) async {
    final initialFromRect = initialRect ??
        (skipAnim ? Offset.zero & _overlayBox.size : _cardRect(item));

    if (mounted) {
      Navigator.of(context).push<void>(
        PageRouteBuilder<void>(
          transitionDuration: skipAnim ? Duration.zero : duration,
          reverseTransitionDuration: duration,
          pageBuilder: (routeContext, animation, _) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (didPop) return;

                if (scheduleCubit.state.current == item) {
                  SystemNavigator.pop();
                } else {
                  Navigator.of(routeContext).pop();
                }
              },
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final progress = Curves.easeIn.transform(
                    animation.value,
                  );

                  final contentOpacity = Curves.easeIn.transform(
                    ((progress - 0.15) / 0.45).clamp(0.0, 1.0),
                  );
                  final deps = DependenciesScope.of(context);

                  return ChangeNotifierProvider(
                    create: (_) => ScheduleViewProvider(
                      apiService: deps.apiService,
                      onUpdate: deps.scheduleCubit.updateSchedule,
                      params: item,
                      onSave: deps.scheduleCubit.addSchedule,
                      gColors: context.groupColors,
                      savedSchedule: scheduleCubit.contains(item),
                      initialViewType: deps.settingsCubit.state.viewType,
                    ),
                    child: ShowScheduleScreen(
                      contentOpacity: contentOpacity,
                      onSwitch: () => Navigator.of(routeContext).pop(),
                    ),
                  );
                },
              ),
            );
          },
          transitionsBuilder: (ctx, animation, _, child) {
            if (animation.status == AnimationStatus.completed) {
              return child;
            }

            final progress = Curves.easeIn.transform(
              animation.value,
            );

            final overlayBox =
                Overlay.of(ctx).context.findRenderObject()! as RenderBox;
            final toRect = Offset.zero & overlayBox.size;
            final currentFromRect = _tryGetCardRect(item, initialFromRect);

            final rect = Rect.lerp(
              currentFromRect,
              toRect,
              progress,
            )!;

            final radius = BorderRadius.lerp(
              fromRadius,
              toRadius,
              progress,
            )!;

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    borderRadius: radius,
                    child: child,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (_) {
          if (isTextFieldVisible) {
            setState(() {
              isTextFieldVisible = false;
              query = "";
            });
          } else if (scheduleCubit.state.current case final current?) {
            openSchedule(current);
          } else {
            SystemNavigator.pop();
          }
        },
        child: BlocBuilder<MyScheduleCubit, MyScheduleState>(
          bloc: scheduleCubit,
          builder: (context, state) {
            final allSchedules = List.of(state.schedules)..sort();
            final current = state.current;
            final otherSchedules =
                allSchedules.where((s) => s != current).toList();

            final filteredOtherSchedules = otherSchedules
                .where((schedule) => schedule.queryValue
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList();

            final bool isCurrentMatch = current == null ||
                current.queryValue.toLowerCase().contains(query.toLowerCase());

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Мои расписания",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                actions: [
                  if (!isTextFieldVisible && allSchedules.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isTextFieldVisible = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                      tooltip: "Поиск",
                    ),
                ],
                centerTitle: true,
              ),
              body: DecoratedBox(
                decoration: context.linearBkgDec,
                child: allSchedules.isNotEmpty
                    ? Column(
                        children: [
                          AnimatedSize(
                            duration: duration,
                            child: isTextFieldVisible
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8),
                                    child: TextField(
                                      onChanged: (value) => setState(() {
                                        query = value;
                                      }),
                                      decoration: InputDecoration(
                                        hintText: "Поиск...",
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => setState(() {
                                            isTextFieldVisible = false;
                                            query = "";
                                          }),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Expanded(
                            child: CustomScrollView(
                              slivers: [
                                if (current != null && isCurrentMatch) ...[
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                                      child: Text(
                                        "Текущее расписание",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ScheduleCard(
                                        key: _cardKeys.putIfAbsent(
                                            current.hashCode, GlobalKey.new),
                                        onTap: () => openSchedule(current),
                                        scheduleModel: current,
                                      ),
                                    ),
                                  ),
                                ],
                                if (filteredOtherSchedules.isNotEmpty) ...[
                                  if (current != null && isCurrentMatch)
                                    const SliverToBoxAdapter(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 12, 8, 4),
                                        child: Text(
                                          "Остальные расписания",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  SliverList.builder(
                                    itemCount: filteredOtherSchedules.length,
                                    itemBuilder: (context, index) {
                                      final schedule =
                                          filteredOtherSchedules[index];
                                      final key = _cardKeys.putIfAbsent(
                                        schedule.hashCode,
                                        GlobalKey.new,
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: ScheduleCard(
                                          key: key,
                                          onTap: () => openSchedule(schedule),
                                          scheduleModel: schedule,
                                          trailing: _buildTrailingMenu(
                                            schedule,
                                            onRemove: (s) {
                                              scheduleCubit
                                                  .removeSchedules([s]);
                                            },
                                            onSetCurrent: scheduleCubit
                                                .setCurrentSchedule,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 80),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : S((
                        Icons.calendar_today_outlined,
                        "Расписаний пока нет",
                        "Добавьте свое первое расписание"
                      )),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: FloatingActionButton(
                key: _addButtonKey,
                onPressed: () async {
                  final newSchedule = await Navigator.push(
                    context,
                    AddScheduleScreen.route(),
                  );
                  if (newSchedule case final schedule? when context.mounted) {
                    openSchedule(schedule,
                        skipAnim: true, initialRect: _addButtonRect());
                  }
                },
                child: const Icon(Icons.add),
              ),
            );
          },
        ));
  }

  Widget _buildTrailingMenu(ScheduleModel schedule,
      {required Function(ScheduleModel schedule) onRemove,
      required Function(ScheduleModel schedule) onSetCurrent}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            MessageService.confirmAction(
                onOk: () => onRemove(schedule),
                title: "Удалить расписание",
                message:
                    "Вы действительно хотите удалить расписание '${schedule.queryValue}'?");
            break;
          case 'set_current':
            MessageService.confirmAction(
                onOk: () => onSetCurrent(schedule),
                title: "Установить расписание как текущее",
                message:
                    "Вы действительно хотите установить расписание '${schedule.queryValue}' как текущее?");
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Удалить', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'set_current',
          child: Row(
            children: [
              Icon(Icons.star_outline, size: 18),
              SizedBox(width: 8),
              Text('Установить как текущий'),
            ],
          ),
        ),
      ],
    );
  }
}
