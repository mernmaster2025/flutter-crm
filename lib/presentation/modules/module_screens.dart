import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/crm_models.dart';
import '../../widgets/crm_components.dart';
import '../../widgets/premium_scaffold.dart';
import '../providers/app_providers.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem('Tasks & meetings', 'Due dates, calendar, recurring work', Icons.task_alt_rounded, '/tasks'),
      _MoreItem('Activities', 'Calls, emails, meetings, notes', Icons.timeline_rounded, '/activities'),
      _MoreItem('Communication', 'Email, SMS, WhatsApp, templates', Icons.mark_email_unread_rounded, '/communication'),
      _MoreItem('Reports', 'Revenue, conversion, team performance', Icons.analytics_rounded, '/reports'),
      _MoreItem('Notifications', 'Push and in-app reminders', Icons.notifications_active_rounded, '/notifications'),
      _MoreItem('Settings', 'Profile, theme, security, preferences', Icons.settings_rounded, '/settings'),
      _MoreItem('Admin', 'Users, teams, permissions, monitoring', Icons.admin_panel_settings_rounded, '/admin'),
    ];
    final columns = MediaQuery.sizeOf(context).width >= 700 ? 2 : 1;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
      children: [
        const SectionHeader(title: 'CRM workspace', subtitle: 'Manage your revenue operations modules'),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: columns == 1 ? 3.45 : 3.2,
          ),
          itemBuilder: (context, index) => _MoreModuleCard(item: items[index]),
        ),
      ],
    );
  }
}

class _MoreModuleCard extends StatelessWidget {
  const _MoreModuleCard({required this.item});

