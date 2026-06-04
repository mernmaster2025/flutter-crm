import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/crm_models.dart';
import '../../widgets/crm_components.dart';
import '../../widgets/premium_scaffold.dart';
import '../providers/app_providers.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(leadsControllerProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _LeadFormSheet(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New lead'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SectionHeader(title: 'Leads', subtitle: 'Track, qualify, and schedule follow-ups'),
                const SizedBox(height: AppSpacing.lg),
                CrmSearchField(
                  hint: 'Search leads, companies, email',
                  onChanged: (value) => ref.read(leadQueryProvider.notifier).state = value,
                ),
                const SizedBox(height: AppSpacing.sm),
                _LeadFilters(ref: ref),
                const SizedBox(height: AppSpacing.md),
                leads.when(
                  loading: () => const LoadingSkeleton(rows: 5),
                  error: (error, stackTrace) => EmptyState(title: 'No leads loaded', message: '$error'),
                  data: (items) => items.isEmpty
                      ? const EmptyState(title: 'No matching leads', message: 'Adjust your filters or create a new lead.')
                      : Column(children: [for (final lead in items) _LeadTile(lead: lead)]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadFilters extends StatelessWidget {
  const _LeadFilters({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(leadStatusFilterProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            selected: selected == null,
            label: const Text('All'),
            onSelected: (_) => ref.read(leadStatusFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: AppSpacing.xs),
          for (final status in LeadStatus.values) ...[
            FilterChip(
              selected: selected == status,
              label: Text(status.label),
              onSelected: (_) => ref.read(leadStatusFilterProvider.notifier).state = status,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _LeadTile extends ConsumerWidget {
  const _LeadTile({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(lead.name.characters.first)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lead.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text(lead.company, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') ref.read(crmUseCasesProvider).removeLead(lead.id).then((_) => ref.invalidate(leadsControllerProvider));
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete lead')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                StatusBadge(label: lead.status.label),
                StatusBadge(label: lead.priority.label, color: priorityColor(lead.priority)),
                StatusBadge(label: lead.source),
                StatusBadge(label: compactMoney(lead.estimatedValue)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Next follow-up: ${lead.nextFollowUp.month}/${lead.nextFollowUp.day} • ${lead.assignedTo}'),
            if (lead.notes.isNotEmpty) Text(lead.notes.first, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _LeadFormSheet extends ConsumerStatefulWidget {
  const _LeadFormSheet();

  @override
  ConsumerState<_LeadFormSheet> createState() => _LeadFormSheetState();
}

class _LeadFormSheetState extends ConsumerState<_LeadFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
              const SectionHeader(title: 'Create lead', subtitle: 'Capture contact and company context'),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => Validators.required(v, field: 'Name')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _company, decoration: const InputDecoration(labelText: 'Company'), validator: (v) => Validators.required(v, field: 'Company')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: Validators.email),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), validator: Validators.phone),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await ref.read(leadsControllerProvider.notifier).createDemoLead(
                        name: _name.text,
                        company: _company.text,
                        email: _email.text,
                        phone: _phone.text,
                      );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Save lead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
