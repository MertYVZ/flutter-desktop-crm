import 'package:Ok/feature/scrap_quality/controllers/scrap_quality_controller.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrapQualityAnalyticsPanel extends StatelessWidget {
  const ScrapQualityAnalyticsPanel({
    required this.controller,
    super.key,
  });

  final ScrapQualityController controller;

  static const _spacing = AppUiTokens.space12;
  static const _cardMinWidth = 220.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final analytics = controller.analytics.value;

      final items = [
        _AnalyticsCardData(
          label: 'En çok hurda bulunan müşteri',
          value: analytics.topFoundCustomer,
          icon: Icons.person_search_outlined,
        ),
        _AnalyticsCardData(
          label: 'En çok hurda alınan müşteri',
          value: analytics.topPurchasedCustomer,
          icon: Icons.verified_outlined,
        ),
        _AnalyticsCardData(
          label: 'En çok kayıp yaşanan müşteri',
          value: analytics.topLostCustomer,
          icon: Icons.warning_amber_outlined,
        ),
        _AnalyticsCardData(
          label: 'En çok çıkan hurda türü',
          value: analytics.topScrapType,
          icon: Icons.category_outlined,
        ),
        _AnalyticsCardData(
          label: 'En çok kayıt olan il',
          value: analytics.topCity,
          icon: Icons.location_city_outlined,
        ),
        _AnalyticsCardData(
          label: 'En yüksek teklif fiyatı',
          value: analytics.highestOfferPrice == null
              ? null
              : '${MoneyUtils.formatAmountInput(analytics.highestOfferPrice!)} TL/KG',
          icon: Icons.arrow_upward_rounded,
        ),
        _AnalyticsCardData(
          label: 'En düşük teklif fiyatı',
          value: analytics.lowestOfferPrice == null
              ? null
              : '${MoneyUtils.formatAmountInput(analytics.lowestOfferPrice!)} TL/KG',
          icon: Icons.arrow_downward_rounded,
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1200
              ? 4
              : constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth >= 520
                      ? 2
                      : 1;
          final cardWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - (_spacing * (columns - 1))) / columns;

          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            children: items
                .map(
                  (item) => SizedBox(
                    width: cardWidth < _cardMinWidth ? constraints.maxWidth : cardWidth,
                    child: _AnalyticsCard(data: item),
                  ),
                )
                .toList(),
          );
        },
      );
    });
  }
}

class _AnalyticsCardData {
  const _AnalyticsCardData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String? value;
  final IconData icon;
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.data});

  final _AnalyticsCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppUiTokens.space16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                data.icon,
                size: 18,
                color: AppUiTokens.textMuted,
              ),
              const SizedBox(width: AppUiTokens.space8),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppUiTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppUiTokens.space12),
          Text(
            data.value ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppUiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
