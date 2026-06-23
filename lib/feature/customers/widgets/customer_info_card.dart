import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/widgets/app_status_badge.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:Ok/product/widgets/status_badge_styles.dart';
import 'package:flutter/material.dart';

class CustomerInfoCard extends StatelessWidget {
  const CustomerInfoCard({
    required this.customer,
    super.key,
  });

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final type = CustomerTypeX.fromValue(customer.type);
    final status = CustomerStatusX.fromValue(customer.status);

    return PanelSurface(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;

          final left = [
            _DetailRow(label: 'Müşteri tipi', value: type?.label ?? '-'),
            _DetailRow(label: 'Telefon', value: customer.phone ?? '-'),
            _DetailRow(label: 'E-posta', value: customer.email ?? '-'),
          ];

          final right = [
            _DetailRow(label: 'Şehir', value: customer.city ?? '-'),
            _DetailRow(label: 'Ülke', value: customer.country ?? '-'),
            _DetailRow(label: 'Adres', value: customer.address ?? '-'),
            _DetailRow(
              label: 'Durum',
              valueWidget: status == null
                  ? null
                  : AppStatusBadge(
                      label: status.label,
                      style: status.badgeStyle,
                      compact: true,
                    ),
              value: status?.label ?? '-',
            ),
          ];

          if (isCompact) {
            return Column(
              children: [
                ...left,
                ...right,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: left)),
              const SizedBox(width: AppUiTokens.space24),
              Expanded(child: Column(children: right)),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppUiTokens.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
            ),
          ),
          if (valueWidget != null)
            valueWidget!
          else
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppUiTokens.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.45,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
