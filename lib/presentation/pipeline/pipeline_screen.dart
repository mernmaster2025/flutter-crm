import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/crm_models.dart';
import '../../widgets/crm_components.dart';
import '../../widgets/premium_scaffold.dart';
import '../providers/app_providers.dart';

class PipelineScreen extends ConsumerWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(dealsControllerProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Sales pipeline', subtitle: 'Drag deals between stages and track weighted forecast'),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: deals.when(
              loading: () => const LoadingSkeleton(rows: 5),
              error: (error, stackTrace) => EmptyState(title: 'Pipeline unavailable', message: '$error'),
              data: (items) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final stage in DealStage.values)
                      _PipelineColumn(
                        stage: stage,
                        deals: items.where((deal) => deal.stage == stage).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineColumn extends ConsumerWidget {
  const _PipelineColumn({required this.stage, required this.deals});

  final DealStage stage;
  final List<Deal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = deals.fold<double>(0, (sum, deal) => sum + deal.value * deal.probability);
    return DragTarget<Deal>(
      onAcceptWithDetails: (details) => ref.read(dealsControllerProvider.notifier).moveDeal(details.data.id, stage),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 292,
          margin: const EdgeInsets.only(right: AppSpacing.md),
          child: GlassPanel(
            borderRadius: AppSpacing.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(stage.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    ),
                    StatusBadge(label: '${deals.length}', color: _stageColor(stage)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Forecast ${compactMoney(forecast)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.md),
                if (candidateData.isNotEmpty)
                  Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: const Text('Drop to move deal'),
                  ),
                for (final deal in deals) _DealCard(deal: deal),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _stageColor(DealStage stage) {
    return switch (stage) {
      DealStage.discovery => AppColors.slate,
      DealStage.qualified => AppColors.azure,
      DealStage.proposal => AppColors.indigo,
      DealStage.negotiation => AppColors.amber,
      DealStage.won => AppColors.emerald,
      DealStage.lost => AppColors.rose,
    };
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deal.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSpacing.xs),
            Text(deal.customerName, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: Text(compactMoney(deal.value), style: const TextStyle(fontWeight: FontWeight.w900))),
                Text('${(deal.probability * 100).round()}%'),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(value: deal.probability),
          ],
        ),
      ),
    );

    return LongPressDraggable<Deal>(
      data: deal,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 260, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }
}
