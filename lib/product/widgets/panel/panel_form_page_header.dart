import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';

class PanelFormPageHeader extends StatelessWidget {
  const PanelFormPageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Geri',
          icon: const Icon(Icons.arrow_back_rounded),
          style: AppInteractiveTheme.iconButtonStyle(
            IconButton.styleFrom(foregroundColor: AppUiTokens.textSecondary),
          ),
        ),
        const SizedBox(width: AppUiTokens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppUiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: AppUiTokens.space8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
