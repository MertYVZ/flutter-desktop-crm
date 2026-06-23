import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/shared/widgets/app_date_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceListArchiveFilters extends StatefulWidget {
  const PriceListArchiveFilters({
    required this.controller,
    required this.searchController,
    super.key,
  });

  final PriceListController controller;
  final TextEditingController searchController;

  @override
  State<PriceListArchiveFilters> createState() =>
      _PriceListArchiveFiltersState();
}

class _PriceListArchiveFiltersState extends State<PriceListArchiveFilters> {
  bool _showDateFilters = false;

  static const _fieldHeight = 38.0;
  static const _maxSearchWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchWidth = constraints.maxWidth.clamp(0.0, _maxSearchWidth);

        final searchField = SizedBox(
          width: searchWidth,
          height: _fieldHeight,
          child: TextField(
            controller: widget.searchController,
            style: const TextStyle(
              color: AppUiTokens.textPrimary,
              fontSize: 14,
            ),
            onChanged: (value) {
              widget.controller.archiveSearchQuery.value = value;
              widget.controller.loadArchivedLists();
            },
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Başlık veya açıklama ara...',
              hintStyle: TextStyle(
                color: AppUiTokens.textMuted,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: AppUiTokens.textMuted,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppUiTokens.space12,
                vertical: AppUiTokens.space8,
              ),
            ),
          ),
        );

        final filterToggle = TextButton.icon(
          onPressed: () {
            setState(() => _showDateFilters = !_showDateFilters);
          },
          style: AppInteractiveTheme.textButtonStyle(
            TextButton.styleFrom(
              foregroundColor: AppUiTokens.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppUiTokens.space12,
              ),
            ),
          ),
          icon: Icon(
            _showDateFilters
                ? Icons.filter_list_off_outlined
                : Icons.filter_list_outlined,
            size: 18,
          ),
          label: Text(
            _showDateFilters ? 'Filtreyi Gizle' : 'Filtrele',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        );

        final clearButton = Obx(
          () {
            if (!widget.controller.hasActiveArchiveFilters) {
              return const SizedBox.shrink();
            }

            return TextButton(
              onPressed: () {
                widget.searchController.clear();
                widget.controller.clearArchiveFilters();
              },
              style: AppInteractiveTheme.textButtonStyle(
                TextButton.styleFrom(
                  foregroundColor: AppUiTokens.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space12,
                  ),
                ),
              ),
              child: const Text(
                'Temizle',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            );
          },
        );

        final dateFilters = _showDateFilters
            ? Obx(
                () => Padding(
                  padding: const EdgeInsets.only(top: AppUiTokens.space12),
                  child: Wrap(
                    spacing: AppUiTokens.space12,
                    runSpacing: AppUiTokens.space8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: AppDatePickerField(
                          label: 'Başlangıç',
                          placeholder: 'Başlangıç',
                          compact: true,
                          selectedDate:
                              widget.controller.archiveStartDateFilter.value,
                          onDateSelected: (date) {
                            widget.controller.archiveStartDateFilter.value =
                                date;
                            widget.controller.loadArchivedLists();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: AppDatePickerField(
                          label: 'Bitiş',
                          placeholder: 'Bitiş',
                          compact: true,
                          selectedDate:
                              widget.controller.archiveEndDateFilter.value,
                          onDateSelected: (date) {
                            widget.controller.archiveEndDateFilter.value = date;
                            widget.controller.loadArchivedLists();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink();

        final warning = Obx(() {
          final message = widget.controller.filterWarningMessage.value;
          if (message == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: AppUiTokens.space8),
            child: PanelMessage(message: message),
          );
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                searchField,
                filterToggle,
                clearButton,
              ],
            ),
            dateFilters,
            warning,
          ],
        );
      },
    );
  }
}
