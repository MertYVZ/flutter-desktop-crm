import 'package:Ok/feature/export/controllers/export_controller.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/widgets/export_items_editor.dart';
import 'package:Ok/feature/export/widgets/export_record_form.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/export_messages.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ExportEditPage extends StatefulWidget {
  const ExportEditPage({super.key});

  @override
  State<ExportEditPage> createState() => _ExportEditPageState();
}

class _ExportEditPageState extends BaseState<ExportEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _guestCustomerNameController;
  late final List<ExportItemFormRow> _itemRows;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _bankController;
  late final TextEditingController _firstPaymentAmountController;
  late final TextEditingController _lastPaymentAmountController;
  late final TextEditingController _logisticsNameController;
  late final TextEditingController _logisticsCostController;
  late final TextEditingController _customsCostController;
  late final TextEditingController _insuranceCostController;
  late final TextEditingController _notesController;
  String? _selectedCustomerId;
  PriceOfferCurrencyType _currency = PriceOfferCurrencyType.try_;
  DateTime? _firstPaymentDate;
  DateTime? _lastPaymentDate;
  DateTime? _shipmentDate;
  DateTime? _deliveryDate;
  bool _isFormInitialized = false;

  String get _recordId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _guestCustomerNameController = TextEditingController();
    _itemRows = [ExportItemFormRow()];
    _paymentMethodController = TextEditingController();
    _bankController = TextEditingController();
    _firstPaymentAmountController = TextEditingController();
    _lastPaymentAmountController = TextEditingController();
    _logisticsNameController = TextEditingController();
    _logisticsCostController = TextEditingController();
    _customsCostController = TextEditingController();
    _insuranceCostController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _guestCustomerNameController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    _paymentMethodController.dispose();
    _bankController.dispose();
    _firstPaymentAmountController.dispose();
    _lastPaymentAmountController.dispose();
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

  void _populateForm(ExportController controller) {
    final detail = controller.selectedExport.value;
    if (detail == null || _isFormInitialized) {
      return;
    }

    final record = detail.record;
    _titleController.text = record.title;
    if (record.customerId.trim().isEmpty) {
      _selectedCustomerId = null;
      _guestCustomerNameController.text = record.customerNameSnapshot ?? '';
    } else {
      _selectedCustomerId = record.customerId;
      _guestCustomerNameController.text = record.customerNameSnapshot ?? '';
    }
    _currency = detail.currency;
    _paymentMethodController.text = record.paymentMethod ?? '';
    _bankController.text = record.bank ?? '';
    _firstPaymentDate = record.firstPaymentDate;
    _setOptionalAmount(
      _firstPaymentAmountController,
      record.firstPaymentAmountMinor,
    );
    _lastPaymentDate = record.lastPaymentDate;
    _setOptionalAmount(
      _lastPaymentAmountController,
      record.lastPaymentAmountMinor,
    );
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
    return BaseView<ExportController>(
      viewModel: Get.find<ExportController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller
          ..clearMessages()
          ..loadCustomersForDropdown();
        controller.getExportById(_recordId).then((loaded) {
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
              (controller.selectedExport.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final detail = controller.selectedExport.value;
          if (detail == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ExportMessages.notFound,
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
                  title: 'İhracat Düzenle',
                  subtitle: detail.record.title,
                  onBack: () => Get.offNamed<void>(AppRoutes.exports.value),
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
                      ExportRecordForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        guestCustomerNameController:
                            _guestCustomerNameController,
                        itemRows: _itemRows,
                        currency: _currency,
                        titleController: _titleController,
                        paymentMethodController: _paymentMethodController,
                        bankController: _bankController,
                        firstPaymentDate: _firstPaymentDate,
                        firstPaymentAmountController:
                            _firstPaymentAmountController,
                        lastPaymentDate: _lastPaymentDate,
                        lastPaymentAmountController:
                            _lastPaymentAmountController,
                        logisticsNameController: _logisticsNameController,
                        shipmentDate: _shipmentDate,
                        deliveryDate: _deliveryDate,
                        logisticsCostController: _logisticsCostController,
                        customsCostController: _customsCostController,
                        insuranceCostController: _insuranceCostController,
                        notesController: _notesController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onGuestCustomerNameChanged: (value) => setState(() {
                          _guestCustomerNameController.text = value;
                        }),
                        onCurrencyChanged: (value) => setState(() {
                          if (value != null) {
                            _currency = value;
                          }
                        }),
                        onItemsChanged: () => setState(() {}),
                        onFirstPaymentDateChanged: (value) => setState(() {
                          _firstPaymentDate = value;
                        }),
                        onLastPaymentDateChanged: (value) => setState(() {
                          _lastPaymentDate = value;
                        }),
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
                        () => ExportRecordFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onCancel: controller.isSaving.value
                              ? () {}
                              : () => Get.offNamed<void>(
                                    AppRoutes.exports.value,
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

  Future<void> _submit(ExportController controller) async {
    final success = await controller.updateExport(
      id: _recordId,
      title: _titleController.text,
      customerId: _selectedCustomerId,
      guestCustomerName: _guestCustomerNameController.text,
      currency: _currency,
      items: _items,
      itemInputs: _itemRows.map((row) => row.toValidationInput()).toList(),
      paymentMethod: _paymentMethodController.text,
      bank: _bankController.text,
      firstPaymentDate: _firstPaymentDate,
      firstPaymentAmountText: _firstPaymentAmountController.text,
      lastPaymentDate: _lastPaymentDate,
      lastPaymentAmountText: _lastPaymentAmountController.text,
      logisticsName: _logisticsNameController.text,
      shipmentDate: _shipmentDate,
      deliveryDate: _deliveryDate,
      logisticsCostText: _logisticsCostController.text,
      customsCostText: _customsCostController.text,
      insuranceCostText: _insuranceCostController.text,
      notes: _notesController.text,
    );

    if (success) {
      await Get.offNamed<void>(AppRoutes.exports.value);
    }
  }
}
