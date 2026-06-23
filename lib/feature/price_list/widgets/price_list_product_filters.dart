import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceListProductFilters extends StatelessWidget {
  const PriceListProductFilters({
    required this.controller,
    required this.searchController,
    super.key,
  });

  final PriceListController controller;
  final TextEditingController searchController;

  static const _fieldHeight = 38.0;
  static const _maxSearchWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchWidth = constraints.maxWidth.clamp(0.0, _maxSearchWidth);

        final searchField = SizedBox(
          width: searchWidth,
          height: _fieldHeight,
          child: TextField(
            controller: searchController,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 14,
            ),
            onChanged: (value) {
              controller.productSearchQuery.value = value;
              controller.searchActiveItems();
            },
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Ürün adı veya para birimi ara...',
              hintStyle: TextStyle(
                color: AppUiTokens.textMuted,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: AppUiTokens.textMuted,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppUiTokens.space12,
                vertical: AppUiTokens.space8,
              ),
            ),
          ),
        );

        final clearButton = Obx(
          () {
            if (!controller.hasActiveProductFilters) {
              return const SizedBox.shrink();
            }

            return TextButton(
              onPressed: () {
                searchController.clear();
                controller.clearProductFilters();
              },
              style: AppInteractiveTheme.textButtonStyle(
                TextButton.styleFrom(
                  foregroundColor: AppUiTokens.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space12,
                  ),
                ),
              ),
              child: const Text(
                'Temizle',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            );
          },
        );

        return Row(
          children: [
            searchField,
            const SizedBox(width: AppUiTokens.space8),
            clearButton,
          ],
        );
      },
    );
  }
}
