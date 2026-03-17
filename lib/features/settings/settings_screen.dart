import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:usue_schedule/core/constants.dart';
import 'package:usue_schedule/features/schedule/models/schedule_view_type.dart';
import 'package:usue_schedule/features/settings/controlles/settings_cubit.dart';
import 'package:usue_schedule/shared/widgets/custom_list_tile.dart';

import '../../core/theme/schedule_styles.dart';
import '../../dependencies/widgets/dependencies_scope.dart';
import '../cache/presentation/cache_manager_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsCubit settingsCubit = context.watch<SettingsCubit>();
    final theme = Theme.of(context);
    final cacheProvider =
        DependenciesScope.of(context).apiService.cacheProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: ScheduleStyles.linearBackgroundDecoration(context),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: [
            _Section(
              icon: Icons.palette,
              title: 'Костомизация',
              children: [
                CustomListTile(
                  title: 'Тема приложения',
                  trailing: DropdownButton<ThemeMode>(
                    underline: const SizedBox.shrink(),
                    focusColor: Colors.transparent,
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurface,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: theme.colorScheme.surface,
                    value: settingsCubit.state.themeMode,
                    onChanged: settingsCubit.setThemeMode,
                    items: ThemeMode.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    e.params.icon,
                                    size: 18,
                                    color: e.params.color,
                                  ),
                                  Text(e.params.text),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                CustomListTile(
                  title: 'Вид расписания',
                  subTitle: "Тип отображения расписания по умолчанию",
                  trailing: DropdownButton<ScheduleViewType>(
                    underline: const SizedBox.shrink(),
                    focusColor: Colors.transparent,
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurface,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: theme.colorScheme.surface,
                    value: settingsCubit.state.viewType,
                    onChanged: settingsCubit.setViewType,
                    items: ScheduleViewType.values
                        .where((v) => v != ScheduleViewType.custom)
                        .map((viewType) => DropdownMenuItem(
                              value: viewType,
                              child: Text(viewType.text),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            if (cacheProvider != null)
              _Section(
                icon: Icons.storage,
                title: 'Управление данными',
                children: [
                  CustomListTile(
                      leadingIcon: Icons.delete_sweep,
                      title: 'Очистить кэш',
                      subTitle: 'Удалить данные расписаний',
                      onTap: () {
                        Navigator.push(
                            context,
                            CacheManagerScreen.route(
                                cacheProvider,
                                DependenciesScope.of(context)
                                    .scheduleCubit
                                    .onDeleteCache));
                      }),
                ],
              ),
            _Section(
              icon: Icons.info,
              title: 'О приложении',
              children: [
                CustomListTile(
                  leadingIcon: Icons.info_outline,
                  title: 'О приложении',
                  subTitle: 'Версия, лицензия, разработчики',
                  onTap: () => _showAboutDialog(context),
                ),
                CustomListTile(
                  leadingIcon: Icons.star,
                  title: 'Оценить приложение',
                  subTitle: 'Оставьте отзыв в магазине',
                  onTap: () async =>
                      await launchUrl(Uri.parse(Constants.appLinkRuStore)),
                ),
                CustomListTile(
                  leadingIcon: Icons.share,
                  title: 'Поделиться приложением',
                  subTitle: 'Рекомендовать друзьям',
                  onTap: _shareApp,
                ),
              ],
            ),
            _Section(
              icon: Icons.contact_support,
              title: 'Контакты и поддержка',
              children: [
                CustomListTile(
                  leadingIcon: Icons.email,
                  title: 'Обратная связь',
                  subTitle: 'Написать разработчикам',
                  onTap: () => _sendEmail(context),
                ),
                CustomListTile(
                  leadingIcon: Icons.bug_report,
                  title: 'Сообщить об ошибке',
                  subTitle: 'Нашли баг? Сообщите нам через Telegram',
                  onTap: () async =>
                      await launchUrlString(Constants.telegramContact),
                ),
                CustomListTile(
                  leadingIcon: Icons.group,
                  title: 'Другие проекты',
                  subTitle: 'Посмотреть другие приложения',
                  onTap: () async =>
                      await launchUrlString(Constants.developerLinkRuStore),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Center(
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    Constants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Версия ${Constants.version} • Сборка ${Constants.buildNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    Constants.sign,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          spacing: 10,
          children: [
            Icon(Icons.school, color: Colors.blue),
            Text('О приложении'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              const Text(
                Constants.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Версия: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: '${Constants.version}\n'),
                    TextSpan(
                      text: 'Сборка: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: Constants.buildNumber),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    Expanded(
                      child: Text(
                        'Важное примечание',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: const [
                    TextSpan(
                      text: 'Это приложение является ',
                    ),
                    TextSpan(
                      text: 'неофициальным клиентом ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                        text:
                            """для просмотра расписания УрГЭУ (USUE) и было создано в рамках учебного проекта.
Статус: Студенческий проект
Разработчик: ${Constants.author}
Источник данных: Официальный сайт расписания УрГЭУ"""),
                  ])),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      children: const [
                    TextSpan(
                      text: '⚖️ Лицензия: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: 'BSD 3-Clause',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ])),
              const _LinkCard(
                  'Офицальный сайт расписания', Constants.usueScheduleLink),
              const _LinkCard(
                  'Исходный код приложения на GitHub', Constants.githubLink),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(ShareParams(
      text: Constants.shareText,
      subject: 'Удобное расписание УрГЭУ',
    ));
  }

  Future<void> _sendEmail(BuildContext context) async {
    final email = Uri(
      scheme: 'mailto',
      path: 'development.flutter.contact@gmail.com',
      queryParameters: {
        'subject': 'Обратная связь ${Constants.appName}',
        'body': 'Здравствуйте!\n\n',
      },
    );

    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    }
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _Section(
      {required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(spacing: 10, children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: theme.colorScheme.primary)),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
        ...children,
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String title;
  final String url;
  const _LinkCard(this.title, this.url);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2))),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700)),
                  Text(url,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                      overflow: TextOverflow.ellipsis),
                ])),
            const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
          ]),
        ),
      );
}

extension on ThemeMode {
  ({String text, Color color, IconData icon}) get params {
    switch (this) {
      case ThemeMode.light:
        return (text: 'Светлая', color: Colors.orange, icon: Icons.light_mode);
      case ThemeMode.dark:
        return (text: 'Тёмная', color: Colors.blueGrey, icon: Icons.dark_mode);
      case ThemeMode.system:
        return (
          text: 'Системная',
          color: Colors.blue,
          icon: Icons.settings_suggest
        );
    }
  }
}
