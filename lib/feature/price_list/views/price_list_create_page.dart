import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:Ok/product/widgets/panel/panel_text_field.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class PriceListCreatePage extends StatefulWidget {
  const PriceListCreatePage({super.key});

  @override
  State<PriceListCreatePage> createState() => _PriceListCreatePageState();
}

class _PriceListCreatePageState extends BaseState<PriceListCreatePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _effectiveDate = DateTime.now();
  bool _copyFromActive = false;

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

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceListController>(
      viewModel: Get.find<PriceListController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadActiveSection();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PageHeader(
                title: 'Yeni Fiyat Listesi',
                subtitle: 'Yeni aktif fiyat listesi oluşturun.',
              ),
              const SizedBox(height: AppUiTokens.space16),
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    PanelMessage(message: error),
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
                    const SizedBox(height: AppUiTokens.space16),
                    Obx(() {
                      final hasActive =
                          controller.activePriceList.value != null;
                      if (!hasActive) {
                        return const SizedBox.shrink();
                      }

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _copyFromActive,
                        onChanged: (value) {
                          setState(() => _copyFromActive = value ?? false);
                        },
                        title: const Text(
                          'Aktif listeyi kopyala',
                          style: TextStyle(
                            color: AppUiTokens.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Mevcut aktif listedeki ürünler yeni listeye kopyalanır.',
                          style: TextStyle(
                            color: AppUiTokens.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
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
                                foregroundColor: AppUiTokens.textSecondary,
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
                                : const Text('Oluştur'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit(PriceListController controller) async {
    final id = await controller.createPriceList(
      title: _titleController.text,
      effectiveDate: _effectiveDate == null
          ? null
          : AppDateUtils.normalizeDate(_effectiveDate!),
      description: _descriptionController.text,
      copyFromActive: _copyFromActive,
    );

    if (id != null) {
      Get.offNamed<void>(AppRoutes.priceList.value);
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
  }
}
