import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/formatters/turkish_amount_input_formatter.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';

class PanelAmountField extends StatelessWidget {
  const PanelAmountField({
    required this.controller,
    required this.label,
    this.hintText,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  static void setAmountFromMinor(
    TextEditingController controller,
    int amountMinor,
  ) {
    final formatted = MoneyUtils.formatAmountInputFromMinor(amountMinor);
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [
            TurkishAmountInputFormatter(),
          ],
          onChanged: onChanged,
          style: const TextStyle(
            color: AppUiTokens.textPrimary,
            fontSize: 15,
          ),
          decoration: PanelInputDecoration.build(
            hintText: hintText ?? '0,00',
          ),
        ),
      ],
    );
  }
}
