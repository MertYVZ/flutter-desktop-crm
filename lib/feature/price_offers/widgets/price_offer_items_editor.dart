import 'package:Ok/feature/due_tracking/models/currency_type.dart' as due_currency;
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_unit_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:uuid/uuid.dart';

class PriceOfferItemFormRow {
  PriceOfferItemFormRow({
    String? id,
    PriceOfferCurrencyType currency = PriceOfferCurrencyType.try_,
  })  : id = id ?? const Uuid().v4(),
        productNameController = TextEditingController(),
        quantityController = TextEditingController(),
        priceController = TextEditingController(),
        currency = currency;

  final String id;
  final TextEditingController productNameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  PriceOfferUnitType? unitType;
  PriceOfferCurrencyType currency;

  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }

  void populateFromItem(PriceOfferItemData item) {
    productNameController.text = item.productName;
    unitType = PriceOfferUnitType.fromLabel(item.unitType);
    quantityController.text = QuantityUtils.formatQuantityInput(item.quantity);
    PanelAmountField.setAmountFromMinor(priceController, item.priceMinor);
    currency = item.currencyType ?? PriceOfferCurrencyType.try_;
  }
}

class PriceOfferItemsEditor extends StatefulWidget {
  const PriceOfferItemsEditor({
    required this.rows,
    required this.onChanged,
    super.key,
  });

  final List<PriceOfferItemFormRow> rows;
  final VoidCallback onChanged;

  @override
  State<PriceOfferItemsEditor> createState() => _PriceOfferItemsEditorState();
}

class _PriceOfferItemsEditorState extends State<PriceOfferItemsEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 900;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.rows.length; i++) ...[
                  _ItemRow(
                    index: i,
                    row: widget.rows[i],
                    isCompact: isCompact,
                    canRemove: widget.rows.length > 1,
                    onRemove: () => _removeRow(i),
                    onChanged: widget.onChanged,
                  ),
                  if (i < widget.rows.length - 1)
                    const SizedBox(height: AppUiTokens.space16),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AppUiTokens.space16),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _addRow,
              style: AppInteractiveTheme.outlinedButtonStyle(
                OutlinedButton.styleFrom(
                  foregroundColor: ColorName.primary,
                  backgroundColor: AppUiTokens.accentSoft,
                  side: BorderSide(
                    color: ColorName.primary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                  ),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Ürün Ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addRow() {
    widget.rows.add(PriceOfferItemFormRow());
    widget.onChanged();
    setState(() {});
  }

  void _removeRow(int index) {
    if (widget.rows.length <= 1) {
      return;
    }

    widget.rows[index].dispose();
    widget.rows.removeAt(index);
    widget.onChanged();
    setState(() {});
  }

}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.index,
    required this.row,
    required this.isCompact,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final PriceOfferItemFormRow row;
  final bool isCompact;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppUiTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(color: AppUiTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppUiTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Ürün ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppUiTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    tooltip: 'Satırı sil',
                    onPressed: onRemove,
                    mouseCursor: SystemMouseCursors.click,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppUiTokens.textSecondary,
                    ),
                    style: AppInteractiveTheme.iconButtonStyle(
                      IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppUiTokens.space12),
            if (isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PanelTextField(
                    controller: row.productNameController,
                    label: 'Ürün Adı',
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelDropdown<PriceOfferUnitType>(
                    label: 'Birim Tipi',
                    hint: 'Birim tipi seçiniz',
                    value: row.unitType,
                    items: PriceOfferUnitType.values,
                    itemLabel: (value) => value.label,
                    onChanged: (value) {
                      row.unitType = value;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelTextField(
                    controller: row.quantityController,
                    label: 'Miktar',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelAmountField(
                    controller: row.priceController,
                    label: 'Fiyat',
                    onChanged: (_) => onChanged(),
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelDropdown<PriceOfferCurrencyType>(
                    label: 'Para Birimi',
                    hint: 'Para birimi seçiniz',
                    value: row.currency,
                    items: PriceOfferCurrencyType.values,
                    itemLabel: (value) => value.label,
                    onChanged: (value) {
                      if (value != null) {
                        row.currency = value;
                        onChanged();
                      }
                    },
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  _RowTotalCell(value: _formatRowTotal(row)),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: PanelTextField(
                      controller: row.productNameController,
                      label: 'Ürün Adı',
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: AppUiTokens.space12),
                  Expanded(
                    flex: 2,
                    child: PanelDropdown<PriceOfferUnitType>(
                      label: 'Birim Tipi',
                      hint: 'Birim tipi seçiniz',
                      value: row.unitType,
                      items: PriceOfferUnitType.values,
                      itemLabel: (value) => value.label,
                      onChanged: (value) {
                        row.unitType = value;
                        onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: AppUiTokens.space12),
                  Expanded(
                    flex: 2,
                    child: PanelTextField(
                      controller: row.quantityController,
                      label: 'Miktar',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: AppUiTokens.space12),
                  Expanded(
                    flex: 2,
                    child: PanelAmountField(
                      controller: row.priceController,
                      label: 'Fiyat',
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  const SizedBox(width: AppUiTokens.space12),
                  Expanded(
                    flex: 2,
                    child: PanelDropdown<PriceOfferCurrencyType>(
                      label: 'Para Birimi',
                      hint: 'Para birimi seçiniz',
                      value: row.currency,
                      items: PriceOfferCurrencyType.values,
                      itemLabel: (value) => value.label,
                      onChanged: (value) {
                        if (value != null) {
                          row.currency = value;
                          onChanged();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppUiTokens.space12),
                  Expanded(
                    flex: 2,
                    child: _RowTotalCell(value: _formatRowTotal(row)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

String _formatRowTotal(PriceOfferItemFormRow row) {
  final quantity = QuantityUtils.parseQuantity(row.quantityController.text);
  final priceMinor = MoneyUtils.parseAmountToMinor(row.priceController.text);
  if (quantity == null || priceMinor == null) {
    return '—';
  }

  final totalMinor = (quantity * priceMinor).round();
  return MoneyUtils.formatAmountMinor(
    totalMinor,
    _mapOfferCurrency(row.currency),
  );
}

due_currency.CurrencyType _mapOfferCurrency(PriceOfferCurrencyType currency) {
  switch (currency) {
    case PriceOfferCurrencyType.try_:
      return due_currency.CurrencyType.try_;
    case PriceOfferCurrencyType.usd:
      return due_currency.CurrencyType.usd;
    case PriceOfferCurrencyType.eur:
      return due_currency.CurrencyType.eur;
  }
}

class _RowTotalCell extends StatelessWidget {
  const _RowTotalCell({required this.value});

  final String value;

  static const _label = 'Satır Toplamı';
  static const _fieldHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppUiTokens.surface,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            border: Border.all(color: AppUiTokens.border),
          ),
          child: SizedBox(
            height: _fieldHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppUiTokens.space16,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPlaceholder
                        ? AppUiTokens.textMuted
                        : AppUiTokens.textPrimary,
                    fontSize: 15,
                    fontWeight:
                        isPlaceholder ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
