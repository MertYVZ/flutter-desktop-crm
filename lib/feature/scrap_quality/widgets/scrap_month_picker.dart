import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrapMonthPicker extends StatelessWidget {
  const ScrapMonthPicker({
    required this.controller,
    super.key,
  });

  final ScrapQualityController controller;

  static const _dropdownWidth = 196.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedMonth.value;
      final monthOptions = List.generate(
        12,
        (index) => DateTime(selected.year, index + 1, 1),
      );
      final selectedMonthValue =
          DateTime(selected.year, selected.month, 1);

      return Wrap(
        spacing: AppUiTokens.space8,
        runSpacing: AppUiTokens.space8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton(
            onPressed: controller.goToPreviousMonth,
            style: AppInteractiveTheme.outlinedButtonStyle(
              OutlinedButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppUiTokens.border),
              ),
            ),
            child: const Icon(Icons.chevron_left_rounded, size: 20),
          ),
          SizedBox(
            width: _dropdownWidth,
            child: PanelDropdown<DateTime>(
              label: 'Ay',
              hint: 'Ay seçiniz',
              compact: true,
              value: selectedMonthValue,
              items: monthOptions,
              itemLabel: AppDateUtils.monthYearLabel,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                controller.setSelectedMonth(value);
              },
            ),
          ),
          OutlinedButton(
            onPressed: controller.goToNextMonth,
            style: AppInteractiveTheme.outlinedButtonStyle(
              OutlinedButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppUiTokens.border),
              ),
            ),
            child: const Icon(Icons.chevron_right_rounded, size: 20),
          ),
          TextButton(
            onPressed: controller.goToCurrentMonth,
            style: AppInteractiveTheme.textButtonStyle(
              TextButton.styleFrom(
                foregroundColor: AppUiTokens.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppUiTokens.space12,
                ),
              ),
            ),
            child: const Text(
              'Bu Ay',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    });
  }
}
