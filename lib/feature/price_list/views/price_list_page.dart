import 'package:Ok/feature/price_list/controllers/price_list_controller.dart';
import 'package:Ok/feature/price_list/widgets/price_list_active_summary.dart';
import 'package:Ok/feature/price_list/widgets/price_list_archive_filters.dart';
import 'package:Ok/feature/price_list/widgets/price_list_archive_table.dart';
import 'package:Ok/feature/price_list/widgets/price_list_product_filters.dart';
import 'package:Ok/feature/price_list/widgets/price_list_product_form_dialog.dart';
import 'package:Ok/feature/price_list/widgets/price_list_products_table.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/app_empty_state.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class PriceListPage extends StatefulWidget {
  const PriceListPage({super.key});

  @override
  State<PriceListPage> createState() => _PriceListPageState();
}

class _PriceListPageState extends BaseState<PriceListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _productSearchController;
  late final TextEditingController _archiveSearchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _productSearchController = TextEditingController();
    _archiveSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productSearchController.dispose();
    _archiveSearchController.dispose();
    super.dispose();
  }

  void _navigateToCreate() => Get.toNamed<void>(AppRoutes.priceListNew.value);

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceListController>(
      viewModel: Get.find<PriceListController>(),
      onModelReady: (controller) => controller.loadPageData(),
      onPageBuilder: (context, controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return PanelFormScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageHeader(onCreatePressed: _navigateToCreate),
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
                        if (error != null) PanelMessage(message: error),
                        if (error != null && success != null)
                          const SizedBox(height: AppUiTokens.space8),
                        if (success != null)
                          PanelMessage(
                            message: success,
                            type: PanelMessageType.info,
                          ),
                        const SizedBox(height: AppUiTokens.space16),
                      ],
                    );
                  }),
                  _SectionTabBar(tabController: _tabController),
                  const SizedBox(height: AppUiTokens.space16),
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      if (_tabController.index == 0) {
                        return _ActiveListSection(
                          controller: controller,
                          productSearchController: _productSearchController,
                          availableWidth: constraints.maxWidth,
                          onCreatePressed: _navigateToCreate,
                        );
                      }

                      return _ArchiveSection(
                        controller: controller,
                        archiveSearchController: _archiveSearchController,
                        availableWidth: constraints.maxWidth,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiyat Listesi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppUiTokens.space4),
            Text(
              'Aktif fiyat listesini yönetin veya arşive göz atın.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
          ],
        );

        final createButton = SizedBox(
          height: 44,
          child: FilledButton.icon(
            onPressed: onCreatePressed,
            style: AppInteractiveTheme.filledButtonStyle(
              FilledButton.styleFrom(
                backgroundColor: ColorName.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppUiTokens.space16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Yeni Fiyat Listesi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              const SizedBox(height: AppUiTokens.space16),
              createButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            createButton,
          ],
        );
      },
    );
  }
}

class _SectionTabBar extends StatelessWidget {
  const _SectionTabBar({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppUiTokens.border),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppUiTokens.textPrimary,
        unselectedLabelColor: AppUiTokens.textSecondary,
        indicatorColor: ColorName.primary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Aktif Liste'),
          Tab(text: 'Arşiv'),
        ],
      ),
    );
  }
}

class _ActiveListSection extends StatelessWidget {
  const _ActiveListSection({
    required this.controller,
    required this.productSearchController,
    required this.availableWidth,
    required this.onCreatePressed,
  });

  final PriceListController controller;
  final TextEditingController productSearchController;
  final double availableWidth;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeList = controller.activePriceList.value;

      if (activeList == null) {
        return PanelSurface(
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiTokens.space24,
            vertical: AppUiTokens.space32,
          ),
          child: Center(
            child: AppEmptyState(
              message: 'Aktif fiyat listesi bulunmuyor.',
              icon: Icons.list_alt_outlined,
              actionLabel: 'Yeni Fiyat Listesi',
              onAction: onCreatePressed,
              actionFilled: true,
            ),
          ),
        );
      }

      void openAddProduct() => showPriceListProductFormDialog(
            controller: controller,
            priceListId: activeList.id,
          );

      final showProductSearch = controller.activeItems.isNotEmpty ||
          controller.hasActiveProductFilters;

      return PanelSurface(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppUiTokens.space16),
              child: PriceListActiveSummary(
                controller: controller,
                title: activeList.title,
                effectiveDate: activeList.effectiveDate,
                onEdit: () => Get.toNamed<void>(
                  AppRoutes.priceListEdit.pathForId(activeList.id),
                ),
                onAddProduct: openAddProduct,
                onExport: controller.exportToExcel,
              ),
            ),
            if (showProductSearch) ...[
              const Divider(height: 1, color: AppUiTokens.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppUiTokens.space16,
                  AppUiTokens.space12,
                  AppUiTokens.space16,
                  AppUiTokens.space8,
                ),
                child: PriceListProductFilters(
                  controller: controller,
                  searchController: productSearchController,
                ),
              ),
            ],
            PriceListProductsTable(
              controller: controller,
              items: controller.activeItems.toList(),
              readOnly: false,
              availableWidth: availableWidth,
              onEmptyAction: openAddProduct,
              emptyActionLabel: 'Ürün Ekle',
              onEdit: (item) => showPriceListProductFormDialog(
                controller: controller,
                priceListId: activeList.id,
                existingItem: item,
              ),
              onDelete: (item) => controller.deleteItem(item.id),
            ),
          ],
        ),
      );
    });
  }
}

class _ArchiveSection extends StatelessWidget {
  const _ArchiveSection({
    required this.controller,
    required this.archiveSearchController,
    required this.availableWidth,
  });

  final PriceListController controller;
  final TextEditingController archiveSearchController;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppUiTokens.space16,
              AppUiTokens.space16,
              AppUiTokens.space16,
              AppUiTokens.space8,
            ),
            child: PriceListArchiveFilters(
              controller: controller,
              searchController: archiveSearchController,
            ),
          ),
          Obx(
            () => PriceListArchiveTable(
              controller: controller,
              lists: controller.archivedLists.toList(),
              isLoading: controller.isLoading.value,
              hasActiveFilters: controller.hasActiveArchiveFilters,
              availableWidth: availableWidth,
            ),
          ),
        ],
      ),
    );
  }
}
