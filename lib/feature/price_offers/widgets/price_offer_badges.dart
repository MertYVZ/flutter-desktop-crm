import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

typedef PriceOfferBadgeStyle = AppBadgeStyle;

extension OfferTypeBadgeStyle on OfferType {
  PriceOfferBadgeStyle get badgeStyle {
    switch (this) {
      case OfferType.okTeknik:
        return PriceOfferBadgeStyle(
          backgroundColor: AppUiTokens.accentSoft,
          borderColor: ColorName.primary.withValues(alpha: 0.18),
          textColor: ColorName.primaryDark,
        );
      case OfferType.dengTools:
        return const PriceOfferBadgeStyle(
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
          textColor: Color(0xFF1D4ED8),
        );
      case OfferType.vizviz:
        return PriceOfferBadgeStyle(
          backgroundColor: const Color(0xFFF5F3FF),
          borderColor: ColorName.secondary.withValues(alpha: 0.22),
          textColor: const Color(0xFF4338CA),
        );
      case OfferType.general:
        return const PriceOfferBadgeStyle(
          backgroundColor: AppUiTokens.surfaceMuted,
          borderColor: AppUiTokens.border,
          textColor: AppUiTokens.textSecondary,
        );
    }
  }
}

extension PriceOfferStatusBadgeStyle on PriceOfferStatus {
  PriceOfferBadgeStyle get badgeStyle {
    switch (this) {
      case PriceOfferStatus.draft:
        return AppStatusTone.neutral.badgeStyle;
      case PriceOfferStatus.sent:
        return AppStatusTone.info.badgeStyle;
      case PriceOfferStatus.approved:
        return AppStatusTone.success.badgeStyle;
      case PriceOfferStatus.rejected:
        return AppStatusTone.error.badgeStyle;
      case PriceOfferStatus.cancelled:
        return AppStatusTone.warning.badgeStyle;
    }
  }
}

class PriceOfferBadge extends StatelessWidget {
  const PriceOfferBadge({
    required this.label,
    required this.style,
    this.compact = false,
    super.key,
  });

  final String label;
  final PriceOfferBadgeStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: label,
      style: style,
      compact: compact,
    );
  }
}

class PriceOfferTypeBadge extends StatelessWidget {
  const PriceOfferTypeBadge({
    required this.type,
    required this.fallbackLabel,
    this.compact = false,
    super.key,
  });

  final OfferType? type;
  final String fallbackLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = type?.badgeStyle ?? appNeutralBadgeStyle;
    final label = type?.label ?? fallbackLabel;

    return PriceOfferBadge(
      label: label,
      style: style,
      compact: compact,
    );
  }
}

class PriceOfferStatusBadge extends StatelessWidget {
  const PriceOfferStatusBadge({
    required this.status,
    required this.fallbackLabel,
    this.compact = false,
    super.key,
  });

  final PriceOfferStatus? status;
  final String fallbackLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = status?.badgeStyle ?? appNeutralBadgeStyle;
    final label = status?.label ?? fallbackLabel;

    return PriceOfferBadge(
      label: label,
      style: style,
      compact: compact,
    );
  }
}
