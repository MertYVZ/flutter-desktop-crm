import 'package:Ok/feature/due_tracking/controllers/due_tracking_controller.dart';
import 'package:Ok/feature/due_tracking/models/currency_type.dart';
import 'package:Ok/feature/due_tracking/widgets/due_record_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class DueTrackingCreatePage extends StatefulWidget {
  const DueTrackingCreatePage({super.key});

  @override
  State<DueTrackingCreatePage> createState() => _DueTrackingCreatePageState();
}

class _DueTrackingCreatePageState extends BaseState<DueTrackingCreatePage> {
  late final TextEditingController _amountController;
  late final TextEditingController _invoiceNoController;
  String? _selectedCustomerId;
  DateTime? _selectedDueDate;
  CurrencyType? _selectedCurrency = CurrencyType.try_;

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

  @override
  Widget build(BuildContext context) {
    return BaseView<DueTrackingController>(
      viewModel: Get.find<DueTrackingController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadCustomersForDropdown();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PageHeader(
                title: 'Yeni Vade Kaydı',
                subtitle: 'Yeni vade kaydı oluşturun.',
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
                      () => DueRecordForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        dueDate: _selectedDueDate,
                        amountController: _amountController,
                        invoiceNoController: _invoiceNoController,
                        selectedCurrency: _selectedCurrency,
                        showStatus: false,
                        selectedStatus: null,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onDueDateChanged: (value) => setState(() {
                          _selectedDueDate = value;
                        }),
                        onCurrencyChanged: (value) => setState(() {
                          _selectedCurrency = value;
                        }),
                        onStatusChanged: (_) {},
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => DueRecordFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () =>
                                Get.offNamed<void>(AppRoutes.dueTracking.value),
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

  Future<void> _submit(DueTrackingController controller) async {
    final id = await controller.createDueRecord(
      customerId: _selectedCustomerId,
      dueDate: _selectedDueDate,
      amountText: _amountController.text,
      currency: _selectedCurrency,
      invoiceNo: _invoiceNoController.text,
    );

    if (id != null) {
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
