import 'package:Ok/feature/reminders/controllers/reminders_controller.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/widgets/reminder_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_route_args.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ReminderCreatePage extends StatefulWidget {
  const ReminderCreatePage({super.key});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends BaseState<ReminderCreatePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  String? _selectedCustomerId;
  ReminderPeriod? _selectedPeriod = ReminderPeriod.monthly;
  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = AppRouteArgs.readCustomerId();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
    _selectedStartDate = AppDateUtils.normalizeDate(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<RemindersController>(
      viewModel: Get.find<RemindersController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadCustomersForDropdown();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelFormPageHeader(
                title: 'Yeni Hatırlatma',
                subtitle: 'Yeni hatırlatma kaydı oluşturun.',
                onBack: () => Get.offNamed<void>(AppRoutes.reminders.value),
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
                      () => ReminderForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        titleController: _titleController,
                        selectedPeriod: _selectedPeriod,
                        startDate: _selectedStartDate,
                        noteController: _noteController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onPeriodChanged: (value) => setState(() {
                          _selectedPeriod = value;
                        }),
                        onStartDateChanged: (value) => setState(() {
                          _selectedStartDate = value;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => ReminderFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () =>
                                Get.offNamed<void>(AppRoutes.reminders.value),
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

  Future<void> _submit(RemindersController controller) async {
    final id = await controller.createReminder(
      customerId: _selectedCustomerId,
      title: _titleController.text,
      period: _selectedPeriod,
      startDate: _selectedStartDate,
      note: _noteController.text,
    );

    if (id != null) {
      Get.offNamed<void>(AppRoutes.reminders.value);
    }
  }
}
