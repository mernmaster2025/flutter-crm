import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/crm_models.dart';
import '../../widgets/crm_components.dart';
import '../../widgets/premium_scaffold.dart';
import '../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return dashboard.when(
      loading: () => const _DashboardLoading(),
      error: (error, stackTrace) => Center(child: EmptyState(title: 'Could not load dashboard', message: '$error')),
      data: (bundle) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _DashboardHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _MetricGrid(metrics: bundle.metrics),
                  const SizedBox(height: AppSpacing.lg),
                  RevenueChart(points: bundle.revenue).animate().fadeIn().slideY(begin: 0.08),
                  const SizedBox(height: AppSpacing.lg),
                  _TodayPanel(tasks: bundle.tasks, meetings: bundle.meetings),
                  const SizedBox(height: AppSpacing.lg),
                  _ActivityFeed(activities: bundle.activities),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, ${user?.name.split(' ').first ?? 'there'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSpacing.xs),
              Text('Your revenue command center is up to date.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => context.go('/notifications'),
          icon: const Icon(Icons.notifications_active_outlined),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(title: 'Revenue', value: compactMoney(metrics.revenue), icon: Icons.payments_rounded, accent: AppColors.indigo, delta: '+${metrics.monthlyGrowth}%'),
      MetricCard(title: 'Total leads', value: '${metrics.totalLeads}', icon: Icons.person_add_rounded, accent: AppColors.azure),
      MetricCard(title: 'Active customers', value: '${metrics.activeCustomers}', icon: Icons.groups_rounded, accent: AppColors.emerald),
      MetricCard(title: 'Sales pipeline', value: compactMoney(metrics.openPipeline), icon: Icons.stacked_line_chart_rounded, accent: AppColors.violet),
      MetricCard(title: 'Tasks due today', value: '${metrics.tasksDueToday}', icon: Icons.task_alt_rounded, accent: AppColors.amber),
      MetricCard(title: 'Upcoming meetings', value: '${metrics.upcomingMeetings}', icon: Icons.video_camera_front_rounded, accent: AppColors.rose),
      MetricCard(title: 'Conversion rate', value: '${metrics.conversionRate}%', icon: Icons.trending_up_rounded, accent: AppColors.cyan),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Breakpoints.dashboardColumns(context),
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: Breakpoints.isTabletOrLarger(context) ? 1.65 : 1.08,
      ),
      itemBuilder: (context, index) => cards[index].animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.08),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({required this.tasks, required this.meetings});

  final List<TaskItem> tasks;
  final List<Meeting> meetings;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Today', subtitle: 'Tasks and meetings that need attention'),
          const SizedBox(height: AppSpacing.md),
          for (final task in tasks.take(3))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline_rounded, color: priorityColor(task.priority)),
              title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${task.assignee} • ${timeFormat.format(task.dueAt)}'),
              trailing: StatusBadge(label: task.priority.label, color: priorityColor(task.priority)),
            ),
          const Divider(),
          for (final meeting in meetings)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(meeting.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${meeting.customerName} • ${timeFormat.format(meeting.startsAt)}'),
            ),
        ],
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.activities});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent activity', subtitle: 'Customer interactions across the team'),
          const SizedBox(height: AppSpacing.md),
          for (final activity in activities)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(_activityIcon(activity.type), size: 18)),
              title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${activity.description}\n${activity.actor}'),
              isThreeLine: true,
            ),
        ],
      ),
    );
  }

  IconData _activityIcon(ActivityType type) {
    return switch (type) {
      ActivityType.call => Icons.call_rounded,
      ActivityType.email => Icons.mail_rounded,
      ActivityType.meeting => Icons.event_rounded,
      ActivityType.note => Icons.note_alt_rounded,
      ActivityType.sms => Icons.sms_rounded,
      ActivityType.whatsapp => Icons.chat_rounded,
    };
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: LoadingSkeleton(rows: 6),
    );
  }
}
