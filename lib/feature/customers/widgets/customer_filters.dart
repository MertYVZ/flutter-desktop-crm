import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerFilters extends StatelessWidget {
  const CustomerFilters({
    required this.controller,
    required this.searchController,
    super.key,
  });

  final CustomersController controller;
  final TextEditingController searchController;

  static const _fieldHeight = 38.0;
  static const _searchWidth = 290.0;
  static const _dropdownWidth = 160.0;
  static const _compactBreakpoint = 760.0;
  static const _veryNarrowBreakpoint = 420.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;
        final isVeryNarrow = constraints.maxWidth < _veryNarrowBreakpoint;

        final searchField = SizedBox(
          width: isVeryNarrow ? null : _searchWidth,
          height: _fieldHeight,
          child: TextField(
            controller: searchController,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 14,
            ),
            onChanged: (value) {
              controller.searchQuery.value = value;
              controller.searchAndFilterCustomers();
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

        final typeFilter = Obx(
          () => PanelDropdown<CustomerType?>(
            label: 'Tip',
            hint: 'Tip',
            compact: true,
            value: controller.selectedTypeFilter.value,
            items: const [
              null,
              CustomerType.individual,
              CustomerType.corporate,
              CustomerType.foreign,
            ],
            itemLabel: (value) {
              if (value == null) {
                return 'Tümü';
              }
              return value.label;
            },
            onChanged: (value) {
              controller.selectedTypeFilter.value = value;
              controller.searchAndFilterCustomers();
            },
          ),
        );

        final statusFilter = Obx(
          () => PanelDropdown<CustomerStatus?>(
            label: 'Durum',
            hint: 'Durum',
            compact: true,
            value: controller.selectedStatusFilter.value,
            items: const [
              null,
              CustomerStatus.active,
              CustomerStatus.passive,
            ],
            itemLabel: (value) {
              if (value == null) {
                return 'Tümü';
              }
              return value.label;
            },
            onChanged: (value) {
              controller.selectedStatusFilter.value = value;
              controller.searchAndFilterCustomers();
            },
          ),
        );

        final clearButton = TextButton(
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
            'Temizle',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        );

        if (isCompact) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isVeryNarrow
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                searchField,
                const SizedBox(height: AppUiTokens.space8),
                if (isVeryNarrow) ...[
                  SizedBox(width: _dropdownWidth, child: typeFilter),
                  const SizedBox(height: AppUiTokens.space8),
                  SizedBox(width: _dropdownWidth, child: statusFilter),
                  const SizedBox(height: AppUiTokens.space4),
                  clearButton,
                ] else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: _dropdownWidth, child: typeFilter),
                      const SizedBox(width: AppUiTokens.space8),
                      SizedBox(width: _dropdownWidth, child: statusFilter),
                      clearButton,
                    ],
                  ),
              ],
            ),
          );
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              searchField,
              const SizedBox(width: AppUiTokens.space8),
              SizedBox(width: _dropdownWidth, child: typeFilter),
              const SizedBox(width: AppUiTokens.space8),
              SizedBox(width: _dropdownWidth, child: statusFilter),
              clearButton,
            ],
          ),
        );
      },
    );
  }
}
