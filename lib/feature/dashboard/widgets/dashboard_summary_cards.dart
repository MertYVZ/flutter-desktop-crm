import 'package:Ok/feature/dashboard/controllers/dashboard_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

final class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({
    required this.controller,
    super.key,
  });

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSummary.value &&
          controller.summary.value == null) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                _crossAxisCountForWidth(constraints.maxWidth);
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppUiTokens.space12,
              crossAxisSpacing: AppUiTokens.space12,
              childAspectRatio: _aspectRatioForCount(crossAxisCount),
              children: List.generate(
                6,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: AppUiTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                    border: Border.all(color: AppUiTokens.border),
                  ),
                ),
              ),
            );
          },
        );
      }

      final summary = controller.summary.value;
      if (summary == null) {
        return const SizedBox.shrink();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _crossAxisCountForWidth(constraints.maxWidth);

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppUiTokens.space12,
            crossAxisSpacing: AppUiTokens.space12,
            childAspectRatio: _aspectRatioForCount(crossAxisCount),
            children: [
              _SummaryCard(
                label: 'Toplam Müşteri',
                value: summary.totalCustomers,
                icon: Icons.people_outline_rounded,
                helper: 'Aktif müşteri kayıtları',
                onTap: controller.navigateToCustomers,
              ),
              _SummaryCard(
                label: 'Bekleyen Vadeler',
                value: summary.pendingDueCount,
                icon: Icons.schedule_outlined,
                helper: 'Takip bekleyen vadeler',
                accentColor: const Color(0xFF059669),
                onTap: controller.navigateToDueTracking,
              ),
              _SummaryCard(
                label: 'Gecikmiş Vadeler',
                value: summary.overdueDueCount,
                icon: Icons.warning_amber_outlined,
                helper: 'Aksiyon gereken vadeler',
                accentColor: const Color(0xFFDC2626),
                onTap: controller.navigateToDueTracking,
              ),
              _SummaryCard(
                label: 'Bu Ayki Görüşmeler',
                value: summary.currentMonthMeetingsCount,
                icon: Icons.forum_outlined,
                helper: 'Aylık müşteri temasları',
                accentColor: const Color(0xFF2563EB),
                onTap: controller.navigateToMeetings,
              ),
              _SummaryCard(
                label: 'Bu Ayki Fiyat Teklifleri',
                value: summary.currentMonthPriceOffersCount,
                icon: Icons.request_quote_outlined,
                helper: 'Bu ay oluşturulan teklifler',
                accentColor: const Color(0xFFF59E0B),
                onTap: controller.navigateToPriceOffers,
              ),
              _SummaryCard(
                label: 'Taslak/Gönderilmiş Teklifler',
                value: summary.openPriceOffersCount,
                icon: Icons.description_outlined,
                helper: 'Açık teklif iş yükü',
                accentColor: const Color(0xFF7C3AED),
                onTap: controller.navigateToPriceOffers,
              ),
            ],
          );
        },
      );
    });
  }

  int _crossAxisCountForWidth(double width) {
    if (width >= 1180) {
      return 6;
    }
    if (width >= 760) {
      return 3;
    }
    return 2;
  }

  double _aspectRatioForCount(int crossAxisCount) {
    switch (crossAxisCount) {
      case 6:
        return 2.35;
      case 3:
        return 2.75;
      default:
        return 2.1;
    }
  }
}

class _SummaryCard extends StatefulWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.helper,
    this.accentColor,
  });

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback onTap;
  final String helper;
  final Color? accentColor;

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? ColorName.primary;
    final borderColor =
        _isHovered ? color.withValues(alpha: 0.35) : AppUiTokens.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        child: InkWell(
          onTap: widget.onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
          hoverColor: color.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppUiTokens.space12,
              vertical: AppUiTokens.space8,
            ),
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: _isHovered ? 0.07 : 0.04),
                  blurRadius: _isHovered ? 18 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppUiTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: AppUiTokens.space4),
                      Text(
                        '${widget.value}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppUiTokens.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                  height: 1,
                                ),
                      ),
                      const SizedBox(height: AppUiTokens.space4),
                      Text(
                        widget.helper,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppUiTokens.textMuted,
                              height: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppUiTokens.space8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                    border: Border.all(color: color.withValues(alpha: 0.14)),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
