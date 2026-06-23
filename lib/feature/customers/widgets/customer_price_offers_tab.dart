import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_tab_table_shell.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_badges.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/customer_detail_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerPriceOffersTab extends StatelessWidget {
  const CustomerPriceOffersTab({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final offers = controller.priceOffers;
      final isLoading = controller.isLoadingTabData.value;

      return CustomerSectionContent(
        isLoading: isLoading,
        isEmpty: offers.isEmpty,
        emptyMessage: CustomerDetailMessages.priceOffersEmpty,
        emptyActionLabel: 'Fiyat Teklifi Oluştur',
        onEmptyAction: () => Get.toNamed<void>(AppRoutes.priceOffersNew.value),
        children: offers
            .map(
              (offer) => CustomerListRow(
                title: AppDateUtils.formatDate(offer.offerDate),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppUiTokens.space8,
                      runSpacing: AppUiTokens.space4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PriceOfferTypeBadge(
                          type: offer.offerType,
                          fallbackLabel: offer.type,
                          compact: true,
                        ),
                        PriceOfferStatusBadge(
                          status: offer.offerStatus,
                          fallbackLabel: offer.status,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppUiTokens.space4),
                    CustomerRowMeta(
                      items: [
                        offer.contactPerson,
                        offer.displayAuthorizedPhone,
                        offer.displayMobilePhone,
                      ],
                    ),
                  ],
                ),
                trailing: [
                  CustomerSectionActionButton(
                    tooltip: 'Detay',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.priceOffersDetail.pathForId(offer.id),
                    ),
                  ),
                  CustomerSectionActionButton(
                    tooltip: 'Düzenle',
                    icon: Icons.edit_outlined,
                    onPressed: () => Get.toNamed<void>(
                      AppRoutes.priceOffersEdit.pathForId(offer.id),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      );
    });
  }
}
