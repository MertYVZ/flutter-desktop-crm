import 'package:Ok/feature/due_tracking/models/currency_type.dart'
    as due_currency;
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_totals.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_items_editor.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/formatters/percentage_input_formatter.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class PriceOfferDiscountSection extends StatefulWidget {
  const PriceOfferDiscountSection({
    required this.itemRows,
    required this.discountType,
    required this.percentageController,
    required this.amountController,
    required this.selectedCurrency,
    required this.onTypeChanged,
    required this.onCurrencyChanged,
    super.key,
  });

  final List<PriceOfferItemFormRow> itemRows;
  final PriceOfferDiscountType discountType;
  final TextEditingController percentageController;
  final TextEditingController amountController;
  final PriceOfferCurrencyType? selectedCurrency;
  final ValueChanged<PriceOfferDiscountType> onTypeChanged;
  final ValueChanged<PriceOfferCurrencyType?> onCurrencyChanged;

  @override
  State<PriceOfferDiscountSection> createState() =>
      _PriceOfferDiscountSectionState();
}

class _PriceOfferDiscountSectionState extends State<PriceOfferDiscountSection> {
  @override
  void initState() {
    super.initState();
    widget.percentageController.addListener(_refresh);
    widget.amountController.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.percentageController.removeListener(_refresh);
    widget.amountController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  List<PriceOfferCurrencyType> get _availableCurrencies {
    final present = <PriceOfferCurrencyType>{
      for (final row in widget.itemRows) row.currency,
    };
    return [
      for (final currency in PriceOfferCurrencyType.values)
        if (present.contains(currency)) currency,
    ];
  }

  Map<PriceOfferCurrencyType, int> get _grossByCurrency {
    final totals = <PriceOfferCurrencyType, double>{};
    for (final row in widget.itemRows) {
      final quantity = QuantityUtils.parseQuantity(row.quantityController.text);
      final priceMinor = MoneyUtils.parseAmountToMinor(row.priceController.text);
      if (quantity == null || priceMinor == null || quantity <= 0) {
        continue;
      }
      totals[row.currency] =
          (totals[row.currency] ?? 0) + quantity * priceMinor;
    }
    return {
      for (final entry in totals.entries) entry.key: entry.value.round(),
    };
  }

  PriceOfferDiscount get _previewDiscount {
    switch (widget.discountType) {
      case PriceOfferDiscountType.none:
        return const PriceOfferDiscount.none();
      case PriceOfferDiscountType.percentage:
        return PriceOfferDiscount(
          type: PriceOfferDiscountType.percentage,
          percentage: double.tryParse(
            widget.percentageController.text.trim().replaceAll(',', '.'),
          ),
        );
      case PriceOfferDiscountType.fixed:
        return PriceOfferDiscount(
          type: PriceOfferDiscountType.fixed,
          amountMinor:
              MoneyUtils.parseAmountToMinor(widget.amountController.text),
          currency: widget.selectedCurrency,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DiscountTypeSelector(
          selectedType: widget.discountType,
          onTypeChanged: widget.onTypeChanged,
        ),
        if (widget.discountType != PriceOfferDiscountType.none) ...[
          const SizedBox(height: AppUiTokens.space16),
          _buildInputs(),
          const SizedBox(height: AppUiTokens.space16),
          _DiscountTotalsPreview(
            totals: PriceOfferTotalsCalculator.apply(
              grossByCurrency: _grossByCurrency,
              discount: _previewDiscount,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputs() {
    switch (widget.discountType) {
      case PriceOfferDiscountType.none:
        return const SizedBox.shrink();
      case PriceOfferDiscountType.percentage:
        return PanelTextField(
          controller: widget.percentageController,
          label: 'İndirim Yüzdesi (%)',
          hintText: 'Örn. 10 (1-100)',
          keyboardType: TextInputType.number,
          inputFormatters: const [PercentageInputFormatter()],
          onChanged: (_) => _refresh(),
        );
      case PriceOfferDiscountType.fixed:
        final available = _availableCurrencies;
        final currencyValue =
            available.contains(widget.selectedCurrency) ? widget.selectedCurrency : null;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 520;

            final amountField = PanelAmountField(
              controller: widget.amountController,
              label: 'İndirim Tutarı',
              onChanged: (_) => _refresh(),
            );

            final currencyField = PanelDropdown<PriceOfferCurrencyType>(
              label: 'İndirim Para Birimi',
              hint: available.isEmpty
                  ? 'Önce ürün ekleyiniz'
                  : 'Para birimi seçiniz',
              value: currencyValue,
              items: available,
              itemLabel: (value) => value.label,
              enabled: available.isNotEmpty,
              onChanged: widget.onCurrencyChanged,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  amountField,
                  const SizedBox(height: AppUiTokens.space12),
                  currencyField,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: amountField),
                const SizedBox(width: AppUiTokens.space12),
                Expanded(child: currencyField),
              ],
            );
          },
        );
    }
  }
}

class _DiscountTypeSelector extends StatelessWidget {
  const _DiscountTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  final PriceOfferDiscountType selectedType;
  final ValueChanged<PriceOfferDiscountType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İndirim Tipi',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Wrap(
          spacing: AppUiTokens.space8,
          runSpacing: AppUiTokens.space8,
          children: PriceOfferDiscountType.values.map((type) {
            final isSelected = selectedType == type;

            return SizedBox(
              height: 38,
              child: OutlinedButton(
                onPressed: () => onTypeChanged(type),
                style: AppInteractiveTheme.outlinedButtonStyle(
                  OutlinedButton.styleFrom(
                    foregroundColor: isSelected
                        ? ColorName.primary
                        : AppUiTokens.textPrimary,
                    backgroundColor: isSelected
                        ? AppUiTokens.accentSoft
                        : AppUiTokens.surface,
                    side: BorderSide(
                      color: isSelected
                          ? ColorName.primary.withValues(alpha: 0.5)
                          : AppUiTokens.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppUiTokens.space16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                    ),
                  ),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DiscountTotalsPreview extends StatelessWidget {
  const _DiscountTotalsPreview({required this.totals});

  final List<PriceOfferCurrencyTotal> totals;

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppUiTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(color: AppUiTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppUiTokens.space16,
          vertical: AppUiTokens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < totals.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: AppUiTokens.space12),
                const Divider(height: 1, color: AppUiTokens.border),
                const SizedBox(height: AppUiTokens.space12),
              ],
              _buildCurrencyBlock(textTheme, totals[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyBlock(
    TextTheme textTheme,
    PriceOfferCurrencyTotal total,
  ) {
    final currency = _mapOfferCurrency(total.currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(
          textTheme,
          label: 'Ara Toplam (${total.currency.label})',
          value: MoneyUtils.formatAmountMinor(total.grossMinor, currency),
        ),
        if (total.hasDiscount) ...[
          const SizedBox(height: AppUiTokens.space8),
          _row(
            textTheme,
            label: 'İndirim',
            value:
                '- ${MoneyUtils.formatAmountMinor(total.discountMinor, currency)}',
            valueColor: ColorName.error,
          ),
        ],
        const SizedBox(height: AppUiTokens.space8),
        _row(
          textTheme,
          label: 'Genel Toplam (${total.currency.label})',
          value: MoneyUtils.formatAmountMinor(total.netMinor, currency),
          emphasize: true,
        ),
      ],
    );
  }

  Widget _row(
    TextTheme textTheme, {
    required String label,
    required String value,
    bool emphasize = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppUiTokens.textSecondary,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor ??
                (emphasize ? AppUiTokens.textPrimary : AppUiTokens.textPrimary),
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
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
