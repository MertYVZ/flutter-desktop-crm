import 'package:Ok/feature/export/controllers/export_controller.dart';
import 'package:Ok/feature/export/models/export_item_data.dart';
import 'package:Ok/feature/export/widgets/export_items_editor.dart';
import 'package:Ok/feature/export/widgets/export_record_form.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_route_args.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ExportCreatePage extends StatefulWidget {
  const ExportCreatePage({super.key});

  @override
  State<ExportCreatePage> createState() => _ExportCreatePageState();
}

class _ExportCreatePageState extends BaseState<ExportCreatePage> {
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

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = AppRouteArgs.readCustomerId();
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
        controller
          ..clearMessages()
          ..loadCustomersForDropdown();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelFormPageHeader(
                title: 'Yeni İhracat',
                subtitle: 'Yeni ihracat kaydı oluşturun.',
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
                    Obx(
                      () => ExportRecordForm(
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
                            : () => Get.offNamed<void>(AppRoutes.exports.value),
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

  Future<void> _submit(ExportController controller) async {
    final id = await controller.createExport(
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

    if (id != null) {
      await Get.offNamed<void>(AppRoutes.exports.value);
    }
  }
}
