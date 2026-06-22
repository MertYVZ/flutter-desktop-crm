// ignore_for_file: avoid_catches_without_on_clauses, document_ignores, lines_longer_than_80_chars, prefer_constructors_over_static_methods

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Senior Flutter Developer tarafından tasarlanmış cache manager
/// Hive tabanlı, type-safe, performanslı cache sistemi
class CacheManager {
  CacheManager._internal();

  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._internal();

  // Cache box'ları
  late Box<String> _generalBox;
  late Box<String> _userBox;
  late Box<String> _secureBox;
  late Box<String> _tempBox;

  /// Cache manager'ı initialize et
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Box'ları aç
      _generalBox = await Hive.openBox<String>('general_cache');
      _userBox = await Hive.openBox<String>('user_cache');
      _secureBox = await Hive.openBox<String>('secure_cache');
      _tempBox = await Hive.openBox<String>('temp_cache');

      if (kDebugMode) {
        log('💾 CacheManager: Successfully initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        log('❌ CacheManager: Initialization failed - $e');
      }
      rethrow;
    }
  }

  /// Generic cache operations

  /// Cache'e data kaydet
  Future<void> setData<T>({
    required String key,
    required T data,
    CacheBox box = CacheBox.general,
    Duration? expiry,
  }) async {
    try {
      final cacheData = CacheData<T>(
        data: data,
        timestamp: DateTime.now(),
        expiry: expiry,
      );

      final jsonString = jsonEncode(cacheData.toJson());
      await _getBox(box).put(key, jsonString);

      if (kDebugMode) {
        log('💾 CacheManager: Saved $key to ${box.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        log('❌ CacheManager: Failed to save $key - $e');
      }
    }
  }

  /// Cache'den data oku
  T? getData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    CacheBox box = CacheBox.general,
  }) {
    try {
      final jsonString = _getBox(box).get(key);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final cacheData = CacheData.fromJson<T>(json, fromJson);

      // Expiry kontrolü
      if (cacheData.isExpired) {
        deleteData(key: key, box: box);
        if (kDebugMode) {
          log('⏰ CacheManager: $key expired, removed from cache');
        }
        return null;
      }

      if (kDebugMode) {
        log('💾 CacheManager: Retrieved $key from ${box.name}');
      }

      return cacheData.data;
    } catch (e) {
      if (kDebugMode) {
        log('❌ CacheManager: Failed to retrieve $key - $e');
      }
      return null;
    }
  }

  /// Cache'den data sil
  Future<void> deleteData({
    required String key,
    CacheBox box = CacheBox.general,
  }) async {
    try {
      await _getBox(box).delete(key);
      if (kDebugMode) {
        log('🗑️ CacheManager: Deleted $key from ${box.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        log('❌ CacheManager: Failed to delete $key - $e');
      }
    }
  }

  /// Specific cache operations

  /// User data cache
  Future<void> setUserData<T>({
    required String userId,
    required String key,
    required T data,
    Duration? expiry,
  }) async {
    final userKey = '${userId}_$key';
    await setData(
      key: userKey,
      data: data,
      box: CacheBox.user,
      expiry: expiry,
    );
  }

  T? getUserData<T>({
    required String userId,
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final userKey = '${userId}_$key';
    return getData(
      key: userKey,
      fromJson: fromJson,
      box: CacheBox.user,
    );
  }

  /// Secure data cache (tokens, sensitive info)
  Future<void> setSecureData<T>({
    required String key,
    required T data,
    Duration? expiry,
  }) async {
    await setData(
      key: key,
      data: data,
      box: CacheBox.secure,
      expiry: expiry,
    );
  }

  T? getSecureData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return getData(
      key: key,
      fromJson: fromJson,
      box: CacheBox.secure,
    );
  }

  /// Temp cache (short-term data)
  Future<void> setTempData<T>({
    required String key,
    required T data,
    Duration expiry = const Duration(minutes: 30),
  }) async {
    await setData(
      key: key,
      data: data,
      box: CacheBox.temp,
      expiry: expiry,
    );
  }

  T? getTempData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return getData(
      key: key,
      fromJson: fromJson,
      box: CacheBox.temp,
    );
  }

  /// Cache management operations

  /// Belirli bir box'ı temizle
  Future<void> clearBox(CacheBox box) async {
    try {
      await _getBox(box).clear();
      if (kDebugMode) {
        log('🧹 CacheManager: Cleared ${box.name} box');
      }
    } catch (e) {
      if (kDebugMode) {
        log('❌ CacheManager: Failed to clear ${box.name} - $e');
      }
    }
  }

  /// Tüm cache'i temizle
  Future<void> clearAll() async {
    await Future.wait([
      clearBox(CacheBox.general),
      clearBox(CacheBox.user),
      clearBox(CacheBox.temp),
      // Secure box'ı temizleme - sadece logout'ta
    ]);
  }

  /// Expired cache'leri temizle
  Future<void> clearExpired() async {
    for (final box in CacheBox.values) {
      try {
        final hiveBox = _getBox(box);
        final keysToDelete = <String>[];

        for (final key in hiveBox.keys) {
          final jsonString = hiveBox.get(key);
          if (jsonString != null) {
            try {
              final json = jsonDecode(jsonString) as Map<String, dynamic>;
              final timestamp = DateTime.parse(json['timestamp'] as String);
              final expiryMinutes = json['expiryMinutes'] as int?;

              if (expiryMinutes != null) {
                final expiry = timestamp.add(Duration(minutes: expiryMinutes));
                if (DateTime.now().isAfter(expiry)) {
                  keysToDelete.add(key as String);
                }
              }
            } catch (e) {
              // Invalid cache data, mark for deletion
              keysToDelete.add(key as String);
            }
          }
        }

        for (final key in keysToDelete) {
          await hiveBox.delete(key);
        }

        if (kDebugMode && keysToDelete.isNotEmpty) {
          log('🧹 CacheManager: Cleared ${keysToDelete.length} expired items '
              'from ${box.name}');
        }
      } catch (e) {
        if (kDebugMode) {
          log('❌ CacheManager: Failed to clear expired from ${box.name} - $e');
        }
      }
    }
  }

  /// Cache statistics
  Map<String, int> getCacheStats() {
    return {
      'general': _generalBox.length,
      'user': _userBox.length,
      'secure': _secureBox.length,
      'temp': _tempBox.length,
    };
  }

  /// Helper methods
  Box<String> _getBox(CacheBox box) {
    switch (box) {
      case CacheBox.general:
        return _generalBox;
      case CacheBox.user:
        return _userBox;
      case CacheBox.secure:
        return _secureBox;
      case CacheBox.temp:
        return _tempBox;
    }
  }

  /// Cache manager'ı kapat
  Future<void> dispose() async {
    await Future.wait([
      _generalBox.close(),
      _userBox.close(),
      _secureBox.close(),
      _tempBox.close(),
    ]);
  }
}

/// Cache box türleri
enum CacheBox {
  general('general'),
  user('user'),
  secure('secure'),
  temp('temp');

  const CacheBox(this.name);
  final String name;
}

/// Cache data wrapper
class CacheData<T> {
  const CacheData({
    required this.data,
    required this.timestamp,
    this.expiry,
  });

  final T data;
  final DateTime timestamp;
  final Duration? expiry;

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().isAfter(timestamp.add(expiry!));
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiryMinutes': expiry?.inMinutes,
    };
  }

  static CacheData<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return CacheData<T>(
      data: fromJsonT(json['data'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiry: json['expiryMinutes'] != null
          ? Duration(minutes: json['expiryMinutes'] as int)
          : null,
    );
  }
}

/// Cache keys - Centralized key management
class CacheKeys {
  // User related
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';
  static const String likedMovies = 'liked_movies';

  // Auth related
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String lastLoginTime = 'last_login_time';

  // App data
  static const String appSettings = 'app_settings';
  static const String movieCategories = 'movie_categories';
  static const String featuredMovies = 'featured_movies';

  // Temp data
  static const String searchHistory = 'search_history';
  static const String recentlyViewed = 'recently_viewed';
}
