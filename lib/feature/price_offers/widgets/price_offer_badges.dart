import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';

class PriceOfferBadgeStyle {
  const PriceOfferBadgeStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}

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
        return const PriceOfferBadgeStyle(
          backgroundColor: Color(0xFFF3F4F6),
          borderColor: AppUiTokens.borderStrong,
          textColor: AppUiTokens.textSecondary,
        );
      case PriceOfferStatus.sent:
        return PriceOfferBadgeStyle(
          backgroundColor: const Color(0xFFEFF6FF),
          borderColor: ColorName.info.withValues(alpha: 0.22),
          textColor: const Color(0xFF2563EB),
        );
      case PriceOfferStatus.approved:
        return PriceOfferBadgeStyle(
          backgroundColor: const Color(0xFFECFDF5),
          borderColor: ColorName.success.withValues(alpha: 0.22),
          textColor: const Color(0xFF047857),
        );
      case PriceOfferStatus.rejected:
        return PriceOfferBadgeStyle(
          backgroundColor: const Color(0xFFFEF2F2),
          borderColor: ColorName.error.withValues(alpha: 0.22),
          textColor: const Color(0xFFDC2626),
        );
      case PriceOfferStatus.cancelled:
        return PriceOfferBadgeStyle(
          backgroundColor: const Color(0xFFFFFBEB),
          borderColor: ColorName.warning.withValues(alpha: 0.28),
          textColor: const Color(0xFFB45309),
        );
    }
  }
}

const _neutralBadgeStyle = PriceOfferBadgeStyle(
  backgroundColor: AppUiTokens.surfaceMuted,
  borderColor: AppUiTokens.border,
  textColor: AppUiTokens.textSecondary,
);

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
    final horizontalPadding =
        compact ? AppUiTokens.space8 : AppUiTokens.space12;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.borderColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppUiTokens.space4,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: style.textColor,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : null,
              ),
        ),
      ),
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
    final style = type?.badgeStyle ?? _neutralBadgeStyle;
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
    final style = status?.badgeStyle ?? _neutralBadgeStyle;
    final label = status?.label ?? fallbackLabel;

    return PriceOfferBadge(
      label: label,
      style: style,
      compact: compact,
    );
  }
}
