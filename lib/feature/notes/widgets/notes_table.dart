import 'package:Ok/feature/notes/controllers/notes_controller.dart';
import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/note_messages.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class NotesTable extends StatelessWidget {
  const NotesTable({
    required this.controller,
    this.availableWidth,
    super.key,
  });

  final NotesController controller;
  final double? availableWidth;

  static const _headingStyle = TextStyle(
    color: AppUiTokens.textSecondary,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const _dataStyle = TextStyle(
    color: AppUiTokens.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const _headerRowHeight = 44.0;
  static const _contentPreviewLength = 100;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space24),
      child: Obx(() {
        final records = controller.notes;
        final isLoading = controller.isLoading.value;
        final isDeleting = controller.isDeleting.value;
        final deletingId = controller.deletingNoteId.value;

        if (isLoading && records.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppUiTokens.space24,
              vertical: AppUiTokens.space24,
            ),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (records.isEmpty) {
          final message = controller.hasActiveFilters
              ? NoteMessages.listFilteredEmpty
              : NoteMessages.listEmpty;

          return AppTableEmptyState(
            message: message,
            icon: controller.hasActiveFilters
                ? Icons.search_off_outlined
                : Icons.sticky_note_2_outlined,
          );
        }

        final table = DataTable(
          headingRowHeight: _headerRowHeight,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 72,
          headingTextStyle: _headingStyle,
          dataTextStyle: _dataStyle,
          headingRowColor: WidgetStateProperty.all(Colors.transparent),
          dividerThickness: 1,
          columnSpacing: AppUiTokens.space24,
          horizontalMargin: AppUiTokens.space24,
          columns: const [
            DataColumn(label: Text('Müşteri')),
            DataColumn(label: Text('Başlık')),
            DataColumn(label: Text('İçerik')),
            DataColumn(label: Text('Oluşturulma Tarihi')),
            DataColumn(label: Text('İşlemler')),
          ],
          rows: records
              .map(
                (note) => _buildRow(
                  note,
                  isDeleting: isDeleting && deletingId == note.id,
                ),
              )
              .toList(),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final minTableWidth = availableWidth ?? constraints.maxWidth;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _headerRowHeight,
                  child: ColoredBox(color: AppUiTokens.surfaceMuted),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minTableWidth),
                    child: table,
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppUiTokens.surface.withValues(alpha: 0.72),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }

  DataRow _buildRow(
    NoteListItem note, {
    required bool isDeleting,
  }) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              note.displayCustomerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _dataStyle,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _dataStyle,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              _truncateContent(note.content),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _dataStyle,
            ),
          ),
        ),
        DataCell(
          Text(
            AppDateUtils.formatDateTime(note.createdAt),
            style: _dataStyle,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                tooltip: 'Detay',
                icon: Icons.visibility_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.notesDetail.pathForId(note.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Düzenle',
                icon: Icons.edit_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.notesEdit.pathForId(note.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Sil',
                icon: Icons.delete_outline_rounded,
                color: ColorName.error,
                isLoading: isDeleting,
                onPressed: isDeleting
                    ? null
                    : () async {
                        final deleted =
                            await controller.deleteNote(note.id);
                        if (deleted) {
                          await controller.searchAndFilterNotes();
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _truncateContent(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= _contentPreviewLength) {
      return normalized;
    }

    return '${normalized.substring(0, _contentPreviewLength)}...';
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      mouseCursor:
          onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color ?? AppUiTokens.textSecondary,
              ),
            )
          : Icon(icon, size: 18, color: color ?? AppUiTokens.textSecondary),
      style: AppInteractiveTheme.iconButtonStyle(
        IconButton.styleFrom(
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
