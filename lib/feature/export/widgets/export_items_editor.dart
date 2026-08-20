import 'package:Ok/feature/export/models/export_currency.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_unit_type.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/formatters/decimal_text_input_formatter.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:uuid/uuid.dart';

class ExportItemFormRow {
  ExportItemFormRow({
    String? id,
    this.unitType = PriceOfferUnitType.ton,
    this.wasteUnitType = PriceOfferUnitType.kg,
  })  : id = id ?? const Uuid().v4(),
        productNameController = TextEditingController(),
        quantityController = TextEditingController(),
        wasteQuantityController = TextEditingController(),
        priceController = TextEditingController();

  final String id;
  final TextEditingController productNameController;
  final TextEditingController quantityController;
  final TextEditingController wasteQuantityController;
  final TextEditingController priceController;
  PriceOfferUnitType? unitType;
  PriceOfferUnitType? wasteUnitType;

  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    wasteQuantityController.dispose();
    priceController.dispose();
  }

  void populateFromItem(ExportItemData item) {
    productNameController.text = item.productName;
    unitType = item.unit ?? PriceOfferUnitType.ton;
    quantityController.text = QuantityUtils.formatQuantityInput(item.quantity);
    wasteUnitType = item.wasteUnit ?? unitType ?? PriceOfferUnitType.kg;
    if (item.wasteQuantity > 0) {
      wasteQuantityController.text =
          QuantityUtils.formatQuantityInput(item.wasteQuantity);
    }
    PanelAmountField.setAmountFromMinor(priceController, item.priceMinor);
  }

  ExportItemValidationInput toValidationInput() {
    return ExportItemValidationInput(
      productName: productNameController.text,
      unitType: unitType?.label,
      quantityText: quantityController.text,
      priceText: priceController.text,
      wasteUnitType: wasteUnitType?.label,
      wasteQuantityText: wasteQuantityController.text,
    );
  }

  ExportItemData? toItemData({required int sortOrder}) {
    final name = productNameController.text.trim();
    final quantity = QuantityUtils.parseQuantity(quantityController.text);
    final priceMinor = MoneyUtils.parseAmountToMinor(priceController.text);
    if (name.isEmpty ||
        unitType == null ||
        quantity == null ||
        priceMinor == null) {
      return null;
    }

    return ExportItemData(
      id: id,
      productName: name,
      unitType: unitType!.label,
      quantity: quantity,
      wasteUnitType: wasteUnitType?.label,
      wasteQuantity:
          QuantityUtils.parseQuantity(wasteQuantityController.text) ?? 0,
      priceMinor: priceMinor,
      sortOrder: sortOrder,
    );
  }
}

class ExportItemsEditor extends StatefulWidget {
  const ExportItemsEditor({
    required this.rows,
    required this.currency,
    this.onChanged,
    super.key,
  });

  final List<ExportItemFormRow> rows;
  final PriceOfferCurrencyType currency;
  final VoidCallback? onChanged;

  @override
  State<ExportItemsEditor> createState() => _ExportItemsEditorState();
}

class _ExportItemsEditorState extends State<ExportItemsEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 1100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.rows.length; i++) ...[
                  _ItemRow(
                    key: ValueKey(widget.rows[i].id),
                    index: i,
                    row: widget.rows[i],
                    currency: widget.currency,
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
    widget.rows.add(ExportItemFormRow());
    setState(() {});
    widget.onChanged?.call();
  }

  void _removeRow(int index) {
    if (widget.rows.length <= 1) {
      return;
    }

    widget.rows[index].dispose();
    widget.rows.removeAt(index);
    setState(() {});
    widget.onChanged?.call();
  }
}

