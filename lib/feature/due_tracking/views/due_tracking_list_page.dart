import 'package:Ok/feature/due_tracking/controllers/due_tracking_controller.dart';
import 'package:Ok/feature/due_tracking/widgets/due_tracking_filters.dart';
import 'package:Ok/feature/due_tracking/widgets/due_tracking_table.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class DueTrackingListPage extends StatefulWidget {
  const DueTrackingListPage({super.key});

  @override
  State<DueTrackingListPage> createState() => _DueTrackingListPageState();
}

class _DueTrackingListPageState extends BaseState<DueTrackingListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DueTrackingController>(
      viewModel: Get.find<DueTrackingController>(),
      onModelReady: (controller) {
        controller.searchAndFilterDueRecords();
      },
      onPageBuilder: (context, controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return PanelFormScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageHeader(
                    controller: controller,
                    onCreatePressed: () =>
                        Get.toNamed<void>(AppRoutes.dueTrackingNew.value),
                    onExportPressed: () => controller.exportToExcel(),
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
                  PanelSurface(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppUiTokens.space24,
                            AppUiTokens.space16,
                            AppUiTokens.space24,
                            AppUiTokens.space8,
                          ),
                          child: DueTrackingFilters(
                            controller: controller,
                            searchController: _searchController,
                          ),
                        ),
                        DueTrackingTable(
                          controller: controller,
                          availableWidth: constraints.maxWidth,
                        ),
                      ],
                    ),
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
  const _PageHeader({
    required this.controller,
    required this.onCreatePressed,
    required this.onExportPressed,
  });

  final DueTrackingController controller;
  final VoidCallback onCreatePressed;
  final VoidCallback onExportPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vade Takip',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppUiTokens.space8),
            Text(
              'Müşteri vade kayıtlarını görüntüleyin, arayın ve yönetin.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
          ],
        );

        final exportButton = Obx(
          () => SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: controller.isExporting.value ? null : onExportPressed,
              style: AppInteractiveTheme.outlinedButtonStyle(
                OutlinedButton.styleFrom(
                  foregroundColor: AppUiTokens.textPrimary,
                  side: const BorderSide(color: AppUiTokens.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUiTokens.space16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                  ),
                ),
              ),
              icon: controller.isExporting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download_outlined, size: 18),
              label: const Text(
                'Excel\'e Aktar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
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
              'Yeni Kayıt',
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
              const SizedBox(height: AppUiTokens.space8),
              exportButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            exportButton,
            const SizedBox(width: AppUiTokens.space8),
            createButton,
          ],
        );
      },
    );
  }
}
