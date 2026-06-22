import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

/// Brand side of auth screens — company identity and product highlights.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ColorName.primaryDark,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiTokens.space40,
            vertical: AppUiTokens.space40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandLogo(),
              const SizedBox(height: AppUiTokens.space32),
              Text(
                'Ok Teknik Metal',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppUiTokens.space8),
              Text(
                'Yerel CRM Yönetim Paneli',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppUiTokens.space24),
              Container(
                height: 1,
                width: 48,
                color: ColorName.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: AppUiTokens.space24),
              const _FeatureLine(
                icon: Icons.shield_outlined,
                text: 'Güvenli yerel kimlik doğrulama',
              ),
              const SizedBox(height: AppUiTokens.space12),
              const _FeatureLine(
                icon: Icons.storage_outlined,
                text: 'Veriler cihazınızda saklanır',
              ),
              const SizedBox(height: AppUiTokens.space12),
              const _FeatureLine(
                icon: Icons.desktop_windows_outlined,
                text: 'Masaüstü CRM deneyimi',
              ),
              const Spacer(),
              Text(
                'Ok Teknik Metal CRM · Local Desktop System',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Icon(
        Icons.grid_view_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: ColorName.primary.withValues(alpha: 0.95),
        ),
        const SizedBox(width: AppUiTokens.space12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

/// Compact brand header for narrow auth layouts.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppUiTokens.space24),
      decoration: BoxDecoration(
        color: ColorName.primaryDark,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppUiTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ok Teknik Metal CRM',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Local Desktop System',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