  final _MoreItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      onTap: () => context.go(item.path),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Row(
          children: [
            CircleAvatar(radius: 20, child: Icon(item.icon, size: 20)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class TasksMeetingsScreen extends ConsumerWidget {
  const TasksMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final meetings = ref.watch(meetingsProvider);
    return _ModulePage(
      title: 'Tasks & meetings',
      subtitle: 'Status tracking, recurring tasks, calendar, and reminders',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final title = await _promptText(context, 'Create task', 'Task title');
                    if (title != null && title.trim().isNotEmpty) {
                      await ref.read(tasksControllerProvider.notifier).createDemoTask(title.trim());
                    }
                  },
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Add task'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final title = await _promptText(context, 'Schedule meeting', 'Meeting title');
                    if (title != null && title.trim().isNotEmpty) {
                      await ref.read(meetingsControllerProvider.notifier).createDemoMeeting(title.trim(), 'Customer');
                    }
                  },
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Add meeting'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          tasks.when(
            loading: () => const LoadingSkeleton(rows: 2),
            error: (error, stackTrace) => EmptyState(title: 'Tasks unavailable', message: '$error'),
            data: (items) => _TaskList(tasks: items),
          ),
          const SizedBox(height: AppSpacing.lg),
          meetings.when(
            loading: () => const LoadingSkeleton(rows: 2),
            error: (error, stackTrace) => EmptyState(title: 'Meetings unavailable', message: '$error'),
            data: (items) => _MeetingList(meetings: items),
          ),
        ],
      ),
    );
  }
}

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    return _ModulePage(
      title: 'Activity timeline',
      subtitle: 'Customer interactions across calls, email, meetings, and notes',
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: () async {
              final title = await _promptText(context, 'Create activity', 'Activity title');
              if (title != null && title.trim().isNotEmpty) {
                await ref.read(activitiesControllerProvider.notifier).createLog(
                      ActivityType.note,
                      title.trim(),
                      'Manual activity logged from mobile CRM.',
                    );
              }
            },
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('Log activity'),
          ),
          const SizedBox(height: AppSpacing.lg),
          activities.when(
            loading: () => const LoadingSkeleton(rows: 4),
            error: (error, stackTrace) => EmptyState(title: 'Activities unavailable', message: '$error'),
            data: (items) => GlassPanel(
              child: Column(
                children: [
                  for (final activity in items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bubble_chart_rounded),
                      title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text('${activity.description}\n${activity.actor}'),
                      trailing: IconButton(
                        onPressed: () => ref.read(activitiesControllerProvider.notifier).deleteActivity(activity.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                      isThreeLine: true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunicationScreen extends ConsumerWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communications = ref.watch(communicationsControllerProvider);
    final actions = [
      ('Email campaign', Icons.mail_rounded, CommunicationChannel.email, 'Send personalized templates to a lead segment.'),
      ('SMS reminder', Icons.sms_rounded, CommunicationChannel.sms, 'Deliver follow-up reminders and task nudges.'),
      ('WhatsApp outreach', Icons.chat_rounded, CommunicationChannel.whatsapp, 'Continue high-context customer conversations.'),
      ('Bulk messaging', Icons.campaign_rounded, CommunicationChannel.bulk, 'Queue compliant updates for selected customers.'),
    ];
    return _ModulePage(
      title: 'Communication',
      subtitle: 'Integration-ready messaging history, templates, and outreach',
      child: Column(
        children: [
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassPanel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Icon(action.$2)),
                  title: Text(action.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(action.$4),
                  trailing: FilledButton.tonal(
                    onPressed: () async {
                      await ref.read(communicationsControllerProvider.notifier).createCommunication(
                            action.$3,
                            action.$3 == CommunicationChannel.bulk ? 'Selected segment' : 'customer@example.com',
                            action.$1,
                            action.$4,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${action.$1} queued locally')),
                        );
                      }
                    },
                    child: const Text('Use'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          communications.when(
            loading: () => const LoadingSkeleton(rows: 2),
            error: (error, stackTrace) => EmptyState(title: 'Communication history unavailable', message: '$error'),
            data: (records) => GlassPanel(
              child: Column(
                children: [
                  const SectionHeader(title: 'Queued history', subtitle: 'Local communication records'),
                  const SizedBox(height: AppSpacing.sm),
                  for (final record in records)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.mark_email_read_rounded),
                      title: Text(record.subject, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text('${record.channel.label} • ${record.recipient} • ${record.status}'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final exports = ref.watch(exportsControllerProvider);
    return _ModulePage(
      title: 'Reports & analytics',
      subtitle: 'Revenue, conversion, sales performance, and exports',
      child: dashboard.when(
        loading: () => const LoadingSkeleton(rows: 4),
        error: (error, stackTrace) => EmptyState(title: 'Reports unavailable', message: '$error'),
        data: (bundle) => Column(
          children: [
            RevenueChart(points: bundle.revenue),
            const SizedBox(height: AppSpacing.lg),
            GlassPanel(
              child: Column(
                children: [
                  _ReportTile(title: 'Revenue report', value: compactMoney(bundle.metrics.revenue), color: AppColors.indigo),
                  _ReportTile(title: 'Lead conversion', value: '${bundle.metrics.conversionRate}%', color: AppColors.emerald),
                  _ReportTile(title: 'Team performance', value: '+${bundle.metrics.monthlyGrowth}%', color: AppColors.azure),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref.read(exportsControllerProvider.notifier).generateExport('Revenue Report', ExportFormat.pdf),
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: const Text('Export PDF'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref.read(exportsControllerProvider.notifier).generateExport('Revenue Report', ExportFormat.excel),
                          icon: const Icon(Icons.table_chart_rounded),
                          label: const Text('Export Excel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            exports.when(
              loading: () => const LoadingSkeleton(rows: 1),
              error: (error, stackTrace) => EmptyState(title: 'Export history unavailable', message: '$error'),
              data: (records) => GlassPanel(
                child: Column(
                  children: [
                    const SectionHeader(title: 'Export history', subtitle: 'Generated local report records'),
                    for (final record in records)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(record.format == ExportFormat.pdf ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded),
                        title: Text(record.reportName, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text(record.path),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return _ModulePage(
      title: 'Notifications',
      subtitle: 'Push, in-app reminders, task alerts, and meeting nudges',
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: () async {
              final title = await _promptText(context, 'Create reminder', 'Reminder title');
              if (title != null && title.trim().isNotEmpty) {
                await ref.read(notificationsControllerProvider.notifier).createReminder(
                      title.trim(),
                      'Manual reminder created from notification center.',
                    );
              }
            },
            icon: const Icon(Icons.add_alert_rounded),
            label: const Text('Create reminder'),
          ),
          const SizedBox(height: AppSpacing.lg),
          notifications.when(
            loading: () => const LoadingSkeleton(rows: 3),
            error: (error, stackTrace) => EmptyState(title: 'Notifications unavailable', message: '$error'),
            data: (items) => GlassPanel(
              child: Column(
                children: [
                  for (final item in items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(item.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(item.body),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            onPressed: () => ref.read(notificationsControllerProvider.notifier).markRead(item.id, !item.isRead),
                            icon: Icon(item.isRead ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded),
                          ),
                          IconButton(
                            onPressed: () => ref.read(notificationsControllerProvider.notifier).deleteNotification(item.id),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    return _ModulePage(
      title: 'Settings',
      subtitle: 'Profile, team, theme, security, and notifications',
      child: Column(
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme mode', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  selected: {mode},
                  onSelectionChanged: (selection) {
                    ref.read(themeModeControllerProvider.notifier).setThemeMode(selection.single);
                  },
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.auto_mode_rounded)),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPanel(
            child: Column(
              children: [
                SectionHeader(
                  title: 'Workspace profile',
                  subtitle: '${user?.name ?? 'Apex User'} • ${user?.team ?? 'Sales'} team',
                ),
                const SizedBox(height: AppSpacing.sm),
                _SettingsActionTile(
                  icon: Icons.person_rounded,
                  title: 'Edit user profile',
                  subtitle: 'Name, role, avatar, and contact preferences',
                  onTap: () => context.go('/profile'),
                ),
                _SettingsActionTile(
                  icon: Icons.cloud_done_rounded,
                  title: 'Create local backup checkpoint',
                  subtitle: 'Save an offline sync checkpoint for this device',
                  onTap: () => _saveLocalAction(context, ref, 'Backup checkpoint', 'Local CRM checkpoint saved.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPanel(
            child: Column(
              children: [
                const SectionHeader(title: 'Security', subtitle: 'Session management and device trust'),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Require biometric unlock'),
                  subtitle: const Text('Use device biometrics before opening sensitive CRM data'),
                  value: true,
                  onChanged: (_) => _saveLocalAction(context, ref, 'Security preference', 'Biometric unlock preference saved locally.'),
                ),
                _SettingsActionTile(
                  icon: Icons.lock_clock_rounded,
                  title: 'Reset trusted session',
                  subtitle: 'Clear local trust and require a fresh sign-in',
                  onTap: () => _saveLocalAction(context, ref, 'Trusted session reset', 'This device trust state was refreshed locally.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPanel(
            child: Column(
              children: [
                const SectionHeader(title: 'Notifications', subtitle: 'Follow-up, task, and meeting reminders'),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Follow-up reminders'),
                  subtitle: const Text('Create local alerts for due leads and tasks'),
                  value: true,
                  onChanged: (_) => _saveLocalAction(context, ref, 'Notification preference', 'Follow-up reminders preference saved.'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.video_camera_front_rounded),
                  title: const Text('Meeting alerts'),
                  subtitle: const Text('Notify before customer meetings'),
                  value: true,
                  onChanged: (_) => _saveLocalAction(context, ref, 'Meeting alerts', 'Meeting alert preference saved.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPanel(
            child: Column(
              children: [
                const SectionHeader(title: 'CRM preferences', subtitle: 'Default stages, layout density, and lead ownership'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsActionTile(
                  icon: Icons.view_kanban_rounded,
                  title: 'Customize pipeline stages',
                  subtitle: 'Configure discovery, proposal, won/lost flow locally',
                  onTap: () => _saveLocalAction(context, ref, 'Pipeline configuration', 'Pipeline stage preferences saved locally.'),
                ),
                _SettingsActionTile(
                  icon: Icons.density_medium_rounded,
                  title: 'Use compact business cards',
                  subtitle: 'Reduce spacing for lead and customer lists',
                  onTap: () => _saveLocalAction(context, ref, 'Layout preference', 'Compact card preference saved locally.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return _ModulePage(
      title: 'Admin',
      subtitle: 'Control workspace access, CRM configuration, and operations',
      child: Column(
        children: [
          dashboard.when(
            loading: () => const LoadingSkeleton(rows: 1),
            error: (error, stackTrace) => EmptyState(title: 'Admin analytics unavailable', message: '$error'),
            data: (bundle) => GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Admin analytics', subtitle: 'Live local workspace overview'),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      StatusBadge(label: '${bundle.metrics.activeCustomers} customers', color: AppColors.indigo),
                      StatusBadge(label: '${bundle.metrics.totalLeads} leads', color: AppColors.azure),
                      StatusBadge(label: '${bundle.metrics.upcomingMeetings} meetings', color: AppColors.emerald),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AdminActionCard(
            icon: Icons.manage_accounts_rounded,
            title: 'User management',
            subtitle: 'Invite users, deactivate seats, and audit account access',
            primaryAction: 'Invite user',
            secondaryAction: 'Audit users',
            onPrimary: () => _saveLocalAction(context, ref, 'User invited', 'A local user invitation record was created.'),
            onSecondary: () => _saveLocalAction(context, ref, 'User audit', 'User access audit queued locally.'),
          ),
          _AdminActionCard(
            icon: Icons.groups_2_rounded,
            title: 'Team management',
            subtitle: 'Manage sales pods, territories, and capacity',
            primaryAction: 'Create team',
            secondaryAction: 'Assign territory',
            onPrimary: () => _saveLocalAction(context, ref, 'Team created', 'A local team setup record was created.'),
            onSecondary: () => _saveLocalAction(context, ref, 'Territory assigned', 'Territory assignment saved locally.'),
          ),
          _AdminActionCard(
            icon: Icons.verified_user_rounded,
            title: 'Roles & permissions',
            subtitle: 'Configure admin, manager, sales, and support access',
            primaryAction: 'Edit roles',
            secondaryAction: 'Review policy',
            onPrimary: () => _saveLocalAction(context, ref, 'Roles updated', 'Role configuration saved locally.'),
            onSecondary: () => _saveLocalAction(context, ref, 'Policy review', 'Permission policy review queued locally.'),
          ),
          _AdminActionCard(
            icon: Icons.schema_rounded,
            title: 'CRM configuration',
            subtitle: 'Custom stages, fields, lead sources, and automation defaults',
            primaryAction: 'Configure CRM',
            secondaryAction: 'Reset defaults',
            onPrimary: () => _saveLocalAction(context, ref, 'CRM configured', 'CRM configuration saved locally.'),
            onSecondary: () => _saveLocalAction(context, ref, 'Defaults restored', 'Default CRM configuration restored locally.'),
          ),
          _AdminActionCard(
            icon: Icons.monitor_heart_rounded,
            title: 'Activity monitoring',
            subtitle: 'Review workspace activity and compliance events',
            primaryAction: 'View activity',
            secondaryAction: 'Export audit',
            onPrimary: () => context.go('/activities'),
            onSecondary: () => ref.read(exportsControllerProvider.notifier).generateExport('Admin Audit', ExportFormat.pdf),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryAction,
    required this.secondaryAction,
    required this.onPrimary,
    required this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryAction;
  final String secondaryAction;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.tonal(onPressed: onPrimary, child: Text(primaryAction)),
                OutlinedButton(onPressed: onSecondary, child: Text(secondaryAction)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    return _ModulePage(
      title: 'Profile',
      subtitle: 'Personal details and session management',
      child: GlassPanel(
        child: Column(
          children: [
            CircleAvatar(radius: 42, child: Text((user?.name ?? 'A').characters.first)),
            const SizedBox(height: AppSpacing.md),
            Text(user?.name ?? 'Apex User', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text(user?.email ?? 'user@apexcrm.dev'),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat.MMMd().add_jm();
    return GlassPanel(
      child: Column(
        children: [
          const SectionHeader(title: 'Task board', subtitle: 'Priority, category, assignment, and recurring work'),
          const SizedBox(height: AppSpacing.sm),
          for (final task in tasks)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Checkbox(
                value: task.status == TaskStatus.done,
                onChanged: (_) => ref.read(tasksControllerProvider.notifier).toggleDone(task),
              ),
              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${task.assignee} • ${task.category} • ${formatter.format(task.dueAt)}'),
              trailing: Wrap(
                children: [
                  StatusBadge(label: task.status.label, color: priorityColor(task.priority)),
                  IconButton(
                    onPressed: () => ref.read(tasksControllerProvider.notifier).deleteTask(task.id),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MeetingList extends ConsumerWidget {
  const _MeetingList({required this.meetings});

  final List<Meeting> meetings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat.MMMd().add_jm();
    return GlassPanel(
      child: Column(
        children: [
          const SectionHeader(title: 'Meeting calendar', subtitle: 'Customer-linked meetings and reminders'),
          const SizedBox(height: AppSpacing.sm),
          for (final meeting in meetings)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.video_camera_front_rounded),
              title: Text(meeting.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${meeting.customerName} • ${formatter.format(meeting.startsAt)}\n${meeting.videoLink}'),
              trailing: IconButton(
                onPressed: () => ref.read(meetingsControllerProvider.notifier).deleteMeeting(meeting.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              isThreeLine: true,
            ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(Icons.insights_rounded, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      trailing: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
    );
  }
}

class _ModulePage extends StatelessWidget {
  const _ModulePage({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => context.go('/more'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: SectionHeader(title: title, subtitle: subtitle)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    );
  }
}

class _MoreItem {
  const _MoreItem(this.title, this.subtitle, this.icon, this.path);

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;
}

Future<String?> _promptText(BuildContext context, String title, String label) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: label)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
      ],
    ),
  );
}

Future<void> _saveLocalAction(
  BuildContext context,
  WidgetRef ref,
  String title,
  String body,
) async {
  await ref.read(notificationsControllerProvider.notifier).createReminder(title, body);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body)));
  }
}
