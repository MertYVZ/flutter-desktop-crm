import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class PriceListProductsTable extends StatelessWidget {
  const PriceListProductsTable({
    required this.controller,
    required this.items,
    required this.readOnly,
    this.onEdit,
    this.onDelete,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.availableWidth,
    super.key,
  });

  final PriceListController controller;
  final List<PriceListItemModel> items;
  final bool readOnly;
  final void Function(PriceListItemModel item)? onEdit;
  final void Function(PriceListItemModel item)? onDelete;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  final double? availableWidth;

  static const _headingStyle = TextStyle(
    color: AppUiTokens.textSecondary,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const _dataStyle = TextStyle(
    color: AppUiTokens.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const _headerRowHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space24),
      child: Obx(() {
        final isLoading = controller.isLoading.value;
        final isDeleting = controller.isDeleting.value;
        final deletingId = controller.deletingItemId.value;

        if (isLoading && items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppUiTokens.space24,
              vertical: AppUiTokens.space24,
            ),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (items.isEmpty) {
          final hasFilters = controller.hasActiveProductFilters;
          final message = hasFilters
              ? 'Kriterlere uygun ürün bulunamadı.'
              : 'Henüz ürün eklenmemiş.';
          final showAction =
              !hasFilters && onEmptyAction != null && emptyActionLabel != null;

          return AppTableEmptyState(
            message: message,
            icon: hasFilters
                ? Icons.search_off_outlined
                : Icons.inventory_2_outlined,
            actionLabel: showAction ? emptyActionLabel : null,
            onAction: showAction ? onEmptyAction : null,
            actionFilled: true,
            verticalPadding: AppUiTokens.space32,
          );
        }

        final showActions = !readOnly && (onEdit != null || onDelete != null);

        final table = Table(
          columnWidths: {
            0: const FlexColumnWidth(3),
            1: const FlexColumnWidth(1.2),
            2: const FlexColumnWidth(1.5),
            3: const FlexColumnWidth(1.5),
            if (showActions) 4: const FixedColumnWidth(120),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppUiTokens.border),
                ),
              ),
              children: [
                _headerCell('Ürün Adı'),
                _headerCell('Para Birimi'),
                _headerCell('Min Fiyat'),
                _headerCell('Max Fiyat'),
                if (showActions) _headerCell(''),
              ],
            ),
            ...items.map((item) {
              final currency = _mapCurrency(item);
              return TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppUiTokens.border),
                  ),
                ),
                children: [
                  _dataCell(item.productName),
                  _dataCell(item.currencyType?.label ?? item.currency),
                  _dataCell(
                    MoneyUtils.formatAmountMinor(item.minPriceMinor, currency),
                  ),
                  _dataCell(
                    MoneyUtils.formatAmountMinor(item.maxPriceMinor, currency),
                  ),
                  if (showActions)
                    _actionsCell(
                      item: item,
                      isDeleting: isDeleting && deletingId == item.id,
                    ),
                ],
              );
            }),
          ],
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            const horizontalPadding = AppUiTokens.space24 * 2;
            final minTableWidth =
                (availableWidth ?? constraints.maxWidth) - horizontalPadding;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: minTableWidth,
                ),
                child: table,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _actionsCell({
    required PriceListItemModel item,
    required bool isDeleting,
  }) {
    return SizedBox(
      height: _headerRowHeight + 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onEdit != null)
            IconButton(
              tooltip: 'Düzenle',
              onPressed: isDeleting ? null : () => onEdit!(item),
              icon: const Icon(Icons.edit_outlined, size: 18),
              style: AppInteractiveTheme.iconButtonStyle(
                IconButton.styleFrom(
                  foregroundColor: AppUiTokens.textSecondary,
                ),
              ),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Sil',
              onPressed: isDeleting ? null : () => onDelete!(item),
              icon: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              style: AppInteractiveTheme.iconButtonStyle(
                IconButton.styleFrom(
                  foregroundColor: ColorName.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  CurrencyType _mapCurrency(PriceListItemModel item) {
    switch (item.currencyType?.value ?? item.currency) {
      case 'USD':
        return CurrencyType.usd;
      case 'EUR':
        return CurrencyType.eur;
      default:
        return CurrencyType.try_;
    }
  }

  Widget _headerCell(String text) {
    return SizedBox(
      height: _headerRowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space8),
          child: Text(text, style: _headingStyle),
        ),
      ),
    );
  }

  Widget _dataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space8,
        vertical: AppUiTokens.space12,
      ),
      child: Text(text, style: _dataStyle),
    );
  }
}