class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.index,
    required this.row,
    required this.currency,
    required this.isCompact,
    required this.canRemove,
    required this.onRemove,
    this.onChanged,
    super.key,
  });

  final int index;
  final ExportItemFormRow row;
  final PriceOfferCurrencyType currency;
  final bool isCompact;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback? onChanged;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  @override
  void initState() {
    super.initState();
    widget.row.quantityController.addListener(_refreshRow);
    widget.row.wasteQuantityController.addListener(_refreshRow);
    widget.row.priceController.addListener(_refreshRow);
  }

  @override
  void dispose() {
    widget.row.quantityController.removeListener(_refreshRow);
    widget.row.wasteQuantityController.removeListener(_refreshRow);
    widget.row.priceController.removeListener(_refreshRow);
    super.dispose();
  }

  void _refreshRow() {
    if (!mounted) {
      return;
    }
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
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
                  'Ürün ${widget.index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppUiTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (widget.canRemove)
                  IconButton(
                    tooltip: 'Satırı sil',
                    onPressed: widget.onRemove,
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
            if (widget.isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PanelTextField(
                    controller: row.productNameController,
                    label: 'Ürün Adı',
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelDropdown<PriceOfferUnitType>(
                    label: 'Birim Tipi',
                    hint: 'Birim tipi seçiniz',
                    value: row.unitType,
                    items: PriceOfferUnitType.values,
                    itemLabel: (value) => value.label,
                    onChanged: (value) {
                      row
                        ..unitType = value
                        ..wasteUnitType ??= value;
                      setState(() {});
                      widget.onChanged?.call();
                    },
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelTextField(
                    controller: row.quantityController,
                    label: 'Gönderilen miktar',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [DecimalTextInputFormatter()],
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelAmountField(
                    controller: row.priceController,
                    label: 'Birim fiyat',
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  _ReadOnlyValueCell(
                    label: 'Satır Toplamı',
                    value: _formatSentTotal(row, widget.currency),
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelDropdown<PriceOfferUnitType>(
                    label: 'Fire birimi',
                    hint: 'Birim tipi seçiniz',
                    value: row.wasteUnitType,
                    items: PriceOfferUnitType.values,
                    itemLabel: (value) => value.label,
                    onChanged: (value) {
                      row.wasteUnitType = value;
                      setState(() {});
                      widget.onChanged?.call();
                    },
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  PanelTextField(
                    controller: row.wasteQuantityController,
                    label: 'Fire miktarı',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [DecimalTextInputFormatter()],
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  _ReadOnlyValueCell(
                    label: 'Fire tutarı',
                    value: _formatWasteTotal(row, widget.currency),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: PanelTextField(
                          controller: row.productNameController,
                          label: 'Ürün Adı',
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
                            row
                              ..unitType = value
                              ..wasteUnitType ??= value;
                            setState(() {});
                            widget.onChanged?.call();
                          },
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space12),
                      Expanded(
                        flex: 2,
                        child: PanelTextField(
                          controller: row.quantityController,
                          label: 'Gönderilen miktar',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: const [DecimalTextInputFormatter()],
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space12),
                      Expanded(
                        flex: 2,
                        child: PanelAmountField(
                          controller: row.priceController,
                          label: 'Birim fiyat',
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space12),
                      Expanded(
                        flex: 2,
                        child: _ReadOnlyValueCell(
                          label: 'Satır Toplamı',
                          value: _formatSentTotal(row, widget.currency),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppUiTokens.space12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: PanelDropdown<PriceOfferUnitType>(
                          label: 'Fire birimi',
                          hint: 'Birim tipi seçiniz',
                          value: row.wasteUnitType,
                          items: PriceOfferUnitType.values,
                          itemLabel: (value) => value.label,
                          onChanged: (value) {
                            row.wasteUnitType = value;
                            setState(() {});
                            widget.onChanged?.call();
                          },
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space12),
                      Expanded(
                        flex: 2,
                        child: PanelTextField(
                          controller: row.wasteQuantityController,
                          label: 'Fire miktarı',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: const [DecimalTextInputFormatter()],
                        ),
                      ),
                      const SizedBox(width: AppUiTokens.space12),
                      Expanded(
                        flex: 2,
                        child: _ReadOnlyValueCell(
                          label: 'Fire tutarı',
                          value: _formatWasteTotal(row, widget.currency),
                        ),
                      ),
                      const Expanded(flex: 6, child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

String _formatSentTotal(
  ExportItemFormRow row,
  PriceOfferCurrencyType currency,
) {
  final item = row.toItemData(sortOrder: 0);
  if (item == null) {
    return '—';
  }

  return MoneyUtils.formatAmountMinor(
    item.sentTotalMinor,
    mapExportCurrency(currency),
  );
}

String _formatWasteTotal(
  ExportItemFormRow row,
  PriceOfferCurrencyType currency,
) {
  final item = row.toItemData(sortOrder: 0);
  if (item == null || item.wasteQuantity <= 0) {
    return '—';
  }

  return MoneyUtils.formatAmountMinor(
    item.wasteTotalMinor,
    mapExportCurrency(currency),
  );
}

class _ReadOnlyValueCell extends StatelessWidget {
  const _ReadOnlyValueCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const _fieldHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == '—';

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
