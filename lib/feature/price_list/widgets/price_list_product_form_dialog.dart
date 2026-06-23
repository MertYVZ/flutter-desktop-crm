import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/models/price_list_currency.dart';
import 'package:Ok/feature/price_list/models/price_list_item_model.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/widgets/panel/panel_dropdown.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

Future<void> showPriceListProductFormDialog({
  required PriceListController controller,
  required String priceListId,
  PriceListItemModel? existingItem,
}) async {
  final productNameController =
      TextEditingController(text: existingItem?.productName ?? '');
  final minPriceController = TextEditingController(
    text: existingItem == null
        ? ''
        : MoneyUtils.formatAmountInputFromMinor(existingItem.minPriceMinor),
  );
  final maxPriceController = TextEditingController(
    text: existingItem == null
        ? ''
        : MoneyUtils.formatAmountInputFromMinor(existingItem.maxPriceMinor),
  );
  var selectedCurrency = existingItem?.currencyType ?? PriceListCurrency.try_;

  await Get.dialog<void>(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppUiTokens.surface,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            border: Border.all(color: AppUiTokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppUiTokens.space24),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existingItem == null ? 'Ürün Ekle' : 'Ürün Düzenle',
                      style: const TextStyle(
                        color: AppUiTokens.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    PanelTextField(
                      controller: productNameController,
                      label: 'Ürün Adı',
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    PanelDropdown<PriceListCurrency>(
                      label: 'Para Birimi',
                      hint: 'Para birimi seçiniz',
                      value: selectedCurrency,
                      items: PriceListCurrency.values,
                      itemLabel: (value) => value.label,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedCurrency = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    PanelTextField(
                      controller: minPriceController,
                      label: 'Min Fiyat',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    PanelTextField(
                      controller: maxPriceController,
                      label: 'Max Fiyat',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(() {
                      final error = controller.errorMessage.value;
                      if (error == null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppUiTokens.space16,
                        ),
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: ColorName.error,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () => Get.back<void>(),
                          style: AppInteractiveTheme.textButtonStyle(
                            TextButton.styleFrom(
                              foregroundColor: AppUiTokens.textSecondary,
                            ),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                        const SizedBox(width: AppUiTokens.space8),
                        Obx(
                          () => FilledButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () async {
                                    controller.clearMessages();
                                    final success = existingItem == null
                                        ? await controller.createItem(
                                            priceListId: priceListId,
                                            productName:
                                                productNameController.text,
                                            currency: selectedCurrency,
                                            minPriceText:
                                                minPriceController.text,
                                            maxPriceText:
                                                maxPriceController.text,
                                          )
                                        : await controller.updateItem(
                                            id: existingItem.id,
                                            productName:
                                                productNameController.text,
                                            currency: selectedCurrency,
                                            minPriceText:
                                                minPriceController.text,
                                            maxPriceText:
                                                maxPriceController.text,
                                          );

                                    if (success) {
                                      Get.back<void>();
                                    }
                                  },
                            style: AppInteractiveTheme.filledButtonStyle(
                              FilledButton.styleFrom(
                                backgroundColor: ColorName.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    existingItem == null ? 'Ekle' : 'Kaydet',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );

  productNameController.dispose();
  minPriceController.dispose();
  maxPriceController.dispose();
}
