import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class PanelPrimaryButton extends StatelessWidget {
  const PanelPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: AppInteractiveTheme.filledButtonStyle(
          FilledButton.styleFrom(
            backgroundColor: ColorName.primary,
            foregroundColor: ColorName.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
