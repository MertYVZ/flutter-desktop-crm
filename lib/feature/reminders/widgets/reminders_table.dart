import 'package:Ok/feature/reminders/controllers/reminders_controller.dart';
import 'package:Ok/feature/reminders/models/reminder_list_item.dart';
import 'package:Ok/feature/reminders/models/reminder_period.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/reminder_messages.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class RemindersTable extends StatelessWidget {
  const RemindersTable({
    required this.controller,
    this.availableWidth,
    super.key,
  });

  final RemindersController controller;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space24),
      child: Obx(() {
        final records = controller.reminders;
        final isLoading = controller.isLoading.value;
        final isDeleting = controller.isDeleting.value;
        final isCompleting = controller.isCompleting.value;
        final deletingId = controller.deletingReminderId.value;
        final completingId = controller.completingReminderId.value;
        final isActionLocked = isDeleting || isCompleting;

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
              ? ReminderMessages.listFilteredEmpty
              : ReminderMessages.listEmpty;

          return AppTableEmptyState(
            message: message,
            icon: controller.hasActiveFilters
                ? Icons.search_off_outlined
                : Icons.notifications_none_outlined,
          );
        }

        final table = DataTable(
          headingRowHeight: _headerRowHeight,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 52,
          headingTextStyle: _headingStyle,
          dataTextStyle: _dataStyle,
          headingRowColor: WidgetStateProperty.all(Colors.transparent),
          dividerThickness: 1,
          columnSpacing: AppUiTokens.space24,
          horizontalMargin: AppUiTokens.space24,
          columns: const [
            DataColumn(label: Text('Müşteri Adı')),
            DataColumn(label: Text('Başlık')),
            DataColumn(label: Text('Periyot')),
            DataColumn(label: Text('Hatırlatma Tarihi')),
            DataColumn(label: Text('Bir Sonraki Hatırlatma Tarihi')),
            DataColumn(label: Text('İşlemler')),
          ],
          rows: records
              .map(
                (reminder) => _buildRow(
                  reminder,
                  isDeleting: isDeleting && deletingId == reminder.id,
                  isCompleting: isCompleting && completingId == reminder.id,
                  isActionLocked: isActionLocked,
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
    ReminderListItem reminder, {
    required bool isDeleting,
    required bool isCompleting,
    required bool isActionLocked,
  }) {
    final rowColor = reminder.isPassive
        ? AppUiTokens.textMuted.withValues(alpha: 0.08)
        : null;
    final nextDateStyle = _nextReminderDateStyle(reminder);

    return DataRow(
      color: rowColor == null
          ? null
          : WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              reminder.customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _cellStyle(reminder, _dataStyle),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              reminder.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _cellStyle(reminder, _dataStyle),
            ),
          ),
        ),
        DataCell(
          Text(
            reminder.reminderPeriod?.label ?? reminder.period,
            style: _cellStyle(reminder, _dataStyle),
          ),
        ),
        DataCell(
          Text(
            AppDateUtils.formatDate(reminder.startDate),
            style: _cellStyle(reminder, _dataStyle),
          ),
        ),
        DataCell(
          Text(
            AppDateUtils.formatDate(reminder.nextReminderDate),
            style: _cellStyle(reminder, nextDateStyle),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                tooltip: 'Tamamlandı',
                icon: Icons.check_circle_outline_rounded,
                color: ColorName.primary,
                isLoading: isCompleting,
                onPressed: isActionLocked || reminder.isPassive
                    ? null
                    : () async {
                        final completed =
                            await controller.completeReminder(reminder.id);
                        if (completed) {
                          await controller.searchAndFilterReminders();
                        }
                      },
              ),
              _ActionIconButton(
                tooltip: 'Düzenle',
                icon: Icons.edit_outlined,
                onPressed: isActionLocked
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.remindersEdit.pathForId(reminder.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Sil',
                icon: Icons.delete_outline_rounded,
                color: ColorName.error,
                isLoading: isDeleting,
                onPressed: isActionLocked
                    ? null
                    : () async {
                        final deleted =
                            await controller.deleteReminder(reminder.id);
                        if (deleted) {
                          await controller.searchAndFilterReminders();
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _cellStyle(ReminderListItem reminder, TextStyle base) {
    if (!reminder.isPassive) {
      return base;
    }

    return base.copyWith(color: AppUiTokens.textMuted);
  }

  TextStyle _nextReminderDateStyle(ReminderListItem reminder) {
    if (reminder.isPassive) {
      return _dataStyle.copyWith(color: AppUiTokens.textMuted);
    }

    if (reminder.isOverdue) {
      return _dataStyle.copyWith(
        color: ColorName.error,
        fontWeight: FontWeight.w700,
      );
    }

    if (reminder.isToday) {
      return _dataStyle.copyWith(
        color: const Color(0xFFB45309),
        fontWeight: FontWeight.w700,
      );
    }

    return _dataStyle;
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
