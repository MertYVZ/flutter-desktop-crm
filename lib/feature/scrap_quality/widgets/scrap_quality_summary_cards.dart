import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:Ok/product/utility/quantity_utils.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class ScrapQualitySummaryCards extends StatelessWidget {
  const ScrapQualitySummaryCards({
    required this.controller,
    super.key,
  });

  final ScrapQualityController controller;

  static const _spacing = AppUiTokens.space12;
  static const _fixedCardWidth = 292.0;
  static const _singleRowBreakpoint = 1400.0;
  static const _cardHeight = 112.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleRow = constraints.maxWidth >= _singleRowBreakpoint;

        return Obx(() {
          final summary = controller.summary.value;

          return _SummaryCardsLayout(
            useSingleRow: useSingleRow,
            children: [
              _SummaryCard(
                label: 'Toplam Bulunan Hurda',
                value: QuantityUtils.formatKg(summary.totalFoundKg),
                helper: 'Seçili ay toplamı',
                icon: Icons.inventory_2_outlined,
              ),
              _SummaryCard(
                label: 'Satın Alınan Hurda',
                value: QuantityUtils.formatKg(summary.totalPurchasedKg),
                helper: 'Alındı statüsündeki kayıtlar',
                icon: Icons.check_circle_outline_rounded,
                accentColor: const Color(0xFF059669),
              ),
              _SummaryCard(
                label: 'Kaybedilen / Alınamayan',
                value: QuantityUtils.formatKg(summary.totalNotPurchasedKg),
                helper: 'Alınmadı statüsündeki kayıtlar',
                icon: Icons.trending_down_rounded,
                accentColor: const Color(0xFFDC2626),
              ),
              _SummaryCard(
                label: 'Bekleyen / Sonuçlanmamış',
                value: QuantityUtils.formatKg(summary.totalPendingKg),
                helper: 'Bekleyecek ve sonuçlanmadı',
                icon: Icons.hourglass_empty_rounded,
                accentColor: const Color(0xFFF59E0B),
              ),
              _SummaryCard(
                label: 'Ort. Teklif Fiyatı',
                value: summary.averageOfferPrice <= 0
                    ? '—'
                    : '${MoneyUtils.formatAmountInput(summary.averageOfferPrice)} TL/KG',
                helper: summary.totalFoundKg <= 0
                    ? 'Teklif girilen kayıt yok'
                    : 'Alım Oranı: %${summary.purchaseRatePercent.toStringAsFixed(1)}',
                icon: Icons.payments_outlined,
                accentColor: const Color(0xFF2563EB),
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
      return SizedBox(
        height: ScrapQualitySummaryCards._cardHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const SizedBox(width: ScrapQualitySummaryCards._spacing),
              Expanded(child: children[i]),
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: ScrapQualitySummaryCards._spacing,
      runSpacing: ScrapQualitySummaryCards._spacing,
      alignment: WrapAlignment.start,
      children: children
          .map(
            (child) => SizedBox(
              width: ScrapQualitySummaryCards._fixedCardWidth,
              height: ScrapQualitySummaryCards._cardHeight,
              child: child,
            ),
          )
          .toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? ColorName.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space16,
        vertical: AppUiTokens.space12,
      ),
      decoration: BoxDecoration(
        color: AppUiTokens.surface,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        border: Border.all(color: AppUiTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
                SizedBox(
                  height: 28,
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppUiTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppUiTokens.space4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: -0.4,
                    height: 1,
                  ),
                ),
                const SizedBox(height: AppUiTokens.space4),
                Text(
                  helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppUiTokens.textMuted,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppUiTokens.space12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
              border: Border.all(color: color.withValues(alpha: 0.14)),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
