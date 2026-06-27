import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_badges.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/price_offer_messages.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class PriceOffersTable extends StatelessWidget {
  const PriceOffersTable({
    required this.controller,
    this.availableWidth,
    super.key,
  });

  final PriceOffersController controller;
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
        final records = controller.offers;
        final isLoading = controller.isLoading.value;
        final isDeleting = controller.isDeleting.value;
        final deletingId = controller.deletingOfferId.value;

        if (isLoading && records.isEmpty) {
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

        if (records.isEmpty) {
          final message = controller.hasActiveFilters
              ? PriceOfferMessages.listFilteredEmpty
              : PriceOfferMessages.listEmpty;

          return AppTableEmptyState(
            message: message,
            icon: controller.hasActiveFilters
                ? Icons.search_off_outlined
                : Icons.request_quote_outlined,
          );
        }

        final table = DataTable(
          headingRowHeight: _headerRowHeight,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 52,
          headingTextStyle: _headingStyle,
          dataTextStyle: _dataStyle,
          headingRowColor: WidgetStateProperty.all(Colors.transparent),
          dividerThickness: 1,
          columnSpacing: AppUiTokens.space24,
          horizontalMargin: AppUiTokens.space24,
          columns: const [
            DataColumn(label: Text('Teklif Tarihi')),
            DataColumn(label: Text('Geçerlilik Tarihi')),
            DataColumn(label: Text('Tip')),
            DataColumn(label: Text('Müşteri')),
            DataColumn(label: Text('İlgili Kişi')),
            DataColumn(label: Text('Yetkili Telefon')),
            DataColumn(label: Text('Yetkili Telefonu')),
            DataColumn(label: Text('Durum')),
            DataColumn(label: Text('İşlemler')),
          ],
          rows: records
              .map(
                (offer) => _buildRow(
                  offer,
                  isDeleting: isDeleting && deletingId == offer.id,
                ),
              )
              .toList(),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final minTableWidth = availableWidth ?? constraints.maxWidth;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _headerRowHeight,
                  child: ColoredBox(color: AppUiTokens.surfaceMuted),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minTableWidth),
                    child: table,
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppUiTokens.surface.withValues(alpha: 0.72),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }

  DataRow _buildRow(
    PriceOfferListItem offer, {
    required bool isDeleting,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            AppDateUtils.formatDate(offer.offerDate),
            style: _dataStyle,
          ),
        ),
        DataCell(
          Text(
            AppDateUtils.formatDate(offer.validityDate),
            style: _dataStyle,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: PriceOfferTypeBadge(
              type: offer.offerType,
              fallbackLabel: offer.type,
              compact: true,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              offer.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _dataStyle,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              offer.contactPerson,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _dataStyle,
            ),
          ),
        ),
        DataCell(
          Text(
            offer.displayAuthorizedPhone,
            style: _dataStyle,
          ),
        ),
        DataCell(
          Text(
            offer.displayMobilePhone,
            style: _dataStyle,
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: PriceOfferStatusBadge(
              status: offer.offerStatus,
              fallbackLabel: offer.status,
              compact: true,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                tooltip: 'Detay',
                icon: Icons.visibility_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.priceOffersDetail.pathForId(offer.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Düzenle',
                icon: Icons.edit_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.priceOffersEdit.pathForId(offer.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Sil',
                icon: Icons.delete_outline_rounded,
                color: ColorName.error,
                isLoading: isDeleting,
                onPressed: isDeleting
                    ? null
                    : () async {
                        final deleted =
                            await controller.deleteOffer(offer.id);
                        if (deleted) {
                          await controller.searchAndFilterOffers();
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      mouseCursor:
          onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color ?? AppUiTokens.textSecondary,
              ),
            )
          : Icon(icon, size: 18, color: color ?? AppUiTokens.textSecondary),
      style: AppInteractiveTheme.iconButtonStyle(
        IconButton.styleFrom(
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
