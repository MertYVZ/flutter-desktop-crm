import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/services/legal_text_template_service.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_form.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_items_editor.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:Ok/product/widgets/panel/panel_form_scroll_view.dart';
import 'package:Ok/product/widgets/panel/panel_message.dart';
import 'package:Ok/product/widgets/panel/panel_surface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class PriceOfferCreatePage extends StatefulWidget {
  const PriceOfferCreatePage({super.key});

  @override
  State<PriceOfferCreatePage> createState() => _PriceOfferCreatePageState();
}

class _PriceOfferCreatePageState extends BaseState<PriceOfferCreatePage> {
  late final TextEditingController _contactPersonController;
  late final TextEditingController _authorizedPhoneController;
  late final TextEditingController _mobilePhoneController;
  late final TextEditingController _legalTextController;
  late final List<PriceOfferItemFormRow> _itemRows;
  late final LegalTextTemplateService _legalTextTemplateService;

  String? _selectedCustomerId;
  OfferType? _selectedType;
  DateTime? _offerDate;
  bool _isLegalTextDirty = false;

  @override
  void initState() {
    super.initState();
    _contactPersonController = TextEditingController();
    _authorizedPhoneController = TextEditingController();
    _mobilePhoneController = TextEditingController();
    _legalTextTemplateService = Get.find<LegalTextTemplateService>();
    _selectedType = OfferType.general;
    _offerDate = AppDateUtils.normalizeDate(DateTime.now());
    _legalTextController = TextEditingController();
    _itemRows = [PriceOfferItemFormRow()];
    _loadInitialLegalText();
  }

  Future<void> _loadInitialLegalText() async {
    final text = await _legalTextTemplateService.getTemplateByOfferType(
      OfferType.general,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _legalTextController.text = text;
    });
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
    final id = await controller.createOffer(
      type: _selectedType,
      offerDate: _offerDate,
      customerId: _selectedCustomerId,
      contactPerson: _contactPersonController.text,
      authorizedPhone: _authorizedPhoneController.text,
      mobilePhone: _mobilePhoneController.text,
      legalText: _legalTextController.text,
      itemValidations: _buildItemValidations(),
    );

    if (id != null) {
      await Get.offNamed<void>(AppRoutes.priceOffersDetail.pathForId(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceOffersController>(
      viewModel: Get.find<PriceOffersController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadCustomersForDropdown();
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PageHeader(
                title: 'Yeni Fiyat Teklifi',
                subtitle: 'Yeni fiyat teklifi oluşturun.',
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
                    Obx(
                      () => PriceOfferForm(
                        customers: controller.customers.toList(),
                        selectedCustomerId: _selectedCustomerId,
                        selectedType: _selectedType,
                        offerDate: _offerDate,
                        contactPersonController: _contactPersonController,
                        authorizedPhoneController: _authorizedPhoneController,
                        mobilePhoneController: _mobilePhoneController,
                        legalTextController: _legalTextController,
                        itemRows: _itemRows,
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
                    ),
                    const SizedBox(height: AppUiTokens.space24),
                    Obx(
                      () => PriceOfferFormActions(
                        isSaving: controller.isSaving.value,
                        onSave: controller.isSaving.value ||
                                controller.customers.isEmpty
                            ? null
                            : () => _submit(controller),
                        onCancel: controller.isSaving.value
                            ? () {}
                            : () =>
                                Get.offNamed<void>(AppRoutes.priceOffers.value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
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
