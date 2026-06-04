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
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
      children: [
        const SectionHeader(title: 'CRM workspace', subtitle: 'Manage your revenue operations modules'),
        const SizedBox(height: AppSpacing.lg),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassPanel(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(item.icon)),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go(item.path),
              ),
            ),
          ),
      ],
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
      child: activities.when(
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
                  isThreeLine: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunicationScreen extends ConsumerWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      ('Email campaign', Icons.mail_rounded, 'Send personalized templates to a lead segment.'),
      ('SMS reminder', Icons.sms_rounded, 'Deliver follow-up reminders and task nudges.'),
      ('WhatsApp outreach', Icons.chat_rounded, 'Continue high-context customer conversations.'),
      ('Bulk messaging', Icons.campaign_rounded, 'Queue compliant updates for selected customers.'),
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
                  subtitle: Text(action.$3),
                  trailing: FilledButton.tonal(onPressed: () {}, child: const Text('Use')),
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
                      Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('Export PDF'))),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_chart_rounded), label: const Text('Export Excel'))),
                    ],
                  ),
                ],
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
      child: notifications.when(
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
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
              children: const [
                ListTile(leading: Icon(Icons.security_rounded), title: Text('Security settings'), subtitle: Text('Biometric login, session management, and device trust')),
                ListTile(leading: Icon(Icons.group_rounded), title: Text('Team management'), subtitle: Text('Roles, permissions, and workspace membership')),
                ListTile(leading: Icon(Icons.tune_rounded), title: Text('App preferences'), subtitle: Text('Pipeline stages, notifications, and CRM defaults')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('User management', 'Invite, deactivate, and audit users', Icons.manage_accounts_rounded),
      ('Team management', 'Territories, sales pods, and capacity', Icons.groups_2_rounded),
      ('Permission control', 'Admin, manager, sales, and support roles', Icons.verified_user_rounded),
      ('CRM configuration', 'Custom stages, fields, lead sources', Icons.schema_rounded),
      ('Activity monitoring', 'Workspace activity and compliance events', Icons.monitor_heart_rounded),
    ];
    return _ModulePage(
      title: 'Admin',
      subtitle: 'Control workspace access, CRM configuration, and operations',
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassPanel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Icon(item.$3)),
                  title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(item.$2),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
        ],
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

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.MMMd().add_jm();
    return GlassPanel(
      child: Column(
        children: [
          const SectionHeader(title: 'Task board', subtitle: 'Priority, category, assignment, and recurring work'),
          const SizedBox(height: AppSpacing.sm),
          for (final task in tasks)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.task_rounded, color: priorityColor(task.priority)),
              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${task.assignee} • ${task.category} • ${formatter.format(task.dueAt)}'),
              trailing: StatusBadge(label: task.status.label, color: priorityColor(task.priority)),
            ),
        ],
      ),
    );
  }
}

class _MeetingList extends StatelessWidget {
  const _MeetingList({required this.meetings});

  final List<Meeting> meetings;

  @override
  Widget build(BuildContext context) {
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
