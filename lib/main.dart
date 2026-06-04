import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/services/local_cache_service.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cache = await LocalCacheService.open();

  runApp(
    ProviderScope(
      overrides: [
        localCacheServiceProvider.overrideWithValue(cache),
      ],
      child: const ApexCrmApp(),
    ),
  );
}
