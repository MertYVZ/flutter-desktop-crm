import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/widgets/export_items_editor.dart';
import 'package:Ok/feature/import/controllers/import_controller.dart';
import 'package:Ok/feature/import/widgets/import_record_form.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ImportCreatePage extends StatefulWidget {
  const ImportCreatePage({super.key});

  @override
  State<ImportCreatePage> createState() => _ImportCreatePageState();
}

class _ImportCreatePageState extends BaseState<ImportCreatePage> {
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
        controller.clearMessages();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelFormPageHeader(
                title: 'Yeni İthalat',
                subtitle: 'Yeni ithalat kaydı oluşturun.',
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
                            : () => Get.offNamed<void>(AppRoutes.imports.value),
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

  Future<void> _submit(ImportController controller) async {
    final id = await controller.createImport(
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

    if (id != null) {
      await Get.offNamed<void>(AppRoutes.imports.value);
    }
  }
}
