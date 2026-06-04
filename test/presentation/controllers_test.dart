import 'dart:io';

import 'package:flutter_crm/data/datasources/crm_local_data_source.dart';
import 'package:flutter_crm/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late CrmLocalDataSource source;
  late ProviderContainer container;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('crm_provider_test_');
    Hive.init(tempDir.path);
    source = await CrmLocalDataSource.open();
    await source.clearAll();
    await source.seedIfNeeded();
    container = ProviderContainer(
      overrides: [
        crmLocalDataSourceProvider.overrideWithValue(source),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('LeadsController creates a persisted lead', () async {
    final initial = await container.read(leadsControllerProvider.future);

    await container.read(leadsControllerProvider.notifier).createDemoLead(
          name: 'Controller Lead',
          company: 'Controller Co',
          email: 'lead@controller.co',
          phone: '+1 555 0100',
        );

    final leads = await container.read(leadsControllerProvider.future);
    expect(leads.length, initial.length + 1);
    expect(leads.any((lead) => lead.name == 'Controller Lead'), isTrue);
  });
}
