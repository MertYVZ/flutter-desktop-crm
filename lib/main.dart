import 'package:Ok/feature/shell/controller/shell_controller.dart';
import 'package:Ok/product/init/product_localization.dart';
import 'package:Ok/product/init/theme/custom_dark_theme.dart';
import 'package:Ok/product/init/theme/custom_light_theme.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:widgets/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(ProductLocalization(child: const MyApp()));
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: CustomResponsive.build,
      theme: CustomLightTheme().themeData,
      darkTheme: CustomDarkTheme().themeData,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Ok Teknik Metal CRM',
      initialRoute: AppRoutes.splash.value,
      getPages: AppScreens.routes,
      routingCallback: (routing) {
        if (Get.isRegistered<ShellController>()) {
          Get.find<ShellController>().updateCurrentRoute(
            routing?.current ?? Get.currentRoute,
          );
        }
      },
    );
  }
}
