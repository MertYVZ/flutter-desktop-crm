import 'package:Ok/feature/customers/models/customer_contact.dart';
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/offer_type.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/feature/price_offers/models/price_offer_status.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class PriceOffersService {
  PriceOffersService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<PriceOfferListItem>> getOffers() =>
      _databaseService.priceOffers.getOffers();

  Future<List<PriceOfferListItem>> searchOffers({
    String? searchQuery,
    OfferType? typeFilter,
    PriceOfferStatus? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _databaseService.priceOffers.searchOffers(
      searchQuery: searchQuery,
      typeFilter: typeFilter,
      statusFilter: statusFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<PriceOfferDetail?> getOfferById(String id) =>
      _databaseService.priceOffers.getOfferDetailById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<List<CustomerContactItem>> getCustomerContacts(
    String customerId,
  ) async {
    final contacts =
        await _databaseService.customerContacts.getContactsByCustomerId(
      customerId,
    );
    return contacts.map(CustomerContactItem.fromEntity).toList();
  }

  Future<String> createOffer({
    required OfferType type,
    required DateTime offerDate,
    required DateTime validityDate,
    required String customerId,
    required String contactPerson,
    String? authorizedPhone,
    String? mobilePhone,
    required String legalText,
    required List<PriceOfferItemInput> items,
  }) async {
    final now = DateTime.now();
    final offerId = _uuid.v4();

    final offerCompanion = PriceOffersCompanion.insert(
      id: offerId,
      type: type.value,
      offerDate: offerDate,
      validityDate: validityDate,
      customerId: customerId,
      contactPerson: contactPerson.trim(),
      authorizedPhone: Value(_nullableTrim(authorizedPhone)),
      mobilePhone: Value(_nullableTrim(mobilePhone)),
      legalText: legalText.trim(),
      status: PriceOfferStatus.draft.value,
      createdAt: now,
      updatedAt: now,
    );

    final itemCompanions = _buildItemCompanions(
      offerId: offerId,
      items: items,
      now: now,
    );

    return _databaseService.priceOffers.createOfferWithItems(
      offer: offerCompanion,
      items: itemCompanions,
    );
  }

  Future<void> updateOffer({
    required String id,
    required OfferType type,
    required DateTime offerDate,
    required DateTime validityDate,
    required String customerId,
    required String contactPerson,
    String? authorizedPhone,
    String? mobilePhone,
    required String legalText,
    required PriceOfferStatus status,
    required List<PriceOfferItemInput> items,
  }) async {
    final existing = await getOfferById(id);
    if (existing == null) {
      throw StateError('Price offer not found');
    }

    final now = DateTime.now();
    final updatedOffer = PriceOffer(
      id: id,
      type: type.value,
      offerDate: offerDate,
      validityDate: validityDate,
      customerId: customerId,
      contactPerson: contactPerson.trim(),
      authorizedPhone: _nullableTrim(authorizedPhone),
      mobilePhone: _nullableTrim(mobilePhone),
      legalText: legalText.trim(),
      status: status.value,
      createdAt: existing.createdAt,
      updatedAt: now,
      deletedAt: null,
    );

    final itemCompanions = _buildItemCompanions(
      offerId: id,
      items: items,
      now: now,
    );

    await _databaseService.priceOffers.updateOfferWithItems(
      offer: updatedOffer,
      items: itemCompanions,
    );
  }

  Future<void> deleteOffer(String id) async {
    final affectedRows =
        await _databaseService.priceOffers.softDeleteOfferAndItems(id);
    if (affectedRows == 0) {
      throw StateError('Price offer not found');
    }
  }

  List<PriceOfferItemsCompanion> _buildItemCompanions({
    required String offerId,
    required List<PriceOfferItemInput> items,
    required DateTime now,
  }) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return PriceOfferItemsCompanion.insert(
        id: _uuid.v4(),
        offerId: offerId,
        productName: item.productName.trim(),
        unitType: item.unitType.trim(),
        quantity: item.quantity,
        priceMinor: item.priceMinor,
        currency: item.currency.value,
        sortOrder: index,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  String? _nullableTrim(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
