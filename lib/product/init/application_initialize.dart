import 'dart:async';
import 'dart:io';

import 'package:Ok/product/cache/simple_cache_manager.dart';
import 'package:Ok/product/init/config/app_environment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gen/gen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

@immutable

/// Application Initialize
final class ApplicationInitialize {
  Future<void> makeInitialize() async {
    await runZonedGuarded(_initialize, (error, stackTrace) {
      Logger().e(error.toString());
    });
  }

  Future<void> _initialize() async {
    await EasyLocalization.ensureInitialized();

    // Basic Cache Manager'ı initialize et
    await SimpleCacheManager.instance.initialize();
    await Hive.openBox<String>(HiveBoxNames.auth);

    if (Platform.isAndroid || Platform.isIOS) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    }

    //TODO: Firebase initialize et
    /*  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); */
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      // Known Flutter macOS issue when a key is held during app launch/focus.
      if (message.contains('KeyDownEvent is dispatched') &&
          message.contains('_pressedKeys.containsKey')) {
        return;
      }
      Logger().e(message);
    };

    AppEnvironment.setup(config: DevEnv());
  }
}
