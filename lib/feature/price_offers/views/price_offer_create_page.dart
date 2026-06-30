import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/price_offers/controllers/price_offers_controller.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_discount_type.dart';
import 'package:Ok/feature/price_offers/services/legal_text_template_service.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_form.dart';
import 'package:Ok/feature/price_offers/widgets/price_offer_items_editor.dart';
import 'package:Ok/product/init/theme/app_ui_tokens.dart';
import 'package:Ok/product/navigation/app_pages.dart';
import 'package:Ok/product/navigation/app_route_args.dart';
import 'package:Ok/product/state/base/state/base_state.dart';
import 'package:Ok/product/state/base/view/base_view.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:Ok/product/widgets/panel/panel_form_page_header.dart';
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
  late final TextEditingController _authorizedPhoneController;
  late final TextEditingController _mobilePhoneController;
  late final TextEditingController _legalTextController;
  late final TextEditingController _discountPercentageController;
  late final TextEditingController _discountAmountController;
  late final List<PriceOfferItemFormRow> _itemRows;
  late final LegalTextTemplateService _legalTextTemplateService;

  String? _selectedCustomerId;
  CustomerContactItem? _selectedContact;
  OfferType? _selectedType;
  DateTime? _offerDate;
  DateTime? _validityDate;
  PriceOfferDiscountType _discountType = PriceOfferDiscountType.none;
  PriceOfferCurrencyType? _discountCurrency;
  bool _isLegalTextDirty = false;
  bool _isValidityDateDirty = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = AppRouteArgs.readCustomerId();
    _authorizedPhoneController = TextEditingController();
    _mobilePhoneController = TextEditingController();
    _legalTextTemplateService = Get.find<LegalTextTemplateService>();
    _selectedType = OfferType.general;
    _offerDate = AppDateUtils.normalizeDate(DateTime.now());
    _validityDate = AppDateUtils.addDays(_offerDate!, 7);
    _legalTextController = TextEditingController();
    _discountPercentageController = TextEditingController();
    _discountAmountController = TextEditingController();
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
    _authorizedPhoneController.dispose();
    _mobilePhoneController.dispose();
    _legalTextController.dispose();
    _discountPercentageController.dispose();
    _discountAmountController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  List<PriceOfferCurrencyType> get _availableDiscountCurrencies {
    final present = <PriceOfferCurrencyType>{
      for (final row in _itemRows) row.currency,
    };
    return [
      for (final currency in PriceOfferCurrencyType.values)
        if (present.contains(currency)) currency,
    ];
  }

  void _handleItemsChanged() {
    setState(() {
      if (_discountType != PriceOfferDiscountType.fixed) {
        return;
      }
      final available = _availableDiscountCurrencies;
      if (available.isEmpty) {
        _discountCurrency = null;
      } else if (_discountCurrency == null ||
          !available.contains(_discountCurrency)) {
        _discountCurrency = available.first;
      }
    });
  }

  void _handleDiscountTypeChanged(PriceOfferDiscountType type) {
    setState(() {
      _discountType = type;
      if (type == PriceOfferDiscountType.fixed && _discountCurrency == null) {
        final available = _availableDiscountCurrencies;
        if (available.isNotEmpty) {
          _discountCurrency = available.first;
        }
      }
    });
  }

  void _handleDiscountCurrencyChanged(PriceOfferCurrencyType? currency) {
    setState(() {
      _discountCurrency = currency;
    });
  }

  Future<void> _handleTypeChanged(OfferType? type) async {
    if (!_isLegalTextDirty && type != null) {
      final text = await _legalTextTemplateService.getTemplateByOfferType(type);
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

  void _handleOfferDateChanged(DateTime? date) {
    setState(() {
      _offerDate = date;
      if (!_isValidityDateDirty && date != null) {
        _validityDate = AppDateUtils.addDays(date, 7);
      }
    });
  }

  void _handleValidityDateChanged(DateTime? date) {
    setState(() {
      _validityDate = date;
      _isValidityDateDirty = true;
    });
  }

  Future<void> _handleCustomerChanged(
    PriceOffersController controller,
    String? customerId,
  ) async {
    setState(() {
      _selectedCustomerId = customerId;
      _selectedContact = null;
      _mobilePhoneController.clear();
      _applyCustomerPhone(controller, customerId);
    });

    await controller.loadCustomerContacts(customerId);
    if (!mounted) {
      return;
    }

    final defaultContact = _findDefaultContact(controller.customerContacts);
    if (defaultContact != null) {
      setState(() {
        _applyContactSelection(defaultContact);
      });
    }
  }

  void _handleContactChanged(CustomerContactItem? contact) {
    setState(() {
      _applyContactSelection(contact);
    });
  }

  void _applyCustomerPhone(
    PriceOffersController controller,
    String? customerId,
  ) {
    if (customerId == null) {
      _authorizedPhoneController.clear();
      return;
    }

    Customer? customer;
    for (final item in controller.customers) {
      if (item.id == customerId) {
        customer = item;
        break;
      }
    }

    final phone = customer?.phone?.trim();
    _authorizedPhoneController.text =
        phone != null && phone.isNotEmpty ? phone : '';
  }

  void _applyContactSelection(CustomerContactItem? contact) {
    _selectedContact = contact;
    final phone = contact?.phone?.trim();
    _mobilePhoneController.text =
        phone != null && phone.isNotEmpty ? phone : '';
  }

  CustomerContactItem? _findDefaultContact(
    List<CustomerContactItem> contacts,
  ) {
    for (final contact in contacts) {
      if (contact.isPrimary) {
        return contact;
      }
    }

    return contacts.isEmpty ? null : contacts.first;
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
      validityDate: _validityDate,
      customerId: _selectedCustomerId,
      contactPerson: _selectedContact?.fullName ?? '',
      authorizedPhone: _authorizedPhoneController.text,
      mobilePhone: _mobilePhoneController.text,
      legalText: _legalTextController.text,
      itemValidations: _buildItemValidations(),
      discountType: _discountType,
      discountPercentageText: _discountPercentageController.text,
      discountAmountText: _discountAmountController.text,
      discountCurrency: _discountCurrency,
    );

    if (id != null) {
      await Get.offNamed<void>(AppRoutes.priceOffersDetail.pathForId(id));
    }
  }

  Future<void> _initializeCustomerContacts(
    PriceOffersController controller,
  ) async {
    if (_selectedCustomerId == null) {
      return;
    }

    await controller.loadCustomerContacts(_selectedCustomerId);
    if (!mounted) {
      return;
    }

    final defaultContact = _findDefaultContact(controller.customerContacts);
    setState(() {
      _applyCustomerPhone(controller, _selectedCustomerId);
      if (defaultContact != null) {
        _applyContactSelection(defaultContact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<PriceOffersController>(
      viewModel: Get.find<PriceOffersController>(),
      onModelReady: (controller) {
        controller.clearMessages();
        controller.loadCustomersForDropdown().then((_) {
          _initializeCustomerContacts(controller);
        });
      },
      onPageBuilder: (context, controller) {
        return PanelFormScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PanelFormPageHeader(
                title: 'Yeni Fiyat Teklifi',
                subtitle: 'Yeni fiyat teklifi oluşturun.',
                onBack: () => Get.offNamed<void>(AppRoutes.priceOffers.value),
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
                        validityDate: _validityDate,
                        contacts: controller.customerContacts.toList(),
                        selectedContact: _selectedContact,
                        isLoadingContacts: controller.isLoadingContacts.value,
                        authorizedPhoneController: _authorizedPhoneController,
                        mobilePhoneController: _mobilePhoneController,
                        legalTextController: _legalTextController,
                        itemRows: _itemRows,
                        discountType: _discountType,
                        discountPercentageController:
                            _discountPercentageController,
                        discountAmountController: _discountAmountController,
                        discountCurrency: _discountCurrency,
                        onCustomerChanged: (value) =>
                            _handleCustomerChanged(controller, value),
                        onContactChanged: _handleContactChanged,
                        onTypeChanged: _handleTypeChanged,
                        onDateChanged: _handleOfferDateChanged,
                        onValidityDateChanged: _handleValidityDateChanged,
                        onLegalTextChanged: (_) {
                          _isLegalTextDirty = true;
                        },
                        onItemsChanged: _handleItemsChanged,
                        onDiscountTypeChanged: _handleDiscountTypeChanged,
                        onDiscountCurrencyChanged:
                            _handleDiscountCurrencyChanged,
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
