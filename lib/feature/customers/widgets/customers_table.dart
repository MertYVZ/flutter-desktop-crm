import 'package:Ok/feature/customers/controllers/customers_controller.dart';
import 'package:Ok/feature/customers/models/customer_status.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class CustomersTable extends StatelessWidget {
  const CustomersTable({
    required this.controller,
    this.availableWidth,
    super.key,
  });

  final CustomersController controller;
  final double? availableWidth;

  static const _headingStyle = TextStyle(
    color: AppUiTokens.textSecondary,
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const _dataStyle = TextStyle(
    color: AppUiTokens.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const _headerRowHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppUiTokens.space24,
      ),
      child: Obx(() {
      final customers = controller.customers;
      final isLoading = controller.isListLoading.value;
      final isDeleting = controller.isDeleting.value;
      final deletingId = controller.deletingCustomerId.value;

      if (isLoading && customers.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppUiTokens.space24,
            vertical: AppUiTokens.space24,
          ),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (customers.isEmpty) {
        final message = controller.hasActiveFilters
            ? 'Kriterlere uygun müşteri bulunamadı.'
            : 'Henüz müşteri kaydı bulunmuyor.';

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiTokens.space24,
            vertical: AppUiTokens.space24,
          ),
          child: Center(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppUiTokens.textSecondary,
                  ),
            ),
          ),
        );
      }

      final table = DataTable(
        headingRowHeight: _headerRowHeight,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 52,
        headingTextStyle: _headingStyle,
        dataTextStyle: _dataStyle,
        headingRowColor: WidgetStateProperty.all(Colors.transparent),
        dividerThickness: 1,
        columnSpacing: AppUiTokens.space24,
        horizontalMargin: AppUiTokens.space24,
        columns: const [
          DataColumn(label: Text('Müşteri adı')),
          DataColumn(label: Text('Tipi')),
          DataColumn(label: Text('Şehir')),
          DataColumn(label: Text('Telefon')),
          DataColumn(label: Text('E-posta')),
          DataColumn(label: Text('Durum')),
          DataColumn(label: Text('İşlem')),
        ],
        rows: customers
            .map(
              (customer) => _buildRow(
                customer,
                isDeleting: isDeleting && deletingId == customer.id,
              ),
            )
            .toList(),
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final minTableWidth = availableWidth ?? constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _headerRowHeight,
                child: ColoredBox(color: AppUiTokens.surfaceMuted),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minTableWidth,
                  ),
                  child: table,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppUiTokens.surface.withValues(alpha: 0.72),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
      }),
    );
  }

  DataRow _buildRow(
    Customer customer, {
    required bool isDeleting,
  }) {
    final type = CustomerTypeX.fromValue(customer.type);
    final status = CustomerStatusX.fromValue(customer.status);

    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              customer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _dataStyle,
            ),
          ),
        ),
        DataCell(Text(type?.label ?? '-', style: _dataStyle)),
        DataCell(Text(customer.city ?? '-', style: _dataStyle)),
        DataCell(Text(customer.phone ?? '-', style: _dataStyle)),
        DataCell(Text(customer.email ?? '-', style: _dataStyle)),
        DataCell(Text(status?.label ?? '-', style: _dataStyle)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                tooltip: 'Detay',
                icon: Icons.visibility_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.customersDetail.pathForId(customer.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Düzenle',
                icon: Icons.edit_outlined,
                onPressed: isDeleting
                    ? null
                    : () => Get.toNamed<void>(
                          AppRoutes.customersEdit.pathForId(customer.id),
                        ),
              ),
              _ActionIconButton(
                tooltip: 'Sil',
                icon: Icons.delete_outline_rounded,
                color: ColorName.error,
                isLoading: isDeleting,
                onPressed: isDeleting
                    ? null
                    : () async {
                        final deleted =
                            await controller.deleteCustomer(customer.id);
                        if (deleted) {
                          await controller.searchAndFilterCustomers();
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isLoading = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      mouseCursor:
          onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color ?? AppUiTokens.textSecondary,
              ),
            )
          : Icon(icon, size: 18, color: color ?? AppUiTokens.textSecondary),
      style: AppInteractiveTheme.iconButtonStyle(
        IconButton.styleFrom(
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
