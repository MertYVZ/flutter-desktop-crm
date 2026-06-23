import 'package:Ok/feature/price_list/models/price_list_list_item.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceListArchiveTable extends StatelessWidget {
  const PriceListArchiveTable({
    required this.lists,
    required this.isLoading,
    required this.hasActiveFilters,
    this.availableWidth,
    super.key,
  });

  final List<PriceListListItem> lists;
  final bool isLoading;
  final bool hasActiveFilters;
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
    if (isLoading && lists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppUiTokens.space24,
          vertical: AppUiTokens.space32,
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

    if (lists.isEmpty) {
      final message = hasActiveFilters
          ? 'Kriterlere uygun arşivlenmiş fiyat listesi bulunamadı.'
          : 'Henüz arşivlenmiş fiyat listesi bulunmuyor.';

      return AppTableEmptyState(
        message: message,
        icon: hasActiveFilters
            ? Icons.search_off_outlined
            : Icons.archive_outlined,
        verticalPadding: AppUiTokens.space32,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: (availableWidth ?? 800) - 48,
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(0.8),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppUiTokens.border),
                ),
              ),
              children: [
                _headerCell('Başlık'),
                _headerCell('Geçerlilik Tarihi'),
                _headerCell('Ürün'),
                _headerCell(''),
              ],
            ),
            ...lists.map((list) {
              return TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppUiTokens.border),
                  ),
                ),
                children: [
                  _dataCell(list.title),
                  _dataCell(AppDateUtils.formatDate(list.effectiveDate)),
                  _dataCell('${list.itemCount}'),
                  _detailCell(list.id),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _detailCell(String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space8,
        vertical: AppUiTokens.space8,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => Get.toNamed<void>(
            AppRoutes.priceListDetail.pathForId(id),
          ),
          style: AppInteractiveTheme.textButtonStyle(
            TextButton.styleFrom(
              foregroundColor: AppUiTokens.textPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppUiTokens.space12,
              ),
            ),
          ),
          child: const Text(
            'Detay',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return SizedBox(
      height: _headerRowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppUiTokens.space8),
          child: Text(text, style: _headingStyle),
        ),
      ),
    );
  }

  Widget _dataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space8,
        vertical: AppUiTokens.space12,
      ),
      child: Text(text, style: _dataStyle),
    );
  }
}
