import 'dart:async';

import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_calendar.dart';
import 'package:Ok/feature/dashboard/widgets/dashboard_day_detail_panel.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends BaseState<DashboardPage> {
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
              final isCompact = constraints.maxWidth < 960;
              final boardHeight = _boardHeight(constraints);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null) ...[
                    PanelMessage(message: error),
                    const SizedBox(height: AppUiTokens.space16),
                  ],
                  if (isCompact)
                    _CompactDashboardBoard(
                      controller: controller,
                    )
                  else
                    PanelSurface(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                      child: SizedBox(
                        height: boardHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: DashboardCalendar(
                                controller: controller,
                                expanded: true,
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppUiTokens.border,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 330,
                              child: DashboardDayDetailPanel(
                                controller: controller,
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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

  double _boardHeight(BoxConstraints constraints) {
    if (!constraints.maxHeight.isFinite) {
      return 720;
    }

    if (constraints.maxHeight < 620) {
      return 620;
    }

    return constraints.maxHeight;
  }
}

class _CompactDashboardBoard extends StatelessWidget {
  const _CompactDashboardBoard({
    required this.controller,
  });

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelSurface(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            child: DashboardCalendar(controller: controller),
          ),
          const SizedBox(height: AppUiTokens.space16),
          PanelSurface(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            child: DashboardDayDetailPanel(
              controller: controller,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
