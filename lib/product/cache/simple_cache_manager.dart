// ignore_for_file: prefer_constructors_over_static_methods, document_ignores

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SimpleCacheManager {
  SimpleCacheManager._();
  static SimpleCacheManager? _instance;
  static SimpleCacheManager get instance =>
      _instance ??= SimpleCacheManager._();

  Box<String>? _box;

  // Initialize cache
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<String>(HiveBoxNames.simpleCache);
      if (kDebugMode) {
        print('✅ SimpleCacheManager: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SimpleCacheManager: Initialize failed: $e');
      }
    }
  }

  // Save data
  Future<void> save(String key, String value) async {
    try {
      await _box?.put(key, value);
      if (kDebugMode) {
        print('💾 SimpleCacheManager: Saved $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SimpleCacheManager: Save failed for $key: $e');
      }
    }
  }

  // Get data
  String? get(String key) {
    try {
      final value = _box?.get(key);
      if (kDebugMode) {
        print(
            '📖 SimpleCacheManager: Get $key = ${value != null ? 'Found' : 'Not found'}');
      }
      return value;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SimpleCacheManager: Get failed for $key: $e');
      }
      return null;
    }
  }

  // Delete data
  Future<void> delete(String key) async {
    try {
      await _box?.delete(key);
      if (kDebugMode) {
        print('🗑️ SimpleCacheManager: Deleted $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SimpleCacheManager: Delete failed for $key: $e');
      }
    }
  }

  // Clear all
  Future<void> clear() async {
    try {
      await _box?.clear();
      if (kDebugMode) {
        print('🧹 SimpleCacheManager: Cleared all cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SimpleCacheManager: Clear failed: $e');
      }
    }
  }
}

// Cache keys
class CacheKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String lastLoginTime = 'last_login_time';
}

class HiveBoxNames {
  HiveBoxNames._();

  static const String auth = 'ok_crm_auth';
  static const String simpleCache = 'simple_cache';
}
