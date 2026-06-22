import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceOffersFilters extends StatelessWidget {
  const PriceOffersFilters({
    required this.controller,
    required this.searchController,
    super.key,
  });

  final PriceOffersController controller;
  final TextEditingController searchController;

  static const _fieldHeight = 38.0;
  static const _searchWidth = 290.0;
  static const _dropdownWidth = 160.0;
  static const _compactBreakpoint = 960.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;

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
              controller.searchAndFilterOffers();
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
          () => PanelDropdown<OfferType?>(
            label: 'Tip',
            hint: 'Tip',
            compact: true,
            value: controller.selectedTypeFilter.value,
            items: const [
              null,
              ...OfferType.values,
            ],
            itemLabel: (value) {
              if (value == null) {
                return 'Tümü';
              }
              return value.label;
            },
            onChanged: (value) {
              controller.selectedTypeFilter.value = value;
              controller.searchAndFilterOffers();
            },
          ),
        );

        final statusFilter = Obx(
          () => PanelDropdown<PriceOfferStatus?>(
            label: 'Durum',
            hint: 'Durum',
            compact: true,
            value: controller.selectedStatusFilter.value,
            items: const [
              null,
              ...PriceOfferStatus.values,
            ],
            itemLabel: (value) {
              if (value == null) {
                return 'Tümü';
              }
              return value.label;
            },
            onChanged: (value) {
              controller.selectedStatusFilter.value = value;
              controller.searchAndFilterOffers();
            },
          ),
        );

        final dateRangeFilter = Obx(
          () => _PriceOfferDateRangeFilter(
            isCompact: isCompact,
            startDate: controller.startDateFilter.value,
            endDate: controller.endDateFilter.value,
            onStartDateSelected: (date) {
              controller.startDateFilter.value = date;
              controller.searchAndFilterOffers();
            },
            onEndDateSelected: (date) {
              controller.endDateFilter.value = date;
              controller.searchAndFilterOffers();
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
            'Filtreleri Temizle',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        );

        final warning = Obx(() {
          final message = controller.filterWarningMessage.value;
          if (message == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: AppUiTokens.space8),
            child: PanelMessage(message: message),
          );
        });

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
                  SizedBox(width: _dropdownWidth, child: typeFilter),
                  SizedBox(width: _dropdownWidth, child: statusFilter),
                  clearButton,
                ],
              ),
              const SizedBox(height: AppUiTokens.space8),
              dateRangeFilter,
              warning,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppUiTokens.space8,
              runSpacing: AppUiTokens.space8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                searchField,
                SizedBox(width: _dropdownWidth, child: typeFilter),
                SizedBox(width: _dropdownWidth, child: statusFilter),
                dateRangeFilter,
                clearButton,
              ],
            ),
            warning,
          ],
        );
      },
    );
  }
}

class _PriceOfferDateRangeFilter extends StatelessWidget {
  const _PriceOfferDateRangeFilter({
    required this.isCompact,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
  });

  final bool isCompact;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateSelected;
  final ValueChanged<DateTime?> onEndDateSelected;

  static const _fieldWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppUiTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? null : 13,
        );

    final startField = AppDatePickerField(
      key: ValueKey(startDate),
      placeholder: 'Başlangıç',
      compact: true,
      selectedDate: startDate,
      onDateSelected: onStartDateSelected,
    );

    final endField = AppDatePickerField(
      key: ValueKey(endDate),
      placeholder: 'Bitiş',
      compact: true,
      selectedDate: endDate,
      onDateSelected: onEndDateSelected,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tarih', style: labelStyle),
          const SizedBox(height: AppUiTokens.space8),
          Row(
            children: [
              Expanded(child: startField),
              const SizedBox(width: AppUiTokens.space8),
              Expanded(child: endField),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Tarih', style: labelStyle),
        const SizedBox(width: AppUiTokens.space8),
        SizedBox(width: _fieldWidth, child: startField),
        const SizedBox(width: AppUiTokens.space8),
        Text(
          '—',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textMuted,
              ),
        ),
        const SizedBox(width: AppUiTokens.space8),
        SizedBox(width: _fieldWidth, child: endField),
      ],
    );
  }
}
