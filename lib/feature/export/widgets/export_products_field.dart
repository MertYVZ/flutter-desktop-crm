import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class ExportProductsField extends StatelessWidget {
  const ExportProductsField({
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < controllers.length; index++) ...[
          if (index > 0) const SizedBox(height: AppUiTokens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PanelTextField(
                  controller: controllers[index],
                  label: index == 0 ? 'Ürün' : 'Ürün (opsiyonel)',
                  hintText: 'Ürün adı yazın',
                ),
              ),
              if (controllers.length > 1) ...[
                const SizedBox(width: AppUiTokens.space8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: IconButton(
                    tooltip: 'Ürünü kaldır',
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppUiTokens.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: AppUiTokens.space12),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              style: AppInteractiveTheme.outlinedButtonStyle(
                OutlinedButton.styleFrom(
                  foregroundColor: ColorName.primary,
                  backgroundColor: AppUiTokens.accentSoft,
                  side: BorderSide(
                    color: ColorName.primary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                  ),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Ürün ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
