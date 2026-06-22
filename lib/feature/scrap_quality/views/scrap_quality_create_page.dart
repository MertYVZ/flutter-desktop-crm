import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_quality_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ScrapQualityCreatePage extends StatefulWidget {
  const ScrapQualityCreatePage({super.key});

  @override
  State<ScrapQualityCreatePage> createState() => _ScrapQualityCreatePageState();
}

class _ScrapQualityCreatePageState extends BaseState<ScrapQualityCreatePage> {
  late final TextEditingController _qualityController;
  late final TextEditingController _quantityController;
  late final TextEditingController _customUnitController;
  late final TextEditingController _noteController;
  String? _selectedCustomerId;
  ScrapQualityUnit? _selectedUnit = ScrapQualityUnit.defaultUnit;

  @override
  void initState() {
    super.initState();
    _qualityController = TextEditingController();
    _quantityController = TextEditingController();
    _customUnitController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _qualityController.dispose();
    _quantityController.dispose();
    _customUnitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ScrapQualityController>(
      viewModel: Get.find<ScrapQualityController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadCustomersForDropdown();
      },
      onPageBuilder: (context, controller) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PageHeader(
                title: 'Yeni Hurda Kalite Kaydı',
                subtitle: 'Yeni hurda kalite kaydı oluşturun.',
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
                    Obx(
                      () => ScrapQualityForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        qualityController: _qualityController,
                        quantityController: _quantityController,
                        selectedUnit: _selectedUnit,
                        customUnitController: _customUnitController,
                        recordDate: DateTime.now(),
                        noteController: _noteController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onUnitChanged: (value) => setState(() {
                          _selectedUnit = value;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => ScrapQualityFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () => Get.offNamed<void>(
                                  AppRoutes.scrapQuality.value,
                                ),
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

  Future<void> _submit(ScrapQualityController controller) async {
    final id = await controller.createRecord(
      customerId: _selectedCustomerId,
      quality: _qualityController.text,
      quantityText: _quantityController.text,
      unit: _selectedUnit,
      customUnitText: _customUnitController.text,
      note: _noteController.text,
    );

    if (id != null) {
      Get.offNamed<void>(AppRoutes.scrapQuality.value);
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
