import 'package:Ok/feature/export/controllers/export_controller.dart';
import 'package:Ok/feature/export/models/export_product_names.dart';
import 'package:Ok/feature/export/widgets/export_record_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/export_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
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
  late final List<TextEditingController> _productControllers;
  late final TextEditingController _quantityTonController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _bankController;
  late final TextEditingController _firstPaymentAmountController;
  late final TextEditingController _lastPaymentAmountController;
  late final TextEditingController _wasteKgController;
  late final TextEditingController _netTotalAmountController;
  late final TextEditingController _logisticsNameController;
  late final TextEditingController _logisticsCostController;
  late final TextEditingController _customsCostController;
  late final TextEditingController _insuranceCostController;
  late final TextEditingController _notesController;
  String? _selectedCustomerId;
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
    _productControllers = [TextEditingController()];
    _quantityTonController = TextEditingController();
    _unitPriceController = TextEditingController();
    _paymentMethodController = TextEditingController();
    _bankController = TextEditingController();
    _firstPaymentAmountController = TextEditingController();
    _lastPaymentAmountController = TextEditingController();
    _wasteKgController = TextEditingController();
    _netTotalAmountController = TextEditingController();
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
    for (final controller in _productControllers) {
      controller.dispose();
    }
    _quantityTonController.dispose();
    _unitPriceController.dispose();
    _paymentMethodController.dispose();
    _bankController.dispose();
    _firstPaymentAmountController.dispose();
    _lastPaymentAmountController.dispose();
    _wasteKgController.dispose();
    _netTotalAmountController.dispose();
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

  String get _totalPriceText {
    final quantity = QuantityUtils.parseQuantity(_quantityTonController.text);
    final unitPrice = MoneyUtils.parseAmountToMinor(_unitPriceController.text);
    if (quantity == null || unitPrice == null) {
      return '';
    }

    return MoneyUtils.formatAmountInputFromMinor(
      (quantity * unitPrice).round(),
    );
  }

  void _setOptionalAmount(TextEditingController controller, int? amountMinor) {
    if (amountMinor == null) {
      return;
    }

    PanelAmountField.setAmountFromMinor(controller, amountMinor);
  }

  void _populateForm(ExportController controller) {
    final record = controller.selectedExport.value;
    if (record == null || _isFormInitialized) {
      return;
    }

    _titleController.text = record.title;
    if (record.customerId.trim().isEmpty) {
      _selectedCustomerId = null;
      _guestCustomerNameController.text = record.customerNameSnapshot ?? '';
    } else {
      _selectedCustomerId = record.customerId;
      _guestCustomerNameController.text = record.customerNameSnapshot ?? '';
    }
    _quantityTonController.text =
        QuantityUtils.formatQuantityInput(record.quantityTon);
    PanelAmountField.setAmountFromMinor(
      _unitPriceController,
      record.unitPriceMinor,
    );
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
    if (record.wasteKg != null) {
      _wasteKgController.text = QuantityUtils.formatQuantityInput(record.wasteKg!);
    }
    _setOptionalAmount(_netTotalAmountController, record.netTotalAmountMinor);
    _logisticsNameController.text = record.logisticsName ?? '';
    _shipmentDate = record.shipmentDate;
    _deliveryDate = record.deliveryDate;
    _setOptionalAmount(_logisticsCostController, record.logisticsCostMinor);
    _setOptionalAmount(_customsCostController, record.customsCostMinor);
    _setOptionalAmount(_insuranceCostController, record.insuranceCostMinor);
    _notesController.text = record.notes ?? '';

    final productNames = ExportProductNames.parse(record.productName);
    _replaceProductControllers(
      productNames.isEmpty ? [''] : productNames,
    );

    _isFormInitialized = true;
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

          final record = controller.selectedExport.value;
          if (record == null) {
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
                  subtitle: record.title,
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
                        productControllers: _productControllers,
                        onAddProduct: _addProduct,
                        onRemoveProduct: _removeProduct,
                        titleController: _titleController,
                        quantityTonController: _quantityTonController,
                        unitPriceController: _unitPriceController,
                        totalPriceText: _totalPriceText,
                        paymentMethodController: _paymentMethodController,
                        bankController: _bankController,
                        firstPaymentDate: _firstPaymentDate,
                        firstPaymentAmountController:
                            _firstPaymentAmountController,
                        lastPaymentDate: _lastPaymentDate,
                        lastPaymentAmountController:
                            _lastPaymentAmountController,
                        wasteKgController: _wasteKgController,
                        netTotalAmountController: _netTotalAmountController,
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
      productNames:
          _productControllers.map((controller) => controller.text).toList(),
      quantityTonText: _quantityTonController.text,
      unitPriceText: _unitPriceController.text,
      paymentMethod: _paymentMethodController.text,
      bank: _bankController.text,
      firstPaymentDate: _firstPaymentDate,
      firstPaymentAmountText: _firstPaymentAmountController.text,
      lastPaymentDate: _lastPaymentDate,
      lastPaymentAmountText: _lastPaymentAmountController.text,
      wasteKgText: _wasteKgController.text,
      netTotalAmountText: _netTotalAmountController.text,
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
