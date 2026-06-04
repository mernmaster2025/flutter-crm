import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

class LocalCacheService {
  LocalCacheService(this._box);

  final Box<dynamic> _box;

  static Future<LocalCacheService> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(AppConstants.hiveBoxName);
    return LocalCacheService(box);
  }

  T? read<T>(String key) => _box.get(key) as T?;

  Future<void> write<T>(String key, T value) => _box.put(key, value);

  Future<void> clear() => _box.clear();
}
