import 'package:Ok/feature/export/controllers/export_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExportFilters extends StatelessWidget {
  const ExportFilters({
    required this.controller,
    required this.searchController,
    super.key,
  });

  final ExportController controller;
  final TextEditingController searchController;

  static const _fieldHeight = 38.0;
  static const _searchWidth = 290.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final searchField = SizedBox(
          width: isCompact ? null : _searchWidth,
          height: _fieldHeight,
          child: TextField(
            controller: searchController,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 14,
            ),
            onChanged: (value) {
              controller.searchQuery.value = value;
              controller.searchAndFilterExports();
            },
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Ara...',
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

        return Obx(() {
          final clearButton = controller.hasActiveFilters
              ? TextButton(
                  onPressed: () {
                    searchController.clear();
                    controller.clearFilters();
                  },
                  style: AppInteractiveTheme.textButtonStyle(
                    TextButton.styleFrom(
                      foregroundColor: AppUiTokens.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppUiTokens.space12,
                      ),
                      minimumSize: const Size(0, _fieldHeight),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  child: const Text(
                    'Filtreleri Temizle',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                )
              : const SizedBox.shrink();

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                if (controller.hasActiveFilters) ...[
                  const SizedBox(height: AppUiTokens.space8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: clearButton,
                  ),
                ],
              ],
            );
          }

          return Wrap(
            spacing: AppUiTokens.space8,
            runSpacing: AppUiTokens.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              searchField,
              clearButton,
            ],
          );
        });
      },
    );
  }
}
