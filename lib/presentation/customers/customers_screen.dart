import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/crm_models.dart';
import '../../widgets/crm_components.dart';
import '../../widgets/premium_scaffold.dart';
import '../providers/app_providers.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    final favoritesOnly = ref.watch(favoritesOnlyProvider);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SectionHeader(title: 'Customers', subtitle: 'Profiles, history, attachments, and segments'),
              const SizedBox(height: AppSpacing.lg),
              CrmSearchField(
                hint: 'Search customers or companies',
                onChanged: (value) => ref.read(customerQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favorite customers only'),
                value: favoritesOnly,
                onChanged: (value) => ref.read(favoritesOnlyProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              customers.when(
                loading: () => const LoadingSkeleton(rows: 4),
                error: (error, stackTrace) => EmptyState(title: 'Customers unavailable', message: '$error'),
                data: (items) => Column(children: [for (final customer in items) _CustomerCard(customer: customer)]),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

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
                CircleAvatar(child: Text(customer.company.characters.first)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.company, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text('${customer.name} • ${customer.location}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(customer.isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.amber),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                StatusBadge(label: customer.segment.label, color: AppColors.indigo),
                StatusBadge(label: compactMoney(customer.revenue), color: AppColors.emerald),
                for (final tag in customer.tags) StatusBadge(label: tag, color: AppColors.azure),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Activity timeline', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.xs),
            for (final item in customer.history)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(Icons.timeline_rounded, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
