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

  static const _cardCount = 6;
  static const _spacing = AppUiTokens.space12;
  static const _fixedCardWidth = 292.0;
  static const _singleRowBreakpoint = 1400.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleRow = constraints.maxWidth >= _singleRowBreakpoint;

        return Obx(() {
          if (controller.isLoadingSummary.value &&
              controller.summary.value == null) {
            return _SummaryCardsLayout(
              useSingleRow: useSingleRow,
              children: List.generate(
                _cardCount,
                (_) => SizedBox(
                  height: 112,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppUiTokens.surfaceMuted,
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.radiusSm),
                      border: Border.all(color: AppUiTokens.border),
                    ),
                  ),
                ),
              ),
            );
          }

          final summary = controller.summary.value;
          if (summary == null) {
            return const SizedBox.shrink();
          }

          return _SummaryCardsLayout(
            useSingleRow: useSingleRow,
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
        });
      },
    );
  }
}

class _SummaryCardsLayout extends StatelessWidget {
  const _SummaryCardsLayout({
    required this.useSingleRow,
    required this.children,
  });

  final bool useSingleRow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (useSingleRow) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: DashboardSummaryCards._spacing),
            Expanded(child: children[i]),
          ],
        ],
      );
    }

    return Wrap(
      spacing: DashboardSummaryCards._spacing,
      runSpacing: DashboardSummaryCards._spacing,
      alignment: WrapAlignment.start,
      children: children
          .map(
            (child) => SizedBox(
              width: DashboardSummaryCards._fixedCardWidth,
              child: child,
            ),
          )
          .toList(),
    );
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
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: InkWell(
          onTap: widget.onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
          hoverColor: color.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppUiTokens.space24,
              vertical: AppUiTokens.space16,
            ),
            decoration: BoxDecoration(
              color: AppUiTokens.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppUiTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: AppUiTokens.space8),
                      Text(
                        '${widget.value}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppUiTokens.textPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                              height: 1,
                            ),
                      ),
                      const SizedBox(height: AppUiTokens.space8),
                      Text(
                        widget.helper,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppUiTokens.textMuted,
                              height: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppUiTokens.space16),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                    border: Border.all(color: color.withValues(alpha: 0.14)),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
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
