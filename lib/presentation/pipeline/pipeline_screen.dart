import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
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
            SectionHeader(
              title: 'Sales pipeline',
              subtitle: 'Drag deals between stages and track weighted forecast',
              action: HeaderActionButton(
                label: 'New',
                icon: Icons.add_chart_rounded,
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const _DealFormSheet(),
                ),
              ),
            ),
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
        return SizedBox(
          width: 292,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
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
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        if (candidateData.isNotEmpty)
                          Container(
                            height: 56,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                ],
              ),
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

class _DealCard extends ConsumerWidget {
  const _DealCard({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.w900))),
                CrmMenuButton<String>(
                  onSelected: (value) async {
                    final controller = ref.read(dealsControllerProvider.notifier);
                    if (value == 'edit') {
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => _DealFormSheet(deal: deal),
                      );
                    }
                    if (value == 'won') await controller.saveDeal(deal.copyWith(stage: DealStage.won, probability: 1));
                    if (value == 'lost') await controller.saveDeal(deal.copyWith(stage: DealStage.lost, probability: 0));
                    if (value == 'delete') await controller.deleteDeal(deal.id);
                  },
                  items: const [
                    PopupMenuItem(value: 'edit', child: Text('Edit deal')),
                    PopupMenuItem(value: 'won', child: Text('Mark won')),
                    PopupMenuItem(value: 'lost', child: Text('Mark lost')),
                    PopupMenuItem(value: 'delete', child: Text('Delete deal')),
                  ],
                ),
              ],
            ),
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

class _DealFormSheet extends ConsumerStatefulWidget {
  const _DealFormSheet({this.deal});

  final Deal? deal;

  @override
  ConsumerState<_DealFormSheet> createState() => _DealFormSheetState();
}

class _DealFormSheetState extends ConsumerState<_DealFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _customer = TextEditingController();
  final _value = TextEditingController();
  DealStage _stage = DealStage.discovery;

  @override
  void initState() {
    super.initState();
    final deal = widget.deal;
    if (deal != null) {
      _title.text = deal.title;
      _customer.text = deal.customerName;
      _value.text = deal.value.toStringAsFixed(0);
      _stage = deal.stage;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _customer.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionHeader(
                title: widget.deal == null ? 'Create deal' : 'Edit deal',
                subtitle: 'Persist opportunity value and stage',
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Deal title'), validator: (v) => Validators.required(v, field: 'Title')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _customer, decoration: const InputDecoration(labelText: 'Customer'), validator: (v) => Validators.required(v, field: 'Customer')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _value, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Value'), validator: (v) => Validators.required(v, field: 'Value')),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<DealStage>(
                initialValue: _stage,
                decoration: const InputDecoration(labelText: 'Stage'),
                items: [
                  for (final stage in DealStage.values)
                    DropdownMenuItem(value: stage, child: Text(stage.label)),
                ],
                onChanged: (value) => setState(() => _stage = value ?? _stage),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final amount = double.tryParse(_value.text) ?? 0;
                  final existing = widget.deal;
                  if (existing == null) {
                    await ref.read(dealsControllerProvider.notifier).saveDeal(
                          Deal(
                            id: DateTime.now().microsecondsSinceEpoch.toString(),
                            title: _title.text,
                            customerId: 'manual',
                            customerName: _customer.text,
                            stage: _stage,
                            value: amount,
                            probability: 0.35,
                            closeDate: DateTime.now().add(const Duration(days: 30)),
                            owner: 'Maya Chen',
                          ),
                        );
                  } else {
                    await ref.read(dealsControllerProvider.notifier).saveDeal(
                          existing.copyWith(
                            title: _title.text,
                            customerName: _customer.text,
                            stage: _stage,
                            value: amount,
                          ),
                        );
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Save deal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
