import 'package:Ok/feature/meetings/controllers/meetings_controller.dart';
import 'package:Ok/feature/meetings/models/meeting_method.dart';
import 'package:Ok/feature/meetings/models/meeting_subject.dart';
import 'package:Ok/feature/meetings/widgets/meeting_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/meeting_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class MeetingEditPage extends StatefulWidget {
  const MeetingEditPage({super.key});

  @override
  State<MeetingEditPage> createState() => _MeetingEditPageState();
}

class _MeetingEditPageState extends BaseState<MeetingEditPage> {
  late final TextEditingController _notesController;
  String? _selectedCustomerId;
  DateTime? _selectedDate;
  MeetingMethod? _selectedMethod;
  MeetingSubject? _selectedSubject;
  bool _isFormInitialized = false;

  String get _meetingId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _populateForm(MeetingsController controller) {
    final meeting = controller.selectedMeeting.value;
    if (meeting == null || _isFormInitialized) {
      return;
    }

    _selectedCustomerId = meeting.customerId;
    _selectedDate = meeting.date;
    _selectedMethod = meeting.meetingMethod;
    _selectedSubject = meeting.meetingSubject;
    _notesController.text = meeting.notes ?? '';
    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MeetingsController>(
      viewModel: Get.find<MeetingsController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.loadCustomersForDropdown();
        controller.getMeetingById(_meetingId).then((loaded) {
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
              (controller.selectedMeeting.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final meeting = controller.selectedMeeting.value;
          if (meeting == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? MeetingMessages.notFound,
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
                  title: 'Görüşme Düzenle',
                  subtitle: meeting.customerName,
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
                      MeetingForm(
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
                      const SizedBox(height: AppUiTokens.space24),
                      Obx(
                        () => MeetingFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onCancel: controller.isSaving.value
                              ? () {}
                              : () => Get.offNamed<void>(
                                    AppRoutes.meetingsDetail
                                        .pathForId(_meetingId),
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

  Future<void> _submit(MeetingsController controller) async {
    final success = await controller.updateMeeting(
      id: _meetingId,
      customerId: _selectedCustomerId,
      date: _selectedDate,
      method: _selectedMethod,
      subject: _selectedSubject,
      notes: _notesController.text,
    );

    if (success) {
      Get.offNamed<void>(AppRoutes.meetingsDetail.pathForId(_meetingId));
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
