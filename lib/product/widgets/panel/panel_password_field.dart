import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';

class PanelPasswordField extends StatelessWidget {
  const PanelPasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return PanelTextField(
      controller: controller,
      label: label,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
      ),
    );
  }
}
