import 'package:Ok/feature/due_tracking/models/currency_type.dart'
    as due_currency;
import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_badges.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/price_offer_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _infoCompactBreakpoint = 800.0;
const _infoTwoColumnBreakpoint = 520.0;

typedef _InfoFieldData = ({String label, String? value, Widget? child});

final class PriceOfferDetailPage extends StatefulWidget {
  const PriceOfferDetailPage({super.key});

  @override
  State<PriceOfferDetailPage> createState() => _PriceOfferDetailPageState();
}

class _PriceOfferDetailPageState extends BaseState<PriceOfferDetailPage> {
  String get _offerId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceOffersController>(
      viewModel: Get.find<PriceOffersController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..getOfferById(_offerId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedOffer.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final offer = controller.selectedOffer.value;
          if (offer == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? PriceOfferMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageHeader(
                  title: offer.customerName,
                  subtitle: 'Fiyat teklifi detayları',
                  onBack: () =>
                      Get.offNamed<void>(AppRoutes.priceOffers.value),
                  onEdit: () => Get.toNamed<void>(
                    AppRoutes.priceOffersEdit.pathForId(offer.id),
                  ),
                  onGeneratePdf: controller.isGeneratingPdf.value
                      ? null
                      : () => controller.generateOfferPdf(offer.id),
                  isGeneratingPdf: controller.isGeneratingPdf.value,
                  onDelete: controller.isDeleting.value
                      ? null
                      : () async {
                          final deleted =
                              await controller.deleteOffer(offer.id);
                          if (deleted) {
                            await Get.offNamed<void>(
                              AppRoutes.priceOffers.value,
                            );
                          }
                        },
                  isDeleting: controller.isDeleting.value,
                ),
                const SizedBox(height: AppUiTokens.space16),
                Obx(() {
                  final error = controller.errorMessage.value;
                  final success = controller.successMessage.value;

                  if (error == null && success == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (success != null)
                        PanelMessage(
                          message: success,
                          type: PanelMessageType.info,
                        ),
                      if (error != null && success != null)
                        const SizedBox(height: AppUiTokens.space12),
                      if (error != null) PanelMessage(message: error),
                      const SizedBox(height: AppUiTokens.space16),
                    ],
                  );
                }),
                _OfferInfoCard(
                  offerDate: AppDateUtils.formatDate(offer.offerDate),
                  validityDate: AppDateUtils.formatDate(offer.validityDate),
                  offerType: offer.offerType,
                  typeFallback: offer.type,
                  customerName: offer.customerName,
                  contactPerson: offer.contactPerson,
                  authorizedPhone: offer.displayAuthorizedPhone,
                  mobilePhone: offer.displayMobilePhone,
                  offerStatus: offer.offerStatus,
                  statusFallback: offer.status,
                  createdAt: dateFormat.format(offer.createdAt),
                  updatedAt: dateFormat.format(offer.updatedAt),
                ),
                const SizedBox(height: AppUiTokens.space16),
                _ItemsCard(items: offer.items),
                const SizedBox(height: AppUiTokens.space16),
                _LegalTextCard(legalText: offer.legalText),
              ],
            ),
          );
        });
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onEdit,
    required this.onGeneratePdf,
    required this.onDelete,
    required this.isDeleting,
    required this.isGeneratingPdf,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback? onGeneratePdf;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final bool isGeneratingPdf;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppUiTokens.space8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
          ],
        );

        final actions = Wrap(
          spacing: AppUiTokens.space8,
          runSpacing: AppUiTokens.space8,
          children: [
            _HeaderButton(
              label: 'Geri Dön',
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
            _HeaderButton(
              label: 'Düzenle',
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
            _HeaderButton(
              label: 'PDF Oluştur',
              icon: Icons.picture_as_pdf_outlined,
              isLoading: isGeneratingPdf,
              onPressed: onGeneratePdf,
            ),
            _HeaderButton(
              label: 'Sil',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              isLoading: isDeleting,
              onPressed: onDelete,
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              const SizedBox(height: AppUiTokens.space16),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            actions,
          ],
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isDestructive ? ColorName.error : AppUiTokens.textPrimary;
    final borderColor =
        isDestructive ? const Color(0xFFFECACA) : AppUiTokens.border;
    final backgroundColor =
        isDestructive ? const Color(0xFFFEF2F2) : AppUiTokens.surface;

    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: AppInteractiveTheme.outlinedButtonStyle(
          OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            side: BorderSide(color: borderColor),
            padding:
                const EdgeInsets.symmetric(horizontal: AppUiTokens.space16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            ),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

class _OfferInfoCard extends StatelessWidget {
  const _OfferInfoCard({
    required this.offerDate,
    required this.validityDate,
    required this.offerType,
    required this.typeFallback,
    required this.customerName,
    required this.contactPerson,
    required this.authorizedPhone,
    required this.mobilePhone,
    required this.offerStatus,
    required this.statusFallback,
    required this.createdAt,
    required this.updatedAt,
  });

  final String offerDate;
  final String validityDate;
  final OfferType? offerType;
  final String typeFallback;
  final String customerName;
  final String contactPerson;
  final String authorizedPhone;
  final String mobilePhone;
  final PriceOfferStatus? offerStatus;
  final String statusFallback;
  final String createdAt;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final isCompact = maxWidth < _infoCompactBreakpoint;

          final quoteInfoFields = <_InfoFieldData>[
            (label: 'Teklif Tarihi', value: offerDate, child: null),
            (label: 'Geçerlilik Tarihi', value: validityDate, child: null),
            (
              label: 'Tip',
              value: null,
              child: PriceOfferTypeBadge(
                type: offerType,
                fallbackLabel: typeFallback,
              ),
            ),
            (label: 'Müşteri', value: customerName, child: null),
            (label: 'İlgili Kişi', value: contactPerson, child: null),
            (label: 'Yetkili Telefon', value: authorizedPhone, child: null),
            (label: 'Yetkili Telefonu', value: mobilePhone, child: null),
            (
              label: 'Durum',
              value: null,
              child: PriceOfferStatusBadge(
                status: offerStatus,
                fallbackLabel: statusFallback,
              ),
            ),
          ];

          final recordInfoLeft = [
            _InfoField(label: 'Oluşturulma tarihi', value: createdAt),
          ];

          final recordInfoRight = [
            _InfoField(
              label: 'Güncellenme tarihi',
              value: updatedAt,
              isLast: true,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(
                title: 'Teklif Bilgileri',
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: AppUiTokens.space24),
              _ResponsiveInfoGrid(
                maxWidth: maxWidth,
                fields: quoteInfoFields,
              ),
              const SizedBox(height: AppUiTokens.space24),
              const _SectionTitle(
                title: 'Kayıt Bilgileri',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: AppUiTokens.space16),
              _ResponsiveInfoColumns(
                isCompact: isCompact,
                left: recordInfoLeft,
                right: recordInfoRight,
              ),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> _buildInfoFieldList(List<_InfoFieldData> fields) {
  return [
    for (var i = 0; i < fields.length; i++)
      _InfoField(
        label: fields[i].label,
        value: fields[i].value,
        isLast: i == fields.length - 1,
        child: fields[i].child,
      ),
  ];
}

class _ResponsiveInfoGrid extends StatelessWidget {
  const _ResponsiveInfoGrid({
    required this.maxWidth,
    required this.fields,
  });

  final double maxWidth;
  final List<_InfoFieldData> fields;

  @override
  Widget build(BuildContext context) {
    if (maxWidth < _infoTwoColumnBreakpoint) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildInfoFieldList(fields),
      );
    }

    final splitIndex = (fields.length / 2).ceil();
    final leftFields = fields.sublist(0, splitIndex);
    final rightFields = fields.sublist(splitIndex);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildInfoFieldList(leftFields),
          ),
        ),
        const SizedBox(width: AppUiTokens.space32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildInfoFieldList(rightFields),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveInfoColumns extends StatelessWidget {
  const _ResponsiveInfoColumns({
    required this.isCompact,
    required this.left,
    required this.right,
  });

  final bool isCompact;
  final List<Widget> left;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [...left, ...right],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: left,
          ),
        ),
        const SizedBox(width: AppUiTokens.space24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: right,
          ),
        ),
      ],
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<PriceOfferItemData> items;

  @override
  Widget build(BuildContext context) {
    final currencyTotals = _computeCurrencyTotals(items);

    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Ürün Detayları',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: AppUiTokens.space16),
          LayoutBuilder(
            builder: (context, constraints) {
              final table = DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                headingTextStyle: const TextStyle(
                  color: AppUiTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dataTextStyle: const TextStyle(
                  color: AppUiTokens.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                headingRowColor:
                    WidgetStateProperty.all(Colors.transparent),
                dividerThickness: 1,
                columnSpacing: AppUiTokens.space24,
                horizontalMargin: AppUiTokens.space24,
                columns: const [
                  DataColumn(label: Text('Ürün Adı')),
                  DataColumn(label: Text('Birim Tipi')),
                  DataColumn(label: Text('Miktar')),
                  DataColumn(label: Text('Fiyat')),
                  DataColumn(label: Text('Para Birimi')),
                  DataColumn(
                    label: Text('Satır Toplamı'),
                    numeric: true,
                  ),
                ],
                rows: items.map(_buildRow).toList(),
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: table,
                ),
              );
            },
          ),
          if (currencyTotals.isNotEmpty) ...[
            const SizedBox(height: AppUiTokens.space16),
            const Divider(height: 1, color: AppUiTokens.border),
            const SizedBox(height: AppUiTokens.space16),
            _CurrencyTotalsSummary(totals: currencyTotals),
          ],
        ],
      ),
    );
  }

  DataRow _buildRow(PriceOfferItemData item) {
    final currency = _mapOfferCurrency(item.currencyType);
    final priceLabel = MoneyUtils.formatAmountMinor(item.priceMinor, currency);
    final rowTotalLabel = MoneyUtils.formatAmountMinor(
      item.rowTotalMinor.round(),
      currency,
    );

    return DataRow(
      cells: [
        DataCell(Text(item.productName)),
        DataCell(Text(item.unitType)),
        DataCell(Text(QuantityUtils.formatQuantity(item.quantity))),
        DataCell(Text(priceLabel)),
        DataCell(Text(item.currencyType?.label ?? item.currency)),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              rowTotalLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

Map<PriceOfferCurrencyType, int> _computeCurrencyTotals(
  List<PriceOfferItemData> items,
) {
  final totals = <PriceOfferCurrencyType, double>{};

  for (final item in items) {
    final currency =
        item.currencyType ?? PriceOfferCurrencyTypeX.fromValue(item.currency);
    if (currency == null) {
      continue;
    }

    totals[currency] = (totals[currency] ?? 0) + item.rowTotalMinor;
  }

  return {
    for (final entry in totals.entries) entry.key: entry.value.round(),
  };
}

class _CurrencyTotalsSummary extends StatelessWidget {
  const _CurrencyTotalsSummary({required this.totals});

  final Map<PriceOfferCurrencyType, int> totals;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final entries = [
      for (final currency in PriceOfferCurrencyType.values)
        if (totals.containsKey(currency))
          (currency: currency, totalMinor: totals[currency]!),
    ];

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
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) const SizedBox(height: AppUiTokens.space8),
              Row(
                children: [
                  Text(
                    'Toplam (${entries[i].currency.label}):',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppUiTokens.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    MoneyUtils.formatAmountMinor(
                      entries[i].totalMinor,
                      _mapOfferCurrency(entries[i].currency),
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppUiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

due_currency.CurrencyType _mapOfferCurrency(PriceOfferCurrencyType? currency) {
  switch (currency) {
    case PriceOfferCurrencyType.try_:
      return due_currency.CurrencyType.try_;
    case PriceOfferCurrencyType.usd:
      return due_currency.CurrencyType.usd;
    case PriceOfferCurrencyType.eur:
      return due_currency.CurrencyType.eur;
    case null:
      return due_currency.CurrencyType.try_;
  }
}

class _LegalTextCard extends StatelessWidget {
  const _LegalTextCard({required this.legalText});

  final String legalText;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Teklif Bilgilendirme Metni',
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: AppUiTokens.space16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              border: Border.all(color: AppUiTokens.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppUiTokens.space16),
              child: SelectableText(
                legalText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppUiTokens.textSecondary,
                      height: 1.6,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppUiTokens.textSecondary),
        const SizedBox(width: AppUiTokens.space8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    this.value,
    this.child,
    this.isLast = false,
  }) : assert(value != null || child != null);

  final String label;
  final String? value;
  final Widget? child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: AppUiTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppUiTokens.space8),
          if (child != null)
            Row(
              children: [
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: child,
                  ),
                ),
              ],
            )
          else
            Text(
              value!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

