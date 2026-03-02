import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:usue_schedule/core/constants.dart';
import 'package:usue_schedule/controlles/settings_cubit.dart';
import 'package:usue_schedule/presentation/widgets/custom_list_tile.dart';

import '../core/theme/schedule_styles.dart';
import '../dependencies/widgets/dependencies_scope.dart';
import 'cache_manager_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsCubit settingsCubit = context.watch<SettingsCubit>();
    final theme = Theme.of(context);

    Widget buildSettingTile({
      IconData? icon,
      required String title,
      String? subtitle,
      VoidCallback? onTap,
      Widget? trailing,
    }) =>
        CustomListTile(
            mainColor: theme.colorScheme.primary,
            title: title,
            subTitle: subtitle,
            leadingIcon: icon,
            trailing: trailing,
            onTap: onTap);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: ScheduleStyles.linearBackgroundDecoration(context),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: [
            _buildSection(
              context,
              icon: Icons.palette,
              title: 'Внешний вид',
              children: [
                buildSettingTile(
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
              ],
            ),
            _buildSection(
              context,
              icon: Icons.storage,
              title: 'Управление данными',
              children: [
                buildSettingTile(
                    icon: Icons.delete_sweep,
                    title: 'Очистить кэш',
                    subtitle: 'Удалить данные расписаний',
                    onTap: () {
                      final cacheProvider = DependenciesScope.of(context)
                          .apiService
                          .cacheProvider;
                      if (cacheProvider != null) {
                        Navigator.push(
                            context, CacheManagerScreen.route(cacheProvider));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Кеш не обнаружен.")));
                      }
                    }),
              ],
            ),
            _buildSection(
              context,
              icon: Icons.info,
              title: 'О приложении',
              children: [
                buildSettingTile(
                  icon: Icons.info_outline,
                  title: 'О приложении',
                  subtitle: 'Версия, лицензия, разработчики',
                  onTap: () => _showAboutDialog(context),
                ),
                buildSettingTile(
                  icon: Icons.star,
                  title: 'Оценить приложение',
                  subtitle: 'Оставьте отзыв в магазине',
                  onTap: _rateApp,
                ),
                buildSettingTile(
                  icon: Icons.share,
                  title: 'Поделиться приложением',
                  subtitle: 'Рекомендовать друзьям',
                  onTap: _shareApp,
                ),
              ],
            ),
            _buildSection(
              context,
              icon: Icons.contact_support,
              title: 'Контакты и поддержка',
              children: [
                buildSettingTile(
                  icon: Icons.email,
                  title: 'Обратная связь',
                  subtitle: 'Написать разработчикам',
                  onTap: () => _sendEmail(context),
                ),
                buildSettingTile(
                  icon: Icons.bug_report,
                  title: 'Сообщить об ошибке',
                  subtitle: 'Нашли баг? Сообщите нам через Telegram',
                  onTap: () async =>
                      await launchUrlString(Constants.telegramContact),
                ),
                buildSettingTile(
                  icon: Icons.group,
                  title: 'Другие проекты',
                  subtitle: 'Посмотреть другие приложения',
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

  Widget _buildSection(
    BuildContext context, {
    IconData? icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            spacing: 10,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.blue),
            SizedBox(width: 12),
            Text('О приложении'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Text(
                Constants.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                  children: [
                    TextSpan(
                      text: 'Версия: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: '${Constants.version}\n'),
                    TextSpan(
                      text: 'Сборка: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
                      children: [
                    const TextSpan(
                      text: 'Это приложение является ',
                    ),
                    const TextSpan(
                      text: 'неофициальным клиентом ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const TextSpan(
                      text: 'для просмотра расписания УрГЭУ (USUE) '
                          'и было создано в рамках учебного проекта.\n',
                    ),
                    const TextSpan(
                      text: 'Статус: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: 'Студенческий проект\n'),
                    const TextSpan(
                      text: 'Разработчик: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: '${Constants.author}\n'),
                    const TextSpan(
                      text: 'Источник данных: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(
                      text: 'Официальный сайт расписания УрГЭУ',
                    ),
                  ])),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      children: const [
                    TextSpan(
                      text: '⚖️ ',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextSpan(
                      text: 'Лицензия: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: 'BSD 3-Clause',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ])),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(Constants.usueScheduleLink));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Офицальный сайт расписания',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              Constants.usueScheduleLink,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse(Constants.githubLink));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Исходный код приложения на GitHub',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              Constants.githubLink,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
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

  Future<void> _rateApp() async {
    await launchUrl(Uri.parse(Constants.appLinkRuStore));
  }

  Future<void> _shareApp() async {
    final text = '''
📅 ${Constants.appName} - твое расписание в телефоне!

Скачивай приложение для удобного просмотра расписания УрГЭУ:
• Все группы, преподаватели, аудитории
• Умные фильтры и поиск
• Автообновление данных

➡️ Ссылка: ${Constants.appLinkRuStore}

Поделись с коллегами! 🎓''';

    await SharePlus.instance.share(ShareParams(
      text: text,
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
