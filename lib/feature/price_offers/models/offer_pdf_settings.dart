import 'package:equatable/equatable.dart';

/// Keys stored in [AppSettings] for price offer PDF generation.
abstract final class OfferPdfSettingsKeys {
  static const supplierCompanyName = 'supplierCompanyName';
  static const supplierContactPerson = 'supplierContactPerson';
  static const supplierPhone = 'supplierPhone';
  static const supplierMobilePhone = 'supplierMobilePhone';
  static const companyLegalName = 'companyLegalName';
  static const companyAddress = 'companyAddress';
  static const companyTaxInfo = 'companyTaxInfo';
  static const companyTradeRegistry = 'companyTradeRegistry';
  static const companyEmail1 = 'companyEmail1';
  static const companyEmail2 = 'companyEmail2';
  static const companyTel = 'companyTel';
  static const companyFax = 'companyFax';

  static const all = [
    supplierCompanyName,
    supplierContactPerson,
    supplierPhone,
    supplierMobilePhone,
    companyLegalName,
    companyAddress,
    companyTaxInfo,
    companyTradeRegistry,
    companyEmail1,
    companyEmail2,
    companyTel,
    companyFax,
  ];
}

/// Company and supplier info used when generating price offer PDFs.
final class OfferPdfSettings extends Equatable {
  const OfferPdfSettings({
    required this.supplierCompanyName,
    required this.supplierContactPerson,
    required this.supplierPhone,
    required this.supplierMobilePhone,
    required this.companyLegalName,
    required this.companyAddress,
    required this.companyTaxInfo,
    required this.companyTradeRegistry,
    required this.companyEmail1,
    required this.companyEmail2,
    required this.companyTel,
    required this.companyFax,
  });

  final String supplierCompanyName;
  final String supplierContactPerson;
  final String supplierPhone;
  final String supplierMobilePhone;
  final String companyLegalName;
  final String companyAddress;
  final String companyTaxInfo;
  final String companyTradeRegistry;
  final String companyEmail1;
  final String companyEmail2;
  final String companyTel;
  final String companyFax;

  static const defaults = OfferPdfSettings(
    supplierCompanyName: 'OK TEKNİK METAL',
    supplierContactPerson: 'Işılay Allıtekin',
    supplierPhone: '0 232 457 36 47',
    supplierMobilePhone: '0 530 257 76 57',
    companyLegalName:
        'OK TEKNİK METAL VE KESİCİ TAKIMLAR GIDA İNŞ. OTOM. SAN. VE TİC. LTD. ŞTİ.',
    companyAddress:
        'Kemalpaşa Mahallesi 7419 Sokak No: 59/A 5. Sanayi Sitesi Bornova/İZMİR',
    companyTaxInfo: 'Hasan Tahsin Vergi Dairesi / 636 037 6782',
    companyTradeRegistry: 'Ticaret Sicil No: 193768',
    companyEmail1: 'info@okteknikmetal.com',
    companyEmail2: 'info@okteknikhirdavat.com',
    companyTel: 'Tel: 0232 478 36 47',
    companyFax: 'Fax: 0232 478 36 50',
  );

  Map<String, String> toKeyValueMap() {
    return {
      OfferPdfSettingsKeys.supplierCompanyName: supplierCompanyName,
      OfferPdfSettingsKeys.supplierContactPerson: supplierContactPerson,
      OfferPdfSettingsKeys.supplierPhone: supplierPhone,
      OfferPdfSettingsKeys.supplierMobilePhone: supplierMobilePhone,
      OfferPdfSettingsKeys.companyLegalName: companyLegalName,
      OfferPdfSettingsKeys.companyAddress: companyAddress,
      OfferPdfSettingsKeys.companyTaxInfo: companyTaxInfo,
      OfferPdfSettingsKeys.companyTradeRegistry: companyTradeRegistry,
      OfferPdfSettingsKeys.companyEmail1: companyEmail1,
      OfferPdfSettingsKeys.companyEmail2: companyEmail2,
      OfferPdfSettingsKeys.companyTel: companyTel,
      OfferPdfSettingsKeys.companyFax: companyFax,
    };
  }

  factory OfferPdfSettings.fromMap(Map<String, String> values) {
    String read(String key, String fallback) {
      final value = values[key];
      if (value == null || value.trim().isEmpty) {
        return fallback;
      }
      return value;
    }

    const d = OfferPdfSettings.defaults;
    return OfferPdfSettings(
      supplierCompanyName:
          read(OfferPdfSettingsKeys.supplierCompanyName, d.supplierCompanyName),
      supplierContactPerson: read(
        OfferPdfSettingsKeys.supplierContactPerson,
        d.supplierContactPerson,
      ),
      supplierPhone:
          read(OfferPdfSettingsKeys.supplierPhone, d.supplierPhone),
      supplierMobilePhone: read(
        OfferPdfSettingsKeys.supplierMobilePhone,
        d.supplierMobilePhone,
      ),
      companyLegalName:
          read(OfferPdfSettingsKeys.companyLegalName, d.companyLegalName),
      companyAddress:
          read(OfferPdfSettingsKeys.companyAddress, d.companyAddress),
      companyTaxInfo:
          read(OfferPdfSettingsKeys.companyTaxInfo, d.companyTaxInfo),
      companyTradeRegistry: read(
        OfferPdfSettingsKeys.companyTradeRegistry,
        d.companyTradeRegistry,
      ),
      companyEmail1: read(OfferPdfSettingsKeys.companyEmail1, d.companyEmail1),
      companyEmail2: read(OfferPdfSettingsKeys.companyEmail2, d.companyEmail2),
      companyTel: read(OfferPdfSettingsKeys.companyTel, d.companyTel),
      companyFax: read(OfferPdfSettingsKeys.companyFax, d.companyFax),
    );
  }

  OfferPdfSettings copyWith({
    String? supplierCompanyName,
    String? supplierContactPerson,
    String? supplierPhone,
    String? supplierMobilePhone,
    String? companyLegalName,
    String? companyAddress,
    String? companyTaxInfo,
    String? companyTradeRegistry,
    String? companyEmail1,
    String? companyEmail2,
    String? companyTel,
    String? companyFax,
  }) {
    return OfferPdfSettings(
      supplierCompanyName: supplierCompanyName ?? this.supplierCompanyName,
      supplierContactPerson:
          supplierContactPerson ?? this.supplierContactPerson,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      supplierMobilePhone: supplierMobilePhone ?? this.supplierMobilePhone,
      companyLegalName: companyLegalName ?? this.companyLegalName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyTaxInfo: companyTaxInfo ?? this.companyTaxInfo,
      companyTradeRegistry: companyTradeRegistry ?? this.companyTradeRegistry,
      companyEmail1: companyEmail1 ?? this.companyEmail1,
      companyEmail2: companyEmail2 ?? this.companyEmail2,
      companyTel: companyTel ?? this.companyTel,
      companyFax: companyFax ?? this.companyFax,
    );
  }

  @override
  List<Object?> get props => [
        supplierCompanyName,
        supplierContactPerson,
        supplierPhone,
        supplierMobilePhone,
        companyLegalName,
        companyAddress,
        companyTaxInfo,
        companyTradeRegistry,
        companyEmail1,
        companyEmail2,
        companyTel,
        companyFax,
      ];
}
