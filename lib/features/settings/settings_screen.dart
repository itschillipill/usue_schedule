import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:usue_schedule/core/constants.dart';
import 'package:usue_schedule/features/schedule/models/schedule_view_type.dart';
import 'package:usue_schedule/features/settings/controllers/settings_cubit.dart';
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
            SizedBox(height: 10),
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
            SizedBox(height: 10),
            _Section(
              icon: Icons.more,
              title: 'Дополнительная информация',
              children: [
                CustomListTile(
                  leadingIcon: Icons.info_outline,
                  title: 'О приложении и контакты',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AboutAppScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: ScheduleStyles.linearBackgroundDecoration(context),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'О приложении',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                        theme.colorScheme.secondary.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildInfoCard(context),
                  const SizedBox(height: 24),

                  _ModernSection(
                    title: 'Источники',
                    icon: Icons.code_outlined,
                    children: [
                      _LinkTile(
                        title: 'Официальный сайт УрГЭУ',
                        url: Constants.usueScheduleLink,
                        icon: Icons.school_outlined,
                      ),
                      _LinkTile(
                        title: 'Исходный код',
                        url: Constants.githubLink,
                        icon: Icons.code,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _ModernSection(
                    title: 'Обратная связь',
                    icon: Icons.contact_support_outlined,
                    children: [
                      _ContactTile(
                        icon: Icons.email_outlined,
                        title: 'Электронная почта',
                        value: 'development.flutter.contact@gmail.com',
                        onTap: () => _sendEmail(context),
                      ),
                      _ContactTile(
                        icon: Icons.telegram,
                        title: 'Telegram',
                        onTap: () => launchUrlString(Constants.telegramContact),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _ModernSection(
                    title: 'Информация',
                    icon: Icons.info_outline,
                    children: [
                      _ActionTile(
                        icon: Icons.verified_outlined,
                        title: 'Лицензии',
                        description: 'Информация о лицензиях ПО',
                        onTap: () => _showLicenseDialog(context),
                      ),
                      _ActionTile(
                        icon: Icons.share_outlined,
                        title: 'Поделиться',
                        description: 'Расскажите друзьям о приложении',
                        onTap: () => SharePlus.instance.share(ShareParams(
                          text: Constants.shareText,
                          subject: 'Удобное расписание УрГЭУ',
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Футер с версией
                  _buildFooter(context),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Это приложение является ',
                  ),
                  TextSpan(
                    text: 'неофициальным клиентом ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const TextSpan(
                    text: 'для просмотра расписания УрГЭУ (CИНХ). '
                        'Создано для удобного слежения за расписанием студентов и преподавателей.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context) async {
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

  void _showLicenseDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: Constants.appName,
      applicationVersion: Constants.version,
      applicationLegalese: '© 2026 ${Constants.author}',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.school, size: 32, color: Colors.white),
      ),
    );
  }
}

Widget _buildFooter(BuildContext context) {
  final theme = Theme.of(context);

  return Column(
    children: [
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  Constants.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Версия ${Constants.version} (${Constants.buildNumber})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Современная секция с заголовком
class _ModernSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ModernSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

// Улучшенная плитка действия
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Улучшенная плитка ссылки
class _LinkTile extends StatelessWidget {
  final String title;
  final String url;
  final IconData icon;

  const _LinkTile({
    required this.title,
    required this.url,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        splashColor: Colors.blue.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      url,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: theme.colorScheme.outline,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Улучшенная контактная плитка
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (value != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        value!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
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
