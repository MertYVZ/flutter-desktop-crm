import 'package:Ok/feature/notes/controllers/notes_controller.dart';
import 'package:Ok/feature/notes/widgets/note_form.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/note_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class NoteEditPage extends StatefulWidget {
  const NoteEditPage({super.key});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends BaseState<NoteEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _selectedCustomerId;
  bool _isFormInitialized = false;

  String get _noteId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _populateForm(NotesController controller) {
    final note = controller.selectedNote.value;
    if (note == null || _isFormInitialized) {
      return;
    }

    _selectedCustomerId = note.customerId;
    _titleController.text = note.title;
    _contentController.text = note.content;
    _isFormInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<NotesController>(
      viewModel: Get.find<NotesController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.loadCustomersForDropdown();
        controller.getNoteById(_noteId).then((loaded) {
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
              (controller.selectedNote.value != null &&
                  !_isFormInitialized)) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final note = controller.selectedNote.value;
          if (note == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? NoteMessages.notFound,
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
                  title: 'Not Düzenle',
                  subtitle: note.title,
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
                      NoteForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        titleController: _titleController,
                        contentController: _contentController,
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                      ),
                      const SizedBox(height: AppUiTokens.space24),
                      Obx(
                        () => NoteFormActions(
                          isSaving: controller.isSaving.value,
                          onSave: controller.isSaving.value
                              ? null
                              : () => _submit(controller),
                          onCancel: controller.isSaving.value
                              ? () {}
                              : () => Get.offNamed<void>(
                                    AppRoutes.notesDetail.pathForId(_noteId),
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

  Future<void> _submit(NotesController controller) async {
    final success = await controller.updateNote(
      id: _noteId,
      customerId: _selectedCustomerId,
      title: _titleController.text,
      content: _contentController.text,
    );

    if (success) {
      Get.offNamed<void>(AppRoutes.notesDetail.pathForId(_noteId));
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
