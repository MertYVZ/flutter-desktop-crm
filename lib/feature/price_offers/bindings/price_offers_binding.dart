import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/services/legal_text_template_service.dart';
import 'package:Ok/feature/price_offers/services/offer_pdf_settings_service.dart';
import 'package:Ok/feature/price_offers/services/price_offer_pdf_service.dart';
import 'package:Ok/feature/price_offers/services/price_offers_export_service.dart';
import 'package:Ok/feature/price_offers/services/price_offers_service.dart';
import 'package:get/get.dart';

final class PriceOffersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PriceOffersService>()) {
      Get.put<PriceOffersService>(
        PriceOffersService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<PriceOffersExportService>()) {
      Get.put<PriceOffersExportService>(
        PriceOffersExportService(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<OfferPdfSettingsService>()) {
      Get.put<OfferPdfSettingsService>(
        OfferPdfSettingsService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<PriceOfferPdfService>()) {
      Get.put<PriceOfferPdfService>(
        PriceOfferPdfService(Get.find<OfferPdfSettingsService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LegalTextTemplateService>()) {
      Get.put<LegalTextTemplateService>(
        LegalTextTemplateService(Get.find()),
        permanent: true,
      );
    }

    Get.lazyPut<PriceOffersController>(
      () => PriceOffersController(
        Get.find<PriceOffersService>(),
        Get.find<PriceOffersExportService>(),
        Get.find<PriceOfferPdfService>(),
      ),
    );
  }
}
