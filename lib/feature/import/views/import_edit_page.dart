import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/widgets/export_items_editor.dart';
import 'package:Ok/feature/import/controllers/import_controller.dart';
import 'package:Ok/feature/import/widgets/import_record_form.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
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
  late final List<ExportItemFormRow> _itemRows;
  late final TextEditingController _logisticsNameController;
  late final TextEditingController _logisticsCostController;
  late final TextEditingController _customsCostController;
  late final TextEditingController _insuranceCostController;
  late final TextEditingController _notesController;
  PriceOfferCurrencyType _currency = PriceOfferCurrencyType.try_;
  DateTime? _shipmentDate;
  DateTime? _deliveryDate;
  bool _isFormInitialized = false;

  String get _recordId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _supplierNameController = TextEditingController();
    _itemRows = [ExportItemFormRow()];
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
    for (final row in _itemRows) {
      row.dispose();
    }
    _logisticsNameController.dispose();
    _logisticsCostController.dispose();
    _customsCostController.dispose();
    _insuranceCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _replaceItemRows(List<ExportItemData> items) {
    for (final row in _itemRows) {
      row.dispose();
    }
    _itemRows
      ..clear()
      ..addAll(
        items.isEmpty
            ? [ExportItemFormRow()]
            : items.map((item) {
                return ExportItemFormRow(id: item.id)..populateFromItem(item);
              }),
      );
  }

  void _setOptionalAmount(TextEditingController controller, int? amountMinor) {
    if (amountMinor == null) {
      return;
    }

    PanelAmountField.setAmountFromMinor(controller, amountMinor);
  }

  void _populateForm(ImportController controller) {
    final detail = controller.selectedImport.value;
    if (detail == null || _isFormInitialized) {
      return;
    }

    final record = detail.record;
    _titleController.text = record.title;
    _supplierNameController.text = record.supplierName;
    _currency = detail.currency;
    _logisticsNameController.text = record.logisticsName ?? '';
    _shipmentDate = record.shipmentDate;
    _deliveryDate = record.deliveryDate;
    _setOptionalAmount(_logisticsCostController, record.logisticsCostMinor);
    _setOptionalAmount(_customsCostController, record.customsCostMinor);
    _setOptionalAmount(_insuranceCostController, record.insuranceCostMinor);
    _notesController.text = record.notes ?? '';
    _replaceItemRows(detail.items);
    _isFormInitialized = true;
  }

  List<ExportItemData> get _items {
    final items = <ExportItemData>[];
    for (var index = 0; index < _itemRows.length; index++) {
      final item = _itemRows[index].toItemData(sortOrder: index);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
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

          final detail = controller.selectedImport.value;
          if (detail == null) {
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
                  subtitle: detail.record.title,
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
                        itemRows: _itemRows,
                        currency: _currency,
                        logisticsNameController: _logisticsNameController,
                        shipmentDate: _shipmentDate,
                        deliveryDate: _deliveryDate,
                        logisticsCostController: _logisticsCostController,
                        customsCostController: _customsCostController,
                        insuranceCostController: _insuranceCostController,
                        notesController: _notesController,
                        onCurrencyChanged: (value) => setState(() {
                          if (value != null) {
                            _currency = value;
                          }
                        }),
                        onItemsChanged: () => setState(() {}),
                        onShipmentDateChanged: (value) => setState(() {
                          _shipmentDate = value;
                        }),
                        onDeliveryDateChanged: (value) => setState(() {
                          _deliveryDate = value;
                        }),
                        onTotalsChanged: () => setState(() {}),
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
      currency: _currency,
      items: _items,
      itemInputs: _itemRows.map((row) => row.toValidationInput()).toList(),
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
