import 'package:Ok/feature/import/controllers/import_controller.dart';
import 'package:Ok/feature/import/widgets/import_filters.dart';
import 'package:Ok/feature/import/widgets/import_table.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class ImportListPage extends StatefulWidget {
  const ImportListPage({super.key});

  @override
  State<ImportListPage> createState() => _ImportListPageState();
}

class _ImportListPageState extends BaseState<ImportListPage> {
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
    return BaseView<ImportController>(
      viewModel: Get.find<ImportController>(),
      onModelReady: (controller) {
        controller.searchAndFilterImports();
      },
      onPageBuilder: (context, controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return PanelFormScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageHeader(
                    onCreatePressed: () =>
                        Get.toNamed<void>(AppRoutes.importsNew.value),
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
                          child: ImportFilters(
                            controller: controller,
                            searchController: _searchController,
                          ),
                        ),
                        ImportTable(
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
    required this.onCreatePressed,
  });

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İthalat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppUiTokens.space8),
            Text(
              'İthalat kayıtlarını görüntüleyin, arayın ve yönetin.',
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
              'Yeni İthalat',
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
