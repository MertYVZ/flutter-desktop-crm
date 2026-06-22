import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_unit.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_quality_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ScrapQualityEditPage extends StatefulWidget {
  const ScrapQualityEditPage({super.key});

  @override
  State<ScrapQualityEditPage> createState() => _ScrapQualityEditPageState();
}

class _ScrapQualityEditPageState extends BaseState<ScrapQualityEditPage> {
  late final TextEditingController _qualityController;
  late final TextEditingController _quantityController;
  late final TextEditingController _customUnitController;
  late final TextEditingController _noteController;
  String? _selectedCustomerId;
  ScrapQualityUnit? _selectedUnit;
  DateTime? _selectedRecordDate;
  bool _isFormInitialized = false;

  String get _recordId => Get.parameters['id'] ?? '';

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

  void _populateForm(ScrapQualityController controller) {
    final record = controller.selectedRecord.value;
    if (record == null || _isFormInitialized) {
      return;
    }

    _selectedCustomerId = record.customerId;
    _qualityController.text = record.quality;
    _quantityController.text =
        QuantityUtils.formatQuantityInput(record.quantity);
    _selectedRecordDate = record.recordDate;
    _noteController.text = record.note ?? '';

    final predefinedUnit = ScrapQualityUnit.fromLabel(record.unit);
    if (predefinedUnit != null) {
      _selectedUnit = predefinedUnit;
      _customUnitController.clear();
    } else {
      _selectedUnit = ScrapQualityUnit.other;
      _customUnitController.text = record.unit;
    }

    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ScrapQualityController>(
      viewModel: Get.find<ScrapQualityController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.loadCustomersForDropdown();
        controller.getRecordById(_recordId).then((loaded) {
          if (!loaded || !mounted) {
            return;
          }

          setState(() {
            _populateForm(controller);
          });
        });
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value ||
              (controller.selectedRecord.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final record = controller.selectedRecord.value;
          if (record == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ScrapQualityMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PageHeader(
                  title: 'Hurda Kalite Kaydı Düzenle',
                  subtitle: record.quality,
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
                      ScrapQualityForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        qualityController: _qualityController,
                        quantityController: _quantityController,
                        selectedUnit: _selectedUnit,
                        customUnitController: _customUnitController,
                        recordDate: _selectedRecordDate,
                        noteController: _noteController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onUnitChanged: (value) => setState(() {
                          _selectedUnit = value;
                        }),
                      ),
                      const SizedBox(height: AppUiTokens.space24),
                      Obx(
                        () => ScrapQualityFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
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
        });
      },
    );
  }

  Future<void> _submit(ScrapQualityController controller) async {
    final success = await controller.updateRecord(
      id: _recordId,
      customerId: _selectedCustomerId,
      quality: _qualityController.text,
      quantityText: _quantityController.text,
      unit: _selectedUnit,
      customUnitText: _customUnitController.text,
      recordDate: _selectedRecordDate,
      note: _noteController.text,
    );

    if (success) {
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
