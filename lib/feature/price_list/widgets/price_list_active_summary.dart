import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/models/price_list_status.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/widgets/app_action_menu.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:Ok/product/widgets/status_badge_styles.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class PriceListActiveSummary extends StatelessWidget {
  const PriceListActiveSummary({
    required this.controller,
    required this.title,
    required this.effectiveDate,
    required this.onEdit,
    required this.onAddProduct,
    required this.onExport,
    super.key,
  });

  final PriceListController controller;
  final String title;
  final DateTime effectiveDate;
  final VoidCallback onEdit;
  final VoidCallback onAddProduct;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final infoSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppUiTokens.space8,
              runSpacing: AppUiTokens.space4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppUiTokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                AppStatusBadge(
                  label: PriceListStatus.active.label,
                  style: PriceListStatus.active.badgeStyle,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: AppUiTokens.space4),
            Text(
              'Geçerlilik: ${AppDateUtils.formatDate(effectiveDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
          ],
        );

        final addButton = FilledButton.icon(
          onPressed: onAddProduct,
          style: AppInteractiveTheme.filledButtonStyle(
            FilledButton.styleFrom(
              backgroundColor: ColorName.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppUiTokens.space16,
              ),
              minimumSize: const Size(0, 40),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Ürün Ekle',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        );

        final menu = _MoreActionsMenu(
          controller: controller,
          onEdit: onEdit,
          onExport: onExport,
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              infoSection,
              const SizedBox(height: AppUiTokens.space12),
              Row(
                children: [
                  Expanded(child: addButton),
                  menu,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: infoSection),
            const SizedBox(width: AppUiTokens.space16),
            addButton,
            const SizedBox(width: AppUiTokens.space8),
            menu,
          ],
        );
      },
    );
  }
}

class _MoreActionsMenu extends StatelessWidget {
  const _MoreActionsMenu({
    required this.controller,
    required this.onEdit,
    required this.onExport,
  });

  final PriceListController controller;
  final VoidCallback onEdit;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isArchiving = controller.isArchiving.value;
        final isExporting = controller.isExporting.value;

        return AppActionMenu(
          tooltip: 'Diğer işlemler',
          items: [
            AppActionMenuItem(
              icon: Icons.edit_outlined,
              label: 'Düzenle',
              onTap: onEdit,
            ),
            AppActionMenuItem(
              icon: Icons.archive_outlined,
              label: 'Arşivle',
              enabled: !isArchiving,
              isLoading: isArchiving,
              onTap: controller.archiveActivePriceList,
            ),
            AppActionMenuItem(
              icon: Icons.file_download_outlined,
              label: "Excel'e Aktar",
              enabled: !isExporting,
              isLoading: isExporting,
              onTap: onExport,
            ),
          ],
        );
      },
    );
  }
}
