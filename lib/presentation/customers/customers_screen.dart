import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _CustomerFormSheet(),
        ),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('New customer'),
      ),
      body: CustomScrollView(
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
      ),
    );
  }
}

class _CustomerCard extends ConsumerWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

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
                IconButton(
                  onPressed: () => ref.read(customersControllerProvider.notifier).toggleFavorite(customer),
                  icon: Icon(customer.isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.amber),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    final controller = ref.read(customersControllerProvider.notifier);
                    if (value == 'edit') {
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => _CustomerFormSheet(customer: customer),
                      );
                    }
                    if (value == 'note') {
                      final note = await _promptText(context, 'Add timeline note', 'Note');
                      if (note != null && note.trim().isNotEmpty) {
                        await controller.addHistory(customer, note.trim());
                      }
                    }
                    if (value == 'delete') await controller.deleteCustomer(customer.id);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit customer')),
                    PopupMenuItem(value: 'note', child: Text('Add timeline note')),
                    PopupMenuItem(value: 'delete', child: Text('Delete customer')),
                  ],
                ),
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

class _CustomerFormSheet extends ConsumerStatefulWidget {
  const _CustomerFormSheet({this.customer});

  final Customer? customer;

  @override
  ConsumerState<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<_CustomerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  CustomerSegment _segment = CustomerSegment.midMarket;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer != null) {
      _name.text = customer.name;
      _company.text = customer.company;
      _email.text = customer.email;
      _phone.text = customer.phone;
      _segment = customer.segment;
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
                title: widget.customer == null ? 'Create customer' : 'Edit customer',
                subtitle: 'Persist profile and segmentation locally',
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Contact name'), validator: (v) => Validators.required(v, field: 'Name')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _company, decoration: const InputDecoration(labelText: 'Company'), validator: (v) => Validators.required(v, field: 'Company')),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: Validators.email),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), validator: Validators.phone),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<CustomerSegment>(
                initialValue: _segment,
                decoration: const InputDecoration(labelText: 'Segment'),
                items: [
                  for (final segment in CustomerSegment.values)
                    DropdownMenuItem(value: segment, child: Text(segment.label)),
                ],
                onChanged: (value) => setState(() => _segment = value ?? _segment),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final existing = widget.customer;
                  if (existing == null) {
                    await ref.read(customersControllerProvider.notifier).createDemoCustomer(
                          name: _name.text,
                          company: _company.text,
                          email: _email.text,
                          phone: _phone.text,
                          segment: _segment,
                        );
                  } else {
                    await ref.read(customersControllerProvider.notifier).saveCustomer(
                          existing.copyWith(
                            name: _name.text,
                            company: _company.text,
                            email: _email.text,
                            phone: _phone.text,
                            segment: _segment,
                          ),
                        );
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Save customer'),
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
      content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: label)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
      ],
    ),
  );
}
