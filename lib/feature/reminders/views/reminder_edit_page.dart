import 'dart:async';

import 'package:Ok/feature/reminders/controllers/reminders_controller.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/feature/reminders/models/reminder_status.dart';
import 'package:Ok/feature/reminders/widgets/reminder_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/reminder_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class ReminderEditPage extends StatefulWidget {
  const ReminderEditPage({super.key});

  @override
  State<ReminderEditPage> createState() => _ReminderEditPageState();
}

class _ReminderEditPageState extends BaseState<ReminderEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  String? _selectedCustomerId;
  ReminderPeriod? _selectedPeriod;
  ReminderStatus? _selectedStatus;
  DateTime? _selectedStartDate;
  DateTime? _selectedNextReminderDate;
  bool _isFormInitialized = false;

  String get _reminderId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _populateForm(RemindersController controller) {
    final reminder = controller.selectedReminder.value;
    if (reminder == null || _isFormInitialized) {
      return;
    }

    _selectedCustomerId = reminder.customerId;
    _titleController.text = reminder.title;
    _selectedPeriod = reminder.reminderPeriod;
    _selectedStartDate = reminder.startDate;
    _selectedNextReminderDate = reminder.nextReminderDate;
    _selectedStatus = reminder.reminderStatus;
    _noteController.text = reminder.note ?? '';
    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<RemindersController>(
      viewModel: Get.find<RemindersController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        unawaited(_loadReminder(controller));
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value ||
              (controller.selectedReminder.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final reminder = controller.selectedReminder.value;
          if (reminder == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? ReminderMessages.notFound,
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
                  title: 'Hatırlatma Düzenle',
                  subtitle: reminder.customerName,
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
                      ReminderForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        titleController: _titleController,
                        selectedPeriod: _selectedPeriod,
                        startDate: _selectedStartDate,
                        nextReminderDate: _selectedNextReminderDate,
                        selectedStatus: _selectedStatus,
                        noteController: _noteController,
                        showEditFields: true,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onPeriodChanged: (value) => setState(() {
                          _selectedPeriod = value;
                        }),
                        onStartDateChanged: (value) => setState(() {
                          _selectedStartDate = value;
                        }),
                        onNextReminderDateChanged: (value) => setState(() {
                          _selectedNextReminderDate = value;
                        }),
                        onStatusChanged: (value) => setState(() {
                          _selectedStatus = value;
                        }),
                      ),
                      const SizedBox(height: AppUiTokens.space24),
                      Obx(
                        () => ReminderFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onCancel: controller.isSaving.value
                              ? () {}
                              : () => Get.offNamed<void>(
                                    AppRoutes.reminders.value,
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

  Future<void> _loadReminder(RemindersController controller) async {
    controller.clearMessages();
    await controller.loadCustomersForDropdown();
    final loaded = await controller.getReminderById(_reminderId);
    if (!loaded || !mounted) {
      return;
    }

    setState(() {
      _populateForm(controller);
    });
  }

  Future<void> _submit(RemindersController controller) async {
    final success = await controller.updateReminder(
      id: _reminderId,
      customerId: _selectedCustomerId,
      title: _titleController.text,
      period: _selectedPeriod,
      startDate: _selectedStartDate,
      nextReminderDate: _selectedNextReminderDate,
      status: _selectedStatus,
      note: _noteController.text,
    );

    if (success) {
      await Get.offNamed<void>(AppRoutes.reminders.value);
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
