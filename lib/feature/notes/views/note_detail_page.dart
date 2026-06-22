import 'package:Ok/feature/notes/controllers/notes_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/note_messages.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

const _detailMaxWidth = 1200.0;
const _twoColumnBreakpoint = 800.0;
const _infoColumnFlex = 2;
const _contentColumnFlex = 3;
const _contentMaxHeight = 480.0;

final class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends BaseState<NoteDetailPage> {
  String get _noteId => Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return BaseView<NotesController>(
      viewModel: Get.find<NotesController>(),
      onModelReady: (controller) {
        controller
          ..clearMessages()
          ..getNoteById(_noteId);
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedNote.value == null) {
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

          return Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _detailMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageHeader(
                      title: note.title,
                      subtitle: 'Not kayıt detayları',
                      onBack: () => Get.offNamed<void>(AppRoutes.notes.value),
                      onEdit: () => Get.toNamed<void>(
                        AppRoutes.notesEdit.pathForId(note.id),
                      ),
                      onDelete: controller.isDeleting.value
                          ? null
                          : () async {
                              final deleted =
                                  await controller.deleteNote(note.id);
                              if (deleted) {
                                await Get.offNamed<void>(
                                  AppRoutes.notes.value,
                                );
                              }
                            },
                      isDeleting: controller.isDeleting.value,
                    ),
                    const SizedBox(height: AppUiTokens.space16),
                    Obx(() {
                      final error = controller.errorMessage.value;
                      final success = controller.successMessage.value;

                      if (error == null && success == null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (success != null)
                            PanelMessage(
                              message: success,
                              type: PanelMessageType.info,
                            ),
                          if (error != null && success != null)
                            const SizedBox(height: AppUiTokens.space12),
                          if (error != null) PanelMessage(message: error),
                          const SizedBox(height: AppUiTokens.space16),
                        ],
                      );
                    }),
                    LayoutBuilder(
                      builder: (context, bodyConstraints) {
                        final isCompact =
                            bodyConstraints.maxWidth < _twoColumnBreakpoint;

                        final infoCard = _NoteInfoCard(
                          customerName: note.displayCustomerName,
                          title: note.title,
                          createdAt:
                              AppDateUtils.formatDateTime(note.createdAt),
                          updatedAt:
                              AppDateUtils.formatDateTime(note.updatedAt),
                        );

                        final contentCard = _ContentCard(content: note.content);

                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              infoCard,
                              const SizedBox(height: AppUiTokens.space16),
                              contentCard,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: _infoColumnFlex, child: infoCard),
                            const SizedBox(width: AppUiTokens.space24),
                            Expanded(
                              flex: _contentColumnFlex,
                              child: contentCard,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        final titleSection = Column(
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

        final actions = Wrap(
          spacing: AppUiTokens.space8,
          runSpacing: AppUiTokens.space8,
          children: [
            _HeaderButton(
              label: 'Geri Dön',
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
            _HeaderButton(
              label: 'Düzenle',
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
            _HeaderButton(
              label: 'Sil',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              isLoading: isDeleting,
              onPressed: onDelete,
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              const SizedBox(height: AppUiTokens.space16),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            actions,
          ],
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isDestructive ? ColorName.error : AppUiTokens.textPrimary;
    final borderColor =
        isDestructive ? const Color(0xFFFECACA) : AppUiTokens.border;
    final backgroundColor =
        isDestructive ? const Color(0xFFFEF2F2) : AppUiTokens.surface;

    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: AppInteractiveTheme.outlinedButtonStyle(
          OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            side: BorderSide(color: borderColor),
            padding:
                const EdgeInsets.symmetric(horizontal: AppUiTokens.space16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            ),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppUiTokens.textSecondary,
        ),
        const SizedBox(width: AppUiTokens.space8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _NoteInfoCard extends StatelessWidget {
  const _NoteInfoCard({
    required this.customerName,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String customerName;
  final String title;
  final String createdAt;
  final String updatedAt;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Not Bilgileri',
            icon: Icons.sticky_note_2_outlined,
          ),
          const SizedBox(height: AppUiTokens.space24),
          _InfoField(label: 'Müşteri', value: customerName),
          _InfoField(label: 'Başlık', value: title),
          const Divider(height: 1, color: AppUiTokens.border),
          const SizedBox(height: AppUiTokens.space16),
          _InfoField(label: 'Oluşturulma tarihi', value: createdAt),
          _InfoField(
            label: 'Güncellenme tarihi',
            value: updatedAt,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PanelSurface(
      padding: const EdgeInsets.all(AppUiTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionTitle(
            title: 'İçerik',
            icon: Icons.article_outlined,
          ),
          const SizedBox(height: AppUiTokens.space16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppUiTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              border: Border.all(color: AppUiTokens.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppUiTokens.space16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: _contentMaxHeight,
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      content,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppUiTokens.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppUiTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: AppUiTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppUiTokens.space4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppUiTokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
