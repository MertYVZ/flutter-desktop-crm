import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/feature/price_list/widgets/price_list_product_form_dialog.dart';
import 'package:Ok/feature/price_list/widgets/price_list_products_table.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/price_list_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class PriceListEditPage extends StatefulWidget {
  const PriceListEditPage({super.key});

  @override
  State<PriceListEditPage> createState() => _PriceListEditPageState();
}

class _PriceListEditPageState extends BaseState<PriceListEditPage> {
  String get _priceListId => Get.parameters['id'] ?? '';

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _effectiveDate;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeFromList(PriceListController controller) {
    if (_initialized) {
      return;
    }

    final list = controller.selectedPriceList.value;
    if (list == null) {
      return;
    }

    _titleController.text = list.title;
    _descriptionController.text = list.description ?? '';
    _effectiveDate = list.effectiveDate;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceListController>(
      viewModel: Get.find<PriceListController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..getPriceListById(_priceListId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedPriceList.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final list = controller.selectedPriceList.value;
          if (list == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? PriceListMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          if (list.status != PriceListStatus.active.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: AppUiTokens.textMuted,
                  ),
                  const SizedBox(height: AppUiTokens.space16),
                  Text(
                    PriceListMessages.notEditable,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppUiTokens.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppUiTokens.space16),
                  TextButton(
                    onPressed: () => Get.offNamed<void>(
                      AppRoutes.priceListDetail.pathForId(list.id),
                    ),
                    child: const Text('Detaya Dön'),
                  ),
                ],
              ),
            );
          }

          _initializeFromList(controller);

          return LayoutBuilder(
            builder: (context, constraints) {
              return PanelFormScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PanelFormPageHeader(
                      title: 'Fiyat Listesi Düzenle',
                      subtitle:
                          'Aktif fiyat listesi bilgilerini ve ürünleri düzenleyin.',
                      onBack: () =>
                          Get.offNamed<void>(AppRoutes.priceList.value),
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
                    PanelSurface(
                      padding: const EdgeInsets.all(AppUiTokens.space24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PanelTextField(
                            controller: _titleController,
                            label: 'Fiyat Listesi Adı',
                          ),
                          const SizedBox(height: AppUiTokens.space16),
                          AppDatePickerField(
                            label: 'Geçerlilik Tarihi',
                            placeholder: 'Tarih seçiniz',
                            selectedDate: _effectiveDate,
                            onDateSelected: (date) {
                              setState(() => _effectiveDate = date);
                            },
                          ),
                          const SizedBox(height: AppUiTokens.space16),
                          PanelTextField(
                            controller: _descriptionController,
                            label: 'Açıklama',
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppUiTokens.space24),
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: controller.isSaving.value
                                      ? null
                                      : () => Get.offNamed<void>(
                                            AppRoutes.priceList.value,
                                          ),
                                  style: AppInteractiveTheme.textButtonStyle(
                                    TextButton.styleFrom(
                                      foregroundColor:
                                          AppUiTokens.textSecondary,
                                    ),
                                  ),
                                  child: const Text('Vazgeç'),
                                ),
                                const SizedBox(width: AppUiTokens.space8),
                                FilledButton(
                                  onPressed: controller.isSaving.value
                                      ? null
                                      : () => _submit(controller),
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
                                      : const Text('Kaydet'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Row(
                      children: [
                        Text(
                          'Ürünler',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppUiTokens.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () => showPriceListProductFormDialog(
                            controller: controller,
                            priceListId: list.id,
                          ),
                          style: AppInteractiveTheme.filledButtonStyle(
                            FilledButton.styleFrom(
                              backgroundColor: ColorName.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Ürün Ekle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppUiTokens.space12),
                    PanelSurface(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                      child: PriceListProductsTable(
                        controller: controller,
                        items: controller.selectedItems.toList(),
                        readOnly: false,
                        availableWidth: constraints.maxWidth,
                        onEdit: (item) => showPriceListProductFormDialog(
                          controller: controller,
                          priceListId: list.id,
                          existingItem: item,
                        ),
                        onDelete: (item) async {
                          final deleted = await controller.deleteItem(item.id);
                          if (deleted) {
                            await controller.getPriceListById(list.id);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Future<void> _submit(PriceListController controller) async {
    final updated = await controller.updatePriceList(
      id: _priceListId,
      title: _titleController.text,
      effectiveDate: _effectiveDate == null
          ? null
          : AppDateUtils.normalizeDate(_effectiveDate!),
      description: _descriptionController.text,
    );

    if (updated) {
      Get.offNamed<void>(AppRoutes.priceList.value);
    }
  }
}
