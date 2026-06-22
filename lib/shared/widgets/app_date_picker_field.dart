import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/shared/widgets/app_date_picker_overlay.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class AppDatePickerField extends FormField<DateTime> {
  AppDatePickerField({
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
    super.key,
    String? label,
    String? placeholder,
    super.validator,
    super.onSaved,
    super.enabled = true,
    this.firstDate,
    this.lastDate,
    this.compact = false,
  }) : super(
          initialValue: selectedDate,
          builder: (field) {
            return _AppDatePickerFieldBody(
              field: field,
              label: label,
              placeholder: placeholder,
              enabled: enabled,
              firstDate: firstDate,
              lastDate: lastDate,
              compact: compact,
              onDateSelected: onDateSelected,
            );
          },
        );

  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool compact;
}

class _AppDatePickerFieldBody extends StatefulWidget {
  const _AppDatePickerFieldBody({
    required this.field,
    required this.onDateSelected,
    this.label,
    this.placeholder,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.compact = false,
  });

  final FormFieldState<DateTime> field;
  final ValueChanged<DateTime?> onDateSelected;
  final String? label;
  final String? placeholder;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool compact;

  @override
  State<_AppDatePickerFieldBody> createState() => _AppDatePickerFieldBodyState();
}

class _AppDatePickerFieldBodyState extends State<_AppDatePickerFieldBody> {
  final GlobalKey _triggerKey = GlobalKey();
  bool _isOpen = false;

  Future<void> _pickDate() async {
    if (!widget.enabled || _isOpen) {
      return;
    }

    setState(() => _isOpen = true);

    final picked = await showAppDatePickerOverlay(
      context: context,
      anchorKey: _triggerKey,
      initialDate: widget.field.value,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (mounted) {
      setState(() => _isOpen = false);
    }

    if (picked == null) {
      return;
    }

    widget.field.didChange(picked);
    widget.onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDate = widget.field.value;
    final displayText = effectiveDate == null
        ? null
        : AppDateUtils.formatDate(effectiveDate);

    final fieldHeight = widget.compact ? 38.0 : 48.0;
    final horizontalPadding =
        widget.compact ? AppUiTokens.space12 : AppUiTokens.space16;
    final fontSize = widget.compact ? 14.0 : 15.0;
    final iconSize = widget.compact ? 16.0 : 18.0;

    final trigger = MouseRegion(
      key: _triggerKey,
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _pickDate,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: fieldHeight,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppUiTokens.surface
                  : AppUiTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(
                color: widget.field.hasError
                    ? const Color(0xFFDC2626)
                    : _isOpen
                        ? ColorName.primary
                        : AppUiTokens.border,
                width: _isOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText ??
                        widget.placeholder ??
                        'Tarih seçiniz',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: displayText == null
                          ? AppUiTokens.textMuted
                          : AppUiTokens.textPrimary,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: iconSize,
                  color: widget.enabled
                      ? AppUiTokens.textSecondary
                      : AppUiTokens.textMuted,
                ),
              ],
            ),
          ),
        ),
      );

    if (widget.label == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          trigger,
          if (widget.field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppUiTokens.space8),
              child: Text(
                widget.field.errorText ?? '',
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label!,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        trigger,
        if (widget.field.hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppUiTokens.space8),
            child: Text(
              widget.field.errorText ?? '',
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
