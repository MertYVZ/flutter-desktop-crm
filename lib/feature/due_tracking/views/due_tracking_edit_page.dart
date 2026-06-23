import 'package:Ok/feature/due_tracking/controllers/due_tracking_controller.dart';
import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/models/due_record_status.dart';
import 'package:Ok/feature/due_tracking/widgets/due_record_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/due_record_messages.dart';
import 'package:Ok/product/widgets/panel/panel_amount_field.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class DueTrackingEditPage extends StatefulWidget {
  const DueTrackingEditPage({super.key});

  @override
  State<DueTrackingEditPage> createState() => _DueTrackingEditPageState();
}

class _DueTrackingEditPageState extends BaseState<DueTrackingEditPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _invoiceNoController;
  String? _selectedCustomerId;
  DateTime? _selectedDueDate;
  CurrencyType? _selectedCurrency;
  DueRecordStatus? _selectedStatus;
  bool _isFormInitialized = false;

  String get _recordId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _invoiceNoController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _invoiceNoController.dispose();
    super.dispose();
  }

  void _populateForm(DueTrackingController controller) {
    final record = controller.selectedDueRecord.value;
    if (record == null || _isFormInitialized) {
      return;
    }

    _selectedCustomerId = record.customerId;
    _selectedDueDate = record.dueDate;
    PanelAmountField.setAmountFromMinor(_amountController, record.amountMinor);
    _selectedCurrency = CurrencyTypeX.fromValue(record.currency) ??
        CurrencyType.try_;
    _invoiceNoController.text = record.invoiceNo;
    _selectedStatus =
        DueRecordStatusX.fromValue(record.status) ?? DueRecordStatus.pending;
    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DueTrackingController>(
      viewModel: Get.find<DueTrackingController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.loadCustomersForDropdown();
        controller.getDueRecordById(_recordId).then((loaded) {
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
              (controller.selectedDueRecord.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final record = controller.selectedDueRecord.value;
          if (record == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? DueRecordMessages.notFound,
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
                _PageHeader(
                  title: 'Vade Kaydı Düzenle',
                  subtitle: record.invoiceNo,
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
                      DueRecordForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        dueDate: _selectedDueDate,
                        amountController: _amountController,
                        invoiceNoController: _invoiceNoController,
                        selectedCurrency: _selectedCurrency,
                        showStatus: true,
                        selectedStatus: _selectedStatus,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onDueDateChanged: (value) => setState(() {
                          _selectedDueDate = value;
                        }),
                        onCurrencyChanged: (value) => setState(() {
                          _selectedCurrency = value;
                        }),
                        onStatusChanged: (value) => setState(() {
                          _selectedStatus = value;
                        }),
                      ),
                      const SizedBox(height: AppUiTokens.space24),
                      Obx(
                        () => DueRecordFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onCancel: controller.isSaving.value
                              ? () {}
                              : () => Get.offNamed<void>(
                                    AppRoutes.dueTracking.value,
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

  Future<void> _submit(DueTrackingController controller) async {
    final success = await controller.updateDueRecord(
      id: _recordId,
      customerId: _selectedCustomerId,
      dueDate: _selectedDueDate,
      amountText: _amountController.text,
      currency: _selectedCurrency,
      invoiceNo: _invoiceNoController.text,
      status: _selectedStatus,
    );

    if (success) {
      Get.offNamed<void>(AppRoutes.dueTracking.value);
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
