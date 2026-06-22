import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gen/gen.dart';

/// Explicit panel input styling so fields stay visible on white surfaces
/// (Material 3 may otherwise use [ColorScheme.outline], which is too light).
abstract final class PanelInputDecoration {
  static InputDecoration build({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
      borderSide: const BorderSide(color: AppUiTokens.border),
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppUiTokens.radiusSm)),
      borderSide: BorderSide(color: ColorName.primary, width: 1.5),
    );

    return InputDecoration(
      filled: true,
      fillColor: AppUiTokens.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space16,
        vertical: AppUiTokens.space16,
      ),
      hintText: hintText,
      hintStyle: const TextStyle(color: AppUiTokens.textMuted),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabelWithHint,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: border,
      focusedErrorBorder: focusedBorder,
      disabledBorder: border,
    );
  }
}

class PanelTextField extends StatelessWidget {
  const PanelTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          style: TextStyle(
            color: AppUiTokens.textPrimary,
            fontSize: 15,
            height: minLines != null && minLines! > 1 ? 1.5 : null,
          ),
          decoration: PanelInputDecoration.build(
            hintText: label,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: AppUiTokens.textMuted),
            suffixIcon: suffixIcon,
            alignLabelWithHint: minLines != null && minLines! > 1,
          ),
        ),
      ],
    );
  }
}
