import 'dart:async';

import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_summary_cards.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_calendar.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_day_detail_panel.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends BaseState<DashboardPage> {
  Size? _lastLoggedViewportSize;

  void _logViewportSize(BuildContext context, BoxConstraints constraints) {
    final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
    if (_lastLoggedViewportSize == viewportSize) {
      return;
    }
    _lastLoggedViewportSize = viewportSize;

    final mediaQuery = MediaQuery.sizeOf(context);
    final windowSize = View.of(context).physicalSize / View.of(context).devicePixelRatio;

    debugPrint(
      '[Dashboard] Viewport: ${viewportSize.width.toStringAsFixed(0)} x '
      '${viewportSize.height.toStringAsFixed(0)} | '
      'MediaQuery: ${mediaQuery.width.toStringAsFixed(0)} x '
      '${mediaQuery.height.toStringAsFixed(0)} | '
      'Window: ${windowSize.width.toStringAsFixed(0)} x '
      '${windowSize.height.toStringAsFixed(0)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DashboardController>(
      viewModel: Get.find<DashboardController>(),
      onModelReady: (controller) => unawaited(_loadDashboard(controller)),
      onPageBuilder: (context, controller) {
        return Obx(() {
          final error = controller.errorMessage.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              _logViewportSize(context, constraints);
              final isCompact = constraints.maxWidth < 960;

              return PanelFormScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (error != null) ...[
                      PanelMessage(message: error),
                      const SizedBox(height: AppUiTokens.space16),
                    ],
                    DashboardSummaryCards(controller: controller),
                    const SizedBox(height: AppUiTokens.space16),
                    if (isCompact) ...[
                      PanelSurface(
                        padding: EdgeInsets.zero,
                        borderRadius:
                            BorderRadius.circular(AppUiTokens.radiusLg),
                        child: DashboardCalendar(controller: controller),
                      ),
                      const SizedBox(height: AppUiTokens.space16),
                      PanelSurface(
                        padding: EdgeInsets.zero,
                        borderRadius:
                            BorderRadius.circular(AppUiTokens.radiusLg),
                        child: DashboardDayDetailPanel(
                          controller: controller,
                          fullWidth: true,
                        ),
                      ),
                    ] else
                      Obx(() {
                        final month = controller.selectedMonth.value;
                        const sidebarWidth = 360.0;

                        return PanelSurface(
                          padding: EdgeInsets.zero,
                          borderRadius:
                              BorderRadius.circular(AppUiTokens.radiusLg),
                          child: LayoutBuilder(
                            builder: (context, panelConstraints) {
                              final calendarWidth =
                                  panelConstraints.maxWidth - sidebarWidth;
                              final splitHeight =
                                  DashboardCalendar.estimatedHeight(
                                width: calendarWidth,
                                month: month,
                              );

                              return SizedBox(
                                height: splitHeight,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: DashboardCalendar(
                                        controller: controller,
                                      ),
                                    ),
                                    SizedBox(
                                      width: sidebarWidth,
                                      child: DashboardDayDetailPanel(
                                        controller: controller,
                                        showLeftBorder: true,
                                        embeddedInSplitView: true,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Future<void> _loadDashboard(DashboardController controller) async {
    await controller.loadDashboard();
    if (controller.selectedDate.value == null) {
      controller.selectDate(DateTime.now());
    }
  }
}
