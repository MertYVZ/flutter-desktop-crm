import 'package:Ok/feature/auth/splash/controller/splash_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<SplashController>(
      viewModel: Get.find<SplashController>(),
      onPageBuilder: (context, controller) =>
          _SplashBody(controller: controller),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppUiTokens.pageBackground,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppUiTokens.space24),
          child: PanelSurface(
            maxWidth: 420,
            child: _SplashLoader(controller: controller),
          ),
        ),
      ),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader({required this.controller});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppUiTokens.accentSoft,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: ColorName.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: AppUiTokens.space24),
          Text(
            'Ok Teknik Metal CRM',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppUiTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppUiTokens.space8),
          Text(
            'Hazırlanıyor',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: AppUiTokens.space8),
          Text(
            'Oturum ve veritabanı kontrol ediliyor...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppUiTokens.textSecondary,
                ),
          ),
          if (controller.isPreparing.value) ...[
            const SizedBox(height: AppUiTokens.space32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: ColorName.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
