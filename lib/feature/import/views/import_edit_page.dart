import 'package:Ok/feature/export/models/export_product_names.dart';
import 'package:Ok/feature/import/controllers/import_controller.dart';
import 'package:Ok/feature/import/widgets/import_record_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/import_messages.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ImportEditPage extends StatefulWidget {
  const ImportEditPage({super.key});

  @override
  State<ImportEditPage> createState() => _ImportEditPageState();
}

class _ImportEditPageState extends BaseState<ImportEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _supplierNameController;
  late final List<TextEditingController> _productControllers;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _logisticsNameController;
  late final TextEditingController _logisticsCostController;
  late final TextEditingController _customsCostController;
  late final TextEditingController _insuranceCostController;
  late final TextEditingController _notesController;
  DateTime? _shipmentDate;
  DateTime? _deliveryDate;
  bool _isFormInitialized = false;

  String get _recordId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _supplierNameController = TextEditingController();
    _productControllers = [TextEditingController()];
    _totalAmountController = TextEditingController();
    _logisticsNameController = TextEditingController();
    _logisticsCostController = TextEditingController();
    _customsCostController = TextEditingController();
    _insuranceCostController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _supplierNameController.dispose();
    for (final controller in _productControllers) {
      controller.dispose();
    }
    _totalAmountController.dispose();
    _logisticsNameController.dispose();
    _logisticsCostController.dispose();
    _customsCostController.dispose();
    _insuranceCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addProduct() {
    setState(() {
      _productControllers.add(TextEditingController());
    });
  }

  void _removeProduct(int index) {
    if (_productControllers.length <= 1) {
      return;
    }

    setState(() {
      _productControllers.removeAt(index).dispose();
    });
  }

  void _replaceProductControllers(List<String> names) {
    for (final controller in _productControllers) {
      controller.dispose();
    }
    _productControllers
      ..clear()
      ..addAll(names.map((name) => TextEditingController(text: name)));
  }

  void _setOptionalAmount(TextEditingController controller, int? amountMinor) {
    if (amountMinor == null) {
      return;
    }

    PanelAmountField.setAmountFromMinor(controller, amountMinor);
  }

  void _populateForm(ImportController controller) {
    final record = controller.selectedImport.value;
    if (record == null || _isFormInitialized) {
      return;
    }

    _titleController.text = record.title;
    _supplierNameController.text = record.supplierName;
    final productNames = ExportProductNames.parse(record.products);
    _replaceProductControllers(
      productNames.isEmpty ? [''] : productNames,
    );
    PanelAmountField.setAmountFromMinor(
      _totalAmountController,
      record.totalAmountMinor,
    );
    _logisticsNameController.text = record.logisticsName ?? '';
    _shipmentDate = record.shipmentDate;
    _deliveryDate = record.deliveryDate;
    _setOptionalAmount(_logisticsCostController, record.logisticsCostMinor);
    _setOptionalAmount(_customsCostController, record.customsCostMinor);
    _setOptionalAmount(_insuranceCostController, record.insuranceCostMinor);
    _notesController.text = record.notes ?? '';
    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ImportController>(
      viewModel: Get.find<ImportController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.getImportById(_recordId).then((loaded) {
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
              (controller.selectedImport.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final record = controller.selectedImport.value;
          if (record == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ImportMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PanelFormPageHeader(
                  title: 'İthalat Düzenle',
                  subtitle: record.title,
                  onBack: () => Get.offNamed<void>(AppRoutes.imports.value),
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
                      ImportRecordForm(
                        titleController: _titleController,
                        supplierNameController: _supplierNameController,
                        productControllers: _productControllers,
                        onAddProduct: _addProduct,
                        onRemoveProduct: _removeProduct,
                        totalAmountController: _totalAmountController,
                        logisticsNameController: _logisticsNameController,
                        shipmentDate: _shipmentDate,
                        deliveryDate: _deliveryDate,
                        logisticsCostController: _logisticsCostController,
                        customsCostController: _customsCostController,
                        insuranceCostController: _insuranceCostController,
                        notesController: _notesController,
                        onShipmentDateChanged: (value) => setState(() {
                          _shipmentDate = value;
                        }),
                        onDeliveryDateChanged: (value) => setState(() {
                          _deliveryDate = value;
                        }),
                      ),
                      const SizedBox(height: AppUiTokens.space24),
                      Obx(
                        () => ImportRecordFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onCancel: controller.isSaving.value
                              ? () {}
                              : () => Get.offNamed<void>(
                                    AppRoutes.imports.value,
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

  Future<void> _submit(ImportController controller) async {
    final success = await controller.updateImport(
      id: _recordId,
      title: _titleController.text,
      supplierName: _supplierNameController.text,
      products: ExportProductNames.join(
        _productControllers.map((controller) => controller.text),
      ),
      totalAmountText: _totalAmountController.text,
      shipmentDate: _shipmentDate,
      deliveryDate: _deliveryDate,
      logisticsName: _logisticsNameController.text,
      logisticsCostText: _logisticsCostController.text,
      customsCostText: _customsCostController.text,
      insuranceCostText: _insuranceCostController.text,
      notes: _notesController.text,
    );

    if (success) {
      await Get.offNamed<void>(AppRoutes.imports.value);
    }
  }
}
