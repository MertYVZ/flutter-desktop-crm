import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/feature/scrap_quality/models/scrap_quality_list_item.dart';
import 'package:Ok/feature/scrap_quality/widgets/scrap_sales_status_badge.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/constants/scrap_quality_messages.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class ScrapQualityTable extends StatefulWidget {
  const ScrapQualityTable({
    required this.controller,
    this.availableWidth,
    super.key,
  });

  final ScrapQualityController controller;
  final double? availableWidth;

  @override
  State<ScrapQualityTable> createState() => _ScrapQualityTableState();
}

class _ScrapQualityTableState extends State<ScrapQualityTable> {
  late final ScrollController _horizontalScrollController;

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
  static const _minTableWidth = 1280.0;
  static const _edgePadding = AppUiTokens.space24;
  static const _cellHorizontalPadding = AppUiTokens.space8;

  static const _columnWidths = <int, TableColumnWidth>{
    0: FlexColumnWidth(1.6),
    1: FlexColumnWidth(0.75),
    2: FlexColumnWidth(0.55),
    3: FlexColumnWidth(0.85),
    4: FlexColumnWidth(1.3),
    5: FlexColumnWidth(0.75),
    6: FlexColumnWidth(0.7),
    7: FlexColumnWidth(1.0),
    8: FlexColumnWidth(1.05),
    9: FlexColumnWidth(1.05),
    10: FlexColumnWidth(1.2),
    11: FlexColumnWidth(1.05),
  };

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  EdgeInsets _cellPadding({
    required int columnIndex,
    double vertical = AppUiTokens.space12,
  }) {
    return EdgeInsets.fromLTRB(
      columnIndex == 0 ? _edgePadding : _cellHorizontalPadding,
      vertical,
      columnIndex == 11 ? _edgePadding : _cellHorizontalPadding,
      vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppUiTokens.space24),
      child: Obx(() {
        final records = widget.controller.records;
        final isLoading = widget.controller.isLoading.value;
        final isDeleting = widget.controller.isDeleting.value;
        final deletingId = widget.controller.deletingRecordId.value;

        if (isLoading && records.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _edgePadding,
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
          return AppTableEmptyState(
            message: widget.controller.hasActiveFilters
                ? ScrapQualityMessages.listFilteredEmpty
                : '${ScrapQualityMessages.listEmptyTitle}\n${ScrapQualityMessages.listEmptyBody}',
            icon: widget.controller.hasActiveFilters
                ? Icons.search_off_outlined
                : Icons.recycling_outlined,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = widget.availableWidth ?? constraints.maxWidth;
            final needsHorizontalScroll =
                viewportWidth.isFinite && viewportWidth < _minTableWidth;
            final tableWidth =
                needsHorizontalScroll ? _minTableWidth : viewportWidth;

            final table = Table(
              columnWidths: _columnWidths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppUiTokens.surfaceMuted,
                    border: Border(
                      bottom: BorderSide(color: AppUiTokens.border),
                    ),
                  ),
                  children: [
                    _headerCell('Müşteri Adı', columnIndex: 0),
                    _headerCell('Miktar', columnIndex: 1),
                    _headerCell('Birim', columnIndex: 2),
                    _headerCell('KG Karşılığı', columnIndex: 3),
                    _headerCell('Hurda Türü / Kalite', columnIndex: 4),
                    _headerCell('Tarih', columnIndex: 5),
                    _headerCell('İl', columnIndex: 6),
                    _headerCell('Satış Durumu', columnIndex: 7),
                    _headerCell('Teklif Fiyatı', columnIndex: 8),
                    _headerCell('Hedef Fiyat', columnIndex: 9),
                    _headerCell('Alınmama Nedeni', columnIndex: 10),
                    _headerCell('', columnIndex: 11),
                  ],
                ),
                ...records.map(
                  (record) => _buildRow(
                    record,
                    isDeleting: isDeleting && deletingId == record.id,
                  ),
                ),
              ],
            );

            final sizedTable = SizedBox(
              width: tableWidth,
              child: table,
            );

            final tableWidget = needsHorizontalScroll
                ? Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: false,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: sizedTable,
                    ),
                  )
                : sizedTable;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                tableWidget,
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

  TableRow _buildRow(
    ScrapQualityListItem record, {
    required bool isDeleting,
  }) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppUiTokens.border),
        ),
      ),
      children: [
        _dataCell(record.displayCustomerName, columnIndex: 0),
        _dataCell(QuantityUtils.formatQuantity(record.quantity), columnIndex: 1),
        _dataCell(record.unit, columnIndex: 2),
        _dataCell(QuantityUtils.formatKg(record.quantityKg), columnIndex: 3),
        _dataCell(record.scrapType, columnIndex: 4),
        _dataCell(AppDateUtils.formatDate(record.recordDate), columnIndex: 5),
        _dataCell(record.city ?? '—', columnIndex: 6),
        _dataCellWidget(
          ScrapSalesStatusBadge(status: record.salesStatusEnum),
          columnIndex: 7,
        ),
        _dataCell(
          record.offerPrice == null
              ? '—'
              : '${MoneyUtils.formatAmountInput(record.offerPrice!)} TL/KG',
          columnIndex: 8,
        ),
        _dataCell(
          record.targetPrice == null
              ? '—'
              : '${MoneyUtils.formatAmountInput(record.targetPrice!)} TL/KG',
          columnIndex: 9,
        ),
        _dataCell(record.lostReasonLabel ?? '—', columnIndex: 10),
        _actionsCell(
          record: record,
          isDeleting: isDeleting,
        ),
      ],
    );
  }

  Widget _headerCell(String text, {required int columnIndex}) {
    return SizedBox(
      height: _headerRowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: _cellPadding(columnIndex: columnIndex, vertical: 0),
          child: Text(text, style: _headingStyle),
        ),
      ),
    );
  }

  Widget _dataCell(String text, {required int columnIndex}) {
    return Padding(
      padding: _cellPadding(columnIndex: columnIndex),
      child: Text(
        text,
        style: _dataStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _dataCellWidget(Widget child, {required int columnIndex}) {
    return Padding(
      padding: _cellPadding(
        columnIndex: columnIndex,
        vertical: AppUiTokens.space8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _actionsCell({
    required ScrapQualityListItem record,
    required bool isDeleting,
  }) {
    return Padding(
      padding: _cellPadding(
        columnIndex: 11,
        vertical: AppUiTokens.space4,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                tooltip: 'Görüntüle',
                icon: Icons.visibility_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.scrapQualityDetail.pathForId(record.id),
                        ),
              ),
              const SizedBox(width: AppUiTokens.space8),
              _ActionIconButton(
                tooltip: 'Düzenle',
                icon: Icons.edit_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.scrapQualityEdit.pathForId(record.id),
                        ),
              ),
              const SizedBox(width: AppUiTokens.space8),
              _ActionIconButton(
                tooltip: 'Sil',
                icon: Icons.delete_outline_rounded,
                color: ColorName.error,
                isLoading: isDeleting,
                onPressed: isDeleting
                    ? null
                    : () async {
                        final deleted =
                            await widget.controller.deleteRecord(record.id);
                        if (deleted) {
                          await widget.controller.searchAndFilterRecords();
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.all(AppUiTokens.space4),
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color ?? AppUiTokens.textSecondary,
              ),
            )
          : Icon(icon, size: 20, color: color ?? AppUiTokens.textSecondary),
      style: AppInteractiveTheme.iconButtonStyle(
        IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
        ),
      ),
    );
  }
}
