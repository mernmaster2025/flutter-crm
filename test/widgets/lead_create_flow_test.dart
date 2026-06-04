import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_crm/data/datasources/crm_local_data_source.dart';
import 'package:flutter_crm/presentation/leads/leads_screen.dart';
import 'package:flutter_crm/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late CrmLocalDataSource source;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('crm_widget_test_');
    Hive.init(tempDir.path);
    source = await CrmLocalDataSource.open();
    await source.clearAll();
    await source.seedIfNeeded();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('creates a lead from the lead form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          crmLocalDataSourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(home: LeadsScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('New lead'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Widget Lead');
    await tester.enterText(find.widgetWithText(TextFormField, 'Company'), 'Widget Co');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'widget@lead.co');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '+1 555 0101');
    await tester.tap(find.text('Save lead'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Widget Lead'), findsOneWidget);
  });
}
