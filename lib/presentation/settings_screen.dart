import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:usue_schedule/core/constants.dart';
import 'package:usue_schedule/controlles/settings_cubit.dart';
import 'package:usue_schedule/presentation/widgets/borde_box.dart';

import '../core/theme/schedule_styles.dart';
import 'cache_manager_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsCubit settingsCubit = context.watch<SettingsCubit>();
    ThemeMode themeMode = settingsCubit.state.themeMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: ScheduleStyles.linearBackgroundDecoration(context),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              context,
              icon: Icons.palette,
              title: 'Внешний вид',
              children: [
                BorderBox(
                  child: ListTile(
                    title: const Text('Тема приложения'),
                    trailing: DropdownButton<ThemeMode>(
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.onSurface,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: theme.colorScheme.surface,
                      value: themeMode,
                      onChanged: settingsCubit.setThemeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.light_mode,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const Text('Светлая'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.dark_mode,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const Text('Тёмная'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.settings_suggest,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const Text('Системная'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            _buildSection(
              context,
              icon: Icons.storage,
              title: 'Управление данными',
              children: [
                _buildSettingTile(context,
                    icon: Icons.delete_sweep,
                    title: 'Очистить кэш',
                    subtitle: 'Удалить данные расписаний',
                    onTap: () =>
                        Navigator.push(context, CacheManagerScreen.route())),
              ],
            ),
            SizedBox(height: 5),
            _buildSection(
              context,
              icon: Icons.info,
              title: 'О приложении',
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'О приложении',
                  subtitle: 'Версия, лицензия, разработчики',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.star,
                  title: 'Оценить приложение',
                  subtitle: 'Оставьте отзыв в магазине',
                  onTap: _rateApp,
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.share,
                  title: 'Поделиться приложением',
                  subtitle: 'Рекомендовать друзьям',
                  onTap: _shareApp,
                ),
              ],
            ),
            SizedBox(height: 5),
            _buildSection(
              context,
              icon: Icons.contact_support,
              title: 'Контакты и поддержка',
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.email,
                  title: 'Обратная связь',
                  subtitle: 'Написать разработчикам',
                  onTap: () => _sendEmail(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.bug_report,
                  title: 'Сообщить об ошибке',
                  subtitle: 'Нашли баг? Сообщите нам',
                  onTap: () => _reportBug(context),
                ),
                _buildSettingTile(
                  context,
                  icon: Icons.group,
                  title: 'Другие проекты',
                  subtitle: 'Посмотреть другие приложения',
                  onTap: _showOtherProjects,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    Constants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Версия ${Constants.version} • Сборка ${Constants.buildNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
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
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: child,
            )),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: BorderBox(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ],
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
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
              const SizedBox(height: 8),
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
                    TextSpan(text: '${Constants.buildNumber}\n\n'),
                    const TextSpan(
                      text: 'Это приложение является ',
                    ),
                    TextSpan(
                      text: 'неофициальным клиентом ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const TextSpan(
                      text: 'для просмотра расписания УрГЭУ (USUE) '
                          'и было создано в рамках учебного проекта.\n\n',
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
                      text: 'Официальный сайт расписания УрГЭУ\n',
                    ),
                  ],
                ),
              ),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                  text: '⚖️ ',
                  style: TextStyle(fontSize: 16),
                ),
                const TextSpan(
                  text: 'Лицензия: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(
                  text: 'Проприетарная (закрытая)',
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
                            const SizedBox(height: 2),
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

  Future<void> _reportBug(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сообщить об ошибке'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Нашли что-то? Опишите проблему, которую вы обнаружили по телеграмм.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await launchUrlString(Constants.telegramContact);
              } on Object catch (error, stackTrace) {
                Error.safeToString(error);
                stackTrace.toString();
                rethrow;
              } finally {
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOtherProjects() async {
    final url = Uri.parse(Constants.developerLinkRuStore);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
