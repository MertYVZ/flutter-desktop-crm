import 'package:Ok/feature/price_offers/services/legal_text_template_service.dart';
import 'package:Ok/feature/price_offers/services/offer_pdf_settings_service.dart';
import 'package:Ok/feature/settings/controller/settings_controller.dart';
import 'package:get/get.dart';

final class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OfferPdfSettingsService>()) {
      Get.put<OfferPdfSettingsService>(
        OfferPdfSettingsService(Get.find()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LegalTextTemplateService>()) {
      Get.put<LegalTextTemplateService>(
        LegalTextTemplateService(Get.find()),
        permanent: true,
      );
    }

    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find(),
        Get.find(),
        Get.find<OfferPdfSettingsService>(),
        Get.find<LegalTextTemplateService>(),
      ),
    );
  }
}
