import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrapQualityFilters extends StatelessWidget {
  const ScrapQualityFilters({
    required this.controller,
    required this.searchController,
    super.key,
  });

  final ScrapQualityController controller;
  final TextEditingController searchController;

  static const _fieldHeight = 38.0;
  static const _searchWidth = 290.0;
  static const _dropdownWidth = 170.0;
  static const _compactBreakpoint = 720.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;

        return Obx(() {
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
                controller.searchAndFilterRecords();
              },
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Müşteri, tür, il, not...',
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

          final statusFilter = PanelDropdown<ScrapSalesStatus?>(
            label: 'Satış Durumu',
            hint: 'Tümü',
            compact: true,
            value: controller.selectedSalesStatusFilter.value,
            items: const [null, ...ScrapSalesStatus.values],
            itemLabel: (value) => value?.label ?? 'Tümü',
            onChanged: (value) {
              controller.selectedSalesStatusFilter.value = value;
              controller.onlyPurchasedFilter.value = false;
              controller.onlyNotPurchasedFilter.value = false;
              controller.onlyPendingFilter.value = false;
              controller.searchAndFilterRecords();
            },
          );

          final scrapTypeFilter = PanelDropdown<ScrapType?>(
            label: 'Kalite / Tür',
            hint: 'Tümü',
            compact: true,
            value: ScrapTypeX.fromLabel(
              controller.selectedScrapTypeFilter.value,
            ),
            items: const [null, ...ScrapType.values],
            itemLabel: (value) => value?.label ?? 'Tümü',
            onChanged: (value) {
              controller.selectedScrapTypeFilter.value = value?.label;
              controller.searchAndFilterRecords();
            },
          );

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
                const SizedBox(height: AppUiTokens.space8),
                Wrap(
                  spacing: AppUiTokens.space8,
                  runSpacing: AppUiTokens.space8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(width: _dropdownWidth, child: scrapTypeFilter),
                    SizedBox(width: _dropdownWidth, child: statusFilter),
                    clearButton,
                  ],
                ),
              ],
            );
          }

          return Wrap(
            spacing: AppUiTokens.space8,
            runSpacing: AppUiTokens.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              searchField,
              SizedBox(width: _dropdownWidth, child: scrapTypeFilter),
              SizedBox(width: _dropdownWidth, child: statusFilter),
              clearButton,
            ],
          );
        });
      },
    );
  }
}
