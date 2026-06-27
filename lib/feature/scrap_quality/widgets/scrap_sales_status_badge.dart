import 'package:Ok/feature/scrap_quality/models/scrap_sales_status.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:flutter/material.dart';

class ScrapSalesStatusBadge extends StatelessWidget {
  const ScrapSalesStatusBadge({
    required this.status,
    this.compact = true,
    super.key,
  });

  final ScrapSalesStatus? status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final resolved = status;
    if (resolved == null) {
      return const AppStatusBadge(
        label: '—',
        style: appNeutralBadgeStyle,
        compact: true,
      );
    }

    return AppStatusBadge(
      label: resolved.label,
      style: _styleForStatus(resolved),
      compact: compact,
    );
  }

  AppBadgeStyle _styleForStatus(ScrapSalesStatus status) {
    switch (status) {
      case ScrapSalesStatus.purchased:
        return AppStatusTone.success.badgeStyle;
      case ScrapSalesStatus.notPurchased:
        return AppStatusTone.error.badgeStyle;
      case ScrapSalesStatus.unresolved:
        return AppStatusTone.neutral.badgeStyle;
      case ScrapSalesStatus.waiting:
        return AppStatusTone.warning.badgeStyle;
    }
  }
}
