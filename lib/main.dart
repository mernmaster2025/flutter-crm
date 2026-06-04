import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/datasources/crm_local_data_source.dart';
import 'data/services/local_cache_service.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cache = await LocalCacheService.open();
  final crmLocalDataSource = await CrmLocalDataSource.open();

  runApp(
    ProviderScope(
      overrides: [
        localCacheServiceProvider.overrideWithValue(cache),
        crmLocalDataSourceProvider.overrideWithValue(crmLocalDataSource),
      ],
      child: const ApexCrmApp(),
    ),
  );
}
