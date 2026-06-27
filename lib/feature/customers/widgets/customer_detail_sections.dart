import 'package:Ok/feature/customers/controllers/customer_detail_controller.dart';
import 'package:Ok/feature/customers/widgets/customer_contact_form_dialog.dart';
import 'package:Ok/feature/customers/widgets/customer_contacts_tab.dart';
import 'package:Ok/feature/customers/widgets/customer_due_records_tab.dart';
import 'package:Ok/feature/customers/widgets/customer_meetings_tab.dart';
import 'package:Ok/feature/customers/widgets/customer_notes_tab.dart';
import 'package:Ok/feature/customers/widgets/customer_price_offers_tab.dart';
import 'package:Ok/feature/customers/widgets/customer_reminders_tab.dart';
import 'package:Ok/feature/customers/widgets/customer_scrap_quality_tab.dart';
import 'package:Ok/product/init/theme/app_interactive_theme.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:gen/gen.dart';
import 'package:get/get.dart';

class CustomerDetailSections extends StatelessWidget {
  const CustomerDetailSections({
    required this.controller,
    super.key,
  });

  final CustomerDetailController controller;

  static const _sections = [
    _SectionDef(
      label: 'Teklifler',
      icon: Icons.request_quote_outlined,
      actionLabel: 'Fiyat Teklifi Oluştur',
      route: AppRoutes.priceOffersNew,
    ),
    _SectionDef(
      label: 'Görüşmeler',
      icon: Icons.groups_outlined,
      actionLabel: 'Görüşme Ekle',
      route: AppRoutes.meetingsNew,
    ),
    _SectionDef(
      label: 'Alacaklar',
      icon: Icons.account_balance_wallet_outlined,
      actionLabel: 'Vade Kaydı Ekle',
      route: AppRoutes.dueTrackingNew,
    ),
    _SectionDef(
      label: 'Hatırlatıcılar',
      icon: Icons.notifications_outlined,
      actionLabel: 'Hatırlatıcı Ekle',
      route: AppRoutes.remindersNew,
    ),
    _SectionDef(
      label: 'Notlar',
      icon: Icons.sticky_note_2_outlined,
      actionLabel: 'Not Ekle',
      route: AppRoutes.notesNew,
    ),
    _SectionDef(
      label: 'Hurdalar',
      icon: Icons.recycling_outlined,
      actionLabel: 'Hurda Kaydı Ekle',
      route: AppRoutes.scrapQualityNew,
    ),
    _SectionDef(
      label: 'Yetkili Kişiler',
      icon: Icons.contacts_outlined,
      actionLabel: 'Yeni Yetkili Ekle',
      isContactAction: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;
      final section = _sections[selectedIndex];

      return PanelSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionNav(
              controller: controller,
              sections: _sections,
              selectedIndex: selectedIndex,
            ),
            const Divider(height: 1),
            _SectionContentArea(
              controller: controller,
              section: section,
              selectedIndex: selectedIndex,
            ),
          ],
        ),
      );
    });
  }
}

class _SectionDef {
  const _SectionDef({
    required this.label,
    required this.icon,
    this.actionLabel,
    this.route,
    this.isContactAction = false,
  });

  final String label;
  final IconData icon;
  final String? actionLabel;
  final AppRoutes? route;
  final bool isContactAction;
}

class _SectionNav extends StatelessWidget {
  const _SectionNav({
    required this.controller,
    required this.sections,
    required this.selectedIndex,
  });

  final CustomerDetailController controller;
  final List<_SectionDef> sections;
  final int selectedIndex;

  int _countForIndex(int index) {
    return switch (index) {
      0 => controller.priceOffers.length,
      1 => controller.meetings.length,
      2 => controller.dueRecords.length,
      3 => controller.reminders.length,
      4 => controller.notes.length,
      5 => controller.scrapQualityRecords.length,
      6 => controller.contacts.length,
      _ => 0,
    };
  }

  bool _isLoaded(int index) => controller.selectedTabIndex.value == index ||
      switch (index) {
        0 => controller.priceOffers.isNotEmpty,
        1 => controller.meetings.isNotEmpty,
        2 => controller.dueRecords.isNotEmpty,
        3 => controller.reminders.isNotEmpty,
        4 => controller.notes.isNotEmpty,
        5 => controller.scrapQualityRecords.isNotEmpty,
        6 => controller.contacts.isNotEmpty,
        _ => false,
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppUiTokens.space12,
        vertical: AppUiTokens.space12,
      ),
      child: Row(
        children: [
          for (var index = 0; index < sections.length; index++) ...[
            if (index > 0) const SizedBox(width: AppUiTokens.space8),
            _NavTile(
              label: sections[index].label,
              icon: sections[index].icon,
              selected: selectedIndex == index,
              count: _isLoaded(index) ? _countForIndex(index) : null,
              onTap: () => controller.changeTab(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppUiTokens.accentSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
            border: Border.all(
              color: selected
                  ? ColorName.primary.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppUiTokens.space12,
            vertical: AppUiTokens.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? ColorName.primary : AppUiTokens.textSecondary,
              ),
              const SizedBox(width: AppUiTokens.space8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppUiTokens.textPrimary
                      : AppUiTokens.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AppUiTokens.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? ColorName.primary.withValues(alpha: 0.12)
                        : AppUiTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected
                          ? ColorName.primary
                          : AppUiTokens.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionContentArea extends StatelessWidget {
  const _SectionContentArea({
    required this.controller,
    required this.section,
    required this.selectedIndex,
  });

  final CustomerDetailController controller;
  final _SectionDef section;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppUiTokens.space16,
            AppUiTokens.space16,
            AppUiTokens.space16,
            AppUiTokens.space12,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 480;

              final title = Text(
                section.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppUiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              );

              final action = section.actionLabel == null
                  ? null
                  : FilledButton.icon(
                      onPressed: () {
                        if (section.isContactAction) {
                          showCustomerContactFormDialog(
                            controller: controller,
                          );
                          return;
                        }
                        if (section.route != null) {
                          controller.openCreateForm(section.route!);
                        }
                      },
                      style: AppInteractiveTheme.filledButtonStyle(
                        FilledButton.styleFrom(
                          backgroundColor: ColorName.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppUiTokens.space16,
                            vertical: AppUiTokens.space12,
                          ),
                        ),
                      ),
                      icon: Icon(
                        section.isContactAction
                            ? Icons.person_add_outlined
                            : Icons.add_rounded,
                        size: 18,
                      ),
                      label: Text(section.actionLabel!),
                    );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    title,
                    if (action != null) ...[
                      const SizedBox(height: AppUiTokens.space12),
                      action,
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  if (action != null) action,
                ],
              );
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppUiTokens.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppUiTokens.space16,
            AppUiTokens.space16,
            AppUiTokens.space16,
            AppUiTokens.space16,
          ),
          child: _buildSectionContent(),
        ),
      ],
    );
  }

  Widget _buildSectionContent() {
    return switch (selectedIndex) {
      0 => CustomerPriceOffersTab(controller: controller),
      1 => CustomerMeetingsTab(controller: controller),
      2 => CustomerDueRecordsTab(controller: controller),
      3 => CustomerRemindersTab(controller: controller),
      4 => CustomerNotesTab(controller: controller),
      5 => CustomerScrapQualityTab(controller: controller),
      6 => CustomerContactsTab(controller: controller),
      _ => const SizedBox.shrink(),
    };
  }
}
