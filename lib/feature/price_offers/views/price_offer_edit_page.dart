import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/feature/price_offers/services/legal_text_template_service.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_form.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_items_editor.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/constants/price_offer_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class PriceOfferEditPage extends StatefulWidget {
  const PriceOfferEditPage({super.key});

  @override
  State<PriceOfferEditPage> createState() => _PriceOfferEditPageState();
}

class _PriceOfferEditPageState extends BaseState<PriceOfferEditPage> {
  late final TextEditingController _contactPersonController;
  late final TextEditingController _authorizedPhoneController;
  late final TextEditingController _mobilePhoneController;
  late final TextEditingController _legalTextController;
  late final List<PriceOfferItemFormRow> _itemRows;
  late final LegalTextTemplateService _legalTextTemplateService;

  String? _selectedCustomerId;
  OfferType? _selectedType;
  DateTime? _offerDate;
  PriceOfferStatus? _selectedStatus;
  bool _isLegalTextDirty = true;
  bool _isFormInitialized = false;

  String get _offerId => Get.parameters['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _contactPersonController = TextEditingController();
    _authorizedPhoneController = TextEditingController();
    _mobilePhoneController = TextEditingController();
    _legalTextController = TextEditingController();
    _legalTextTemplateService = Get.find<LegalTextTemplateService>();
    _itemRows = [];
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _authorizedPhoneController.dispose();
    _mobilePhoneController.dispose();
    _legalTextController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _populateForm(PriceOffersController controller) {
    final offer = controller.selectedOffer.value;
    if (offer == null || _isFormInitialized) {
      return;
    }

    _selectedCustomerId = offer.customerId;
    _selectedType = offer.offerType ?? OfferType.general;
    _offerDate = offer.offerDate;
    _selectedStatus = offer.offerStatus ?? PriceOfferStatus.draft;
    _contactPersonController.text = offer.contactPerson;
    _authorizedPhoneController.text = offer.authorizedPhone ?? '';
    _mobilePhoneController.text = offer.mobilePhone ?? '';
    _legalTextController.text = offer.legalText;
    _isLegalTextDirty = true;

    for (final row in _itemRows) {
      row.dispose();
    }
    _itemRows.clear();

    if (offer.items.isEmpty) {
      _itemRows.add(PriceOfferItemFormRow());
    } else {
      for (final item in offer.items) {
        final row = PriceOfferItemFormRow();
        row.populateFromItem(item);
        _itemRows.add(row);
      }
    }

    _isFormInitialized = true;
  }

  Future<void> _handleTypeChanged(OfferType? type) async {
    if (!_isLegalTextDirty && type != null) {
      final text =
          await _legalTextTemplateService.getTemplateByOfferType(type);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedType = type;
        _legalTextController.text = text;
      });
      return;
    }

    setState(() {
      _selectedType = type;
    });
  }

  List<PriceOfferItemFormValidation> _buildItemValidations() {
    return _itemRows
        .map(
          (row) => PriceOfferItemFormValidation(
            productName: row.productNameController.text,
            unitType: row.unitType?.label ?? '',
            quantityText: row.quantityController.text,
            priceText: row.priceController.text,
            currency: row.currency,
          ),
        )
        .toList();
  }

  Future<void> _submit(PriceOffersController controller) async {
    final updated = await controller.updateOffer(
      id: _offerId,
      type: _selectedType,
      offerDate: _offerDate,
      customerId: _selectedCustomerId,
      contactPerson: _contactPersonController.text,
      authorizedPhone: _authorizedPhoneController.text,
      mobilePhone: _mobilePhoneController.text,
      legalText: _legalTextController.text,
      status: _selectedStatus,
      itemValidations: _buildItemValidations(),
    );

    if (updated) {
      await Get.offNamed<void>(
        AppRoutes.priceOffersDetail.pathForId(_offerId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceOffersController>(
      viewModel: Get.find<PriceOffersController>(),
      onModelReady: (controller) {
        _isFormInitialized = false;
        controller.clearMessages();
        controller.loadCustomersForDropdown();
        controller.getOfferById(_offerId).then((loaded) {
          if (!loaded || !mounted) {
            return;
          }

          setState(() {
            _populateForm(controller);
          });
        });
      },
      onPageBuilder: (context, controller) {
        return Obx(() {
          if (controller.isLoading.value &&
              controller.selectedOffer.value == null) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (controller.selectedOffer.value == null) {
            return Center(
              child: Text(
                controller.errorMessage.value ?? PriceOfferMessages.notFound,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppUiTokens.textSecondary,
                    ),
              ),
            );
          }

          if (!_isFormInitialized) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return PanelFormScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PageHeader(
                  title: 'Fiyat Teklifi Düzenle',
                  subtitle: 'Fiyat teklifi bilgilerini güncelleyin.',
                ),
                const SizedBox(height: AppUiTokens.space16),
                Obx(() {
                  final error = controller.errorMessage.value;
                  if (error == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      PanelMessage(message: error),
                      const SizedBox(height: AppUiTokens.space16),
                    ],
                  );
                }),
                PanelSurface(
                  padding: const EdgeInsets.all(AppUiTokens.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PriceOfferForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        selectedType: _selectedType,
                        offerDate: _offerDate,
                        contactPersonController: _contactPersonController,
                        authorizedPhoneController: _authorizedPhoneController,
                        mobilePhoneController: _mobilePhoneController,
                        legalTextController: _legalTextController,
                        itemRows: _itemRows,
                        showStatus: true,
                        selectedStatus: _selectedStatus,
                        onStatusChanged: (value) => setState(() {
                          _selectedStatus = value;
                        }),
                        onCustomerChanged: (value) => setState(() {
                          _selectedCustomerId = value;
                        }),
                        onTypeChanged: _handleTypeChanged,
                        onDateChanged: (value) => setState(() {
                          _offerDate = value;
                        }),
                        onLegalTextChanged: (_) {
                          _isLegalTextDirty = true;
                        },
                      ),
                      const SizedBox(height: AppUiTokens.space24),
                      PriceOfferFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () => Get.offNamed<void>(
                                  AppRoutes.priceOffersDetail.pathForId(
                                    _offerId,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppUiTokens.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: AppUiTokens.space8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiTokens.textSecondary,
              ),
        ),
      ],
    );
  }
}
