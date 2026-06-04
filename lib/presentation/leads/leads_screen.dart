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
    return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionHeader(
                  title: 'Leads',
                  subtitle: 'Track, qualify, and schedule follow-ups',
                  action: HeaderActionButton(
                    label: 'New',
                    icon: Icons.add_rounded,
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const _LeadFormSheet(),
                    ),
                  ),
                ),
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
                CrmMenuButton<String>(
                  onSelected: (value) async {
                    final controller = ref.read(leadsControllerProvider.notifier);
                    if (value == 'edit') {
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => _LeadFormSheet(lead: lead),
                      );
                    }
                    if (value == 'note') {
                      final note = await _promptText(context, 'Add lead note', 'Note');
                      if (note != null && note.trim().isNotEmpty) {
                        await controller.addNote(lead, note.trim());
                      }
                    }
                    if (value == 'converted') await controller.updateStatus(lead, LeadStatus.converted);
                    if (value == 'delete') await controller.deleteLead(lead.id);
                  },
                  items: const [
                    PopupMenuItem(value: 'edit', child: Text('Edit lead')),
                    PopupMenuItem(value: 'note', child: Text('Add note')),
                    PopupMenuItem(value: 'converted', child: Text('Mark converted')),
                    PopupMenuItem(value: 'delete', child: Text('Delete lead')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.xs),
            Text('Next follow-up: ${lead.nextFollowUp.month}/${lead.nextFollowUp.day} • ${lead.assignedTo}'),
            if (lead.notes.isNotEmpty) Text(lead.notes.first, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _LeadFormSheet extends ConsumerStatefulWidget {
  const _LeadFormSheet({this.lead});

  final Lead? lead;

  @override
  ConsumerState<_LeadFormSheet> createState() => _LeadFormSheetState();
}

class _LeadFormSheetState extends ConsumerState<_LeadFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  LeadStatus _status = LeadStatus.newLead;
  PriorityLevel _priority = PriorityLevel.medium;

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    if (lead != null) {
      _name.text = lead.name;
      _company.text = lead.company;
      _email.text = lead.email;
      _phone.text = lead.phone;
      _status = lead.status;
      _priority = lead.priority;
    }
  }

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
                title: widget.lead == null ? 'Create lead' : 'Edit lead',
                subtitle: 'Capture contact, status, and priority context',
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => Validators.required(v, field: 'Name')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _company, decoration: const InputDecoration(labelText: 'Company'), validator: (v) => Validators.required(v, field: 'Company')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: Validators.email),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), validator: Validators.phone),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<LeadStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final status in LeadStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<PriorityLevel>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  for (final priority in PriorityLevel.values)
                    DropdownMenuItem(value: priority, child: Text(priority.label)),
                ],
                onChanged: (value) => setState(() => _priority = value ?? _priority),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final existing = widget.lead;
                  if (existing == null) {
                    await ref.read(leadsControllerProvider.notifier).createDemoLead(
                          name: _name.text,
                          company: _company.text,
                          email: _email.text,
                          phone: _phone.text,
                          status: _status,
                          priority: _priority,
                        );
                  } else {
                    await ref.read(leadsControllerProvider.notifier).saveLead(
                          existing.copyWith(
                            name: _name.text,
                            company: _company.text,
                            email: _email.text,
                            phone: _phone.text,
                            status: _status,
                            priority: _priority,
                          ),
                        );
                  }
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

Future<String?> _promptText(BuildContext context, String title, String label) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
      ],
    ),
  );
}
