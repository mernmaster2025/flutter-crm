import 'dart:io';

import 'package:flutter_crm/data/datasources/crm_local_data_source.dart';
import 'package:flutter_crm/data/repositories/crm_repository_impl.dart';
import 'package:flutter_crm/domain/entities/crm_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late CrmLocalDataSource source;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('crm_hive_test_');
    Hive.init(tempDir.path);
    source = await CrmLocalDataSource.open();
    await source.clearAll();
    await source.seedIfNeeded();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('seeds and persists leads locally', () async {
    final seeded = await source.getLeads();
    expect(seeded, isNotEmpty);

    final saved = seeded.first.copyWith(name: 'Persisted Lead');
    await source.saveLead(saved);

    final leads = await source.getLeads();
    expect(leads.any((lead) => lead.name == 'Persisted Lead'), isTrue);
  });

  test('repository communication creates activity and notification records', () async {
    final repository = CrmRepositoryImpl(localDataSource: source);

    await repository.saveCommunication(
      CommunicationRecord(
        id: 'comm_test',
        channel: CommunicationChannel.email,
        recipient: 'buyer@example.com',
        subject: 'Follow-up',
        message: 'Thanks for your time.',
        createdAt: DateTime.now(),
        status: 'Queued locally',
      ),
    );

    expect(await repository.getCommunications(), hasLength(1));
    expect((await repository.getActivities()).first.title, contains('Email'));
    expect((await repository.getNotifications()).first.title, 'Communication queued');
  });
}
