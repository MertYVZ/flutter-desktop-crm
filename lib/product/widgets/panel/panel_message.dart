import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

enum PanelMessageType { error, info }

class PanelMessage extends StatelessWidget {
  const PanelMessage({
    required this.message,
    this.type = PanelMessageType.error,
    super.key,
  });

  final String message;
  final PanelMessageType type;

  @override
  Widget build(BuildContext context) {
    final isError = type == PanelMessageType.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space12,
        vertical: AppUiTokens.space12,
      ),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : AppUiTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        border: Border.all(
          color: isError ? const Color(0xFFFECACA) : AppUiTokens.border,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? ColorName.error : AppUiTokens.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}
