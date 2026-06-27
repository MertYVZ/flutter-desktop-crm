import 'package:Ok/feature/meetings/controllers/meetings_controller.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/feature/meetings/widgets/meeting_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_route_args.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class MeetingCreatePage extends StatefulWidget {
  const MeetingCreatePage({super.key});

  @override
  State<MeetingCreatePage> createState() => _MeetingCreatePageState();
}

class _MeetingCreatePageState extends BaseState<MeetingCreatePage> {
  late final TextEditingController _notesController;
  String? _selectedCustomerId;
  DateTime? _selectedDate;
  MeetingMethod? _selectedMethod;
  MeetingSubject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = AppRouteArgs.readCustomerId();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MeetingsController>(
      viewModel: Get.find<MeetingsController>(),
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
                title: 'Yeni Görüşme',
                subtitle: 'Yeni görüşme kaydı oluşturun.',
                onBack: () => Get.offNamed<void>(AppRoutes.meetings.value),
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
                      () => MeetingForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        date: _selectedDate,
                        selectedMethod: _selectedMethod,
                        selectedSubject: _selectedSubject,
                        notesController: _notesController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onDateChanged: (value) => setState(() {
                          _selectedDate = value;
                        }),
                        onMethodChanged: (value) => setState(() {
                          _selectedMethod = value;
                        }),
                        onSubjectChanged: (value) => setState(() {
                          _selectedSubject = value;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => MeetingFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () =>
                                Get.offNamed<void>(AppRoutes.meetings.value),
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

  Future<void> _submit(MeetingsController controller) async {
    final id = await controller.createMeeting(
      customerId: _selectedCustomerId,
      date: _selectedDate,
      method: _selectedMethod,
      subject: _selectedSubject,
      notes: _notesController.text,
    );

    if (id != null) {
      Get.offNamed<void>(AppRoutes.meetings.value);
    }
  }
}
