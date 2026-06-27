import 'package:Ok/feature/due_tracking/models/currency_type.dart'
    as due_currency;
import 'package:Ok/feature/price_offers/models/currency_type.dart';
import 'package:Ok/feature/price_offers/models/offer_pdf_settings.dart';
import 'package:Ok/feature/price_offers/models/price_offer_list_item.dart';
import 'package:Ok/product/utility/app_date_utils.dart';
import 'package:Ok/product/utility/money_utils.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final class PriceOfferPdfBuilder {
  PriceOfferPdfBuilder({
    required this.offer,
    required this.settings,
  });

  final PriceOfferDetail offer;
  final OfferPdfSettings settings;

  static const _pageMargin = 44.0;
  static const _logoAssetPath = 'assets/pdf/logo.png';
  static const _headerLogoWidth = 210.0;

  /// Logo PNG'sinin üst ~%35'inde içerik var; alt boşluk kırpılır.
  static const _logoVisibleHeightRatio = 0.35;

  static const _brandPrimary = PdfColor.fromInt(0xFFED7C02);
  static const _brandTint = PdfColor.fromInt(0xFFFFF4E8);
  static const _textPrimary = PdfColor.fromInt(0xFF1A1A1A);
  static const _textSecondary = PdfColor.fromInt(0xFF666666);
  static const _textMuted = PdfColor.fromInt(0xFF999999);
  static const _surfaceLight = PdfColor.fromInt(0xFFF5F5F5);
  static const _surfaceAlt = PdfColor.fromInt(0xFFFAFAFA);
  static const _borderColor = PdfColor.fromInt(0xFFE0E0E0);

  static final _quantityFormat = NumberFormat('#,##0.00', 'tr_TR');

  Future<pw.Document> buildDocument() async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/InstrumentSans-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/InstrumentSans-Bold.ttf'),
    );
    final logoBytes = await rootBundle.load(_logoAssetPath);
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    final doc = pw.Document(
      title: 'Teklif Formu',
      theme: theme,
    )..addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(_pageMargin),
          header: (_) => _buildBrandStripe(),
          footer: (context) => _buildPageFooter(context, regularFont),
          build: (context) => [
            _buildPageHeader(regularFont, boldFont, logoImage),
            pw.SizedBox(height: 20),
            _buildPartiesSection(regularFont, boldFont),
            pw.SizedBox(height: 12),
            ..._buildProductsTable(regularFont, boldFont),
            pw.SizedBox(height: 16),
            ..._buildCurrencyTotals(regularFont, boldFont),
            pw.SizedBox(height: 24),
            _buildLegalHeading(boldFont),
            pw.SizedBox(height: 10),
            ..._buildLegalBody(regularFont),
            pw.SizedBox(height: 24),
            ..._buildCompanyFooter(regularFont),
          ],
        ),
      );

    return doc;
  }

  pw.Widget _buildBrandStripe() {
    return pw.Container(
      height: 4,
      color: _brandPrimary,
      margin: const pw.EdgeInsets.only(bottom: 12),
    );
  }

  pw.Widget _buildPageFooter(pw.Context context, pw.Font regularFont) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Sayfa ${context.pageNumber} / ${context.pagesCount}',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 8,
          color: _textMuted,
        ),
      ),
    );
  }

  pw.Widget _buildPageHeader(
    pw.Font regularFont,
    pw.Font boldFont,
    pw.MemoryImage logoImage,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Stack(
          children: [
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Image(
                logoImage,
                width: _headerLogoWidth,
                height: _headerLogoWidth * _logoVisibleHeightRatio,
                fit: pw.BoxFit.fitWidth,
                alignment: pw.Alignment.topCenter,
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'TEKLİF FORMU',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _textPrimary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    AppDateUtils.formatDate(offer.offerDate),
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 10,
                      color: _textSecondary,
                    ),
                  ),
                  pw.Text(
                    'Geçerlilik: ${AppDateUtils.formatDate(offer.validityDate)}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _borderColor),
      ],
    );
  }

  pw.Widget _buildPartiesSection(pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _surfaceLight,
        border: pw.Border.all(color: _borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _buildPartyBlock(
              title: 'MÜŞTERİ',
              regularFont: regularFont,
              boldFont: boldFont,
              rows: [
                _PartyRow('Firma', offer.customerName),
                _PartyRow('Yetkili', offer.contactPerson),
                _PartyRow('Telefon', offer.displayAuthorizedPhone),
                _PartyRow('Yetkili Telefonu', offer.displayMobilePhone),
              ],
            ),
          ),
          pw.Container(
            width: 0.5,
            height: 88,
            margin: const pw.EdgeInsets.symmetric(horizontal: 14),
            color: _borderColor,
          ),
          pw.Expanded(
            child: _buildPartyBlock(
              title: 'TEDARİKÇİ',
              regularFont: regularFont,
              boldFont: boldFont,
              rows: [
                _PartyRow('Firma', settings.supplierCompanyName),
                _PartyRow('İlgili Kişi', settings.supplierContactPerson),
                _PartyRow('Telefon', settings.supplierPhone),
                _PartyRow('Yetkili Telefonu', settings.supplierMobilePhone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPartyBlock({
    required String title,
    required pw.Font regularFont,
    required pw.Font boldFont,
    required List<_PartyRow> rows,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: _brandPrimary,
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) pw.SizedBox(height: 6),
          _buildPartyInfoRow(
            label: rows[i].label,
            value: rows[i].value,
            regularFont: regularFont,
            boldFont: boldFont,
          ),
        ],
      ],
    );
  }

  pw.Widget _buildPartyInfoRow({
    required String label,
    required String value,
    required pw.Font regularFont,
    required pw.Font boldFont,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 72,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8,
              color: _textSecondary,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildProductsTable(pw.Font regularFont, pw.Font boldFont) {
    final headerStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: _textPrimary,
    );
    final cellStyle =
        pw.TextStyle(font: regularFont, fontSize: 9, color: _textPrimary);
    final borderSide = pw.BorderSide(color: _borderColor, width: 0.5);
    const columnWidths = {
      0: pw.FlexColumnWidth(2.8),
      1: pw.FlexColumnWidth(1.1),
      2: pw.FlexColumnWidth(1.3),
      3: pw.FlexColumnWidth(1.2),
    };

    pw.Widget headerCell(String text,
        {pw.TextAlign align = pw.TextAlign.left}) {
      return pw.Container(
        color: _brandTint,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: pw.Text(text, style: headerStyle, textAlign: align),
      );
    }

    pw.Widget dataCell(
      String text, {
      pw.TextAlign align = pw.TextAlign.left,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: pw.Text(text, style: cellStyle, textAlign: align),
      );
    }

    pw.TableBorder tableBorder({
      required bool isHeader,
      required bool isLastRow,
    }) {
      return pw.TableBorder(
        left: borderSide,
        right: borderSide,
        top: isHeader ? borderSide : pw.BorderSide.none,
        bottom: isLastRow ? borderSide : pw.BorderSide.none,
        horizontalInside: pw.BorderSide(color: _borderColor, width: 0.25),
        verticalInside: pw.BorderSide(color: _borderColor, width: 0.25),
      );
    }

    final widgets = <pw.Widget>[
      pw.Table(
        border: tableBorder(isHeader: true, isLastRow: offer.items.isEmpty),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            children: [
              headerCell('ÜRÜN'),
              headerCell('MİKTAR'),
              headerCell('BİRİM FİYAT'),
              headerCell('TOPLAM', align: pw.TextAlign.right),
            ],
          ),
        ],
      ),
    ];

    for (var i = 0; i < offer.items.length; i++) {
      final item = offer.items[i];
      widgets.add(
        pw.Table(
          border: tableBorder(
            isHeader: false,
            isLastRow: i == offer.items.length - 1,
          ),
          columnWidths: columnWidths,
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: i.isOdd ? _surfaceAlt : PdfColors.white,
                border: pw.Border(
                  bottom: pw.BorderSide(color: _borderColor, width: 0.25),
                ),
              ),
              children: [
                dataCell(item.productName),
                dataCell(_formatQuantityWithUnit(item)),
                dataCell(_formatUnitPrice(item)),
                dataCell(
                  _formatRowTotal(item),
                  align: pw.TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return widgets;
  }

  List<pw.Widget> _buildCurrencyTotals(pw.Font regularFont, pw.Font boldFont) {
    final totals = _computeCurrencyTotals(offer.items);
    if (totals.isEmpty) {
      return const [];
    }

    final rows = <pw.Widget>[];
    for (final currency in PriceOfferCurrencyType.values) {
      final totalMinor = totals[currency];
      if (totalMinor == null) {
        continue;
      }

      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _currencyTotalLabel(currency),
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9,
                  color: _textSecondary,
                ),
              ),
              pw.Text(
                _formatTotalAmount(totalMinor, currency),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Container(
          width: 240,
          decoration: pw.BoxDecoration(
            color: _surfaceLight,
            border: pw.Border.all(color: _borderColor, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ),
    ];
  }

  List<pw.Widget> _buildCompanyFooter(pw.Font regularFont) {
    final labelStyle = pw.TextStyle(
      font: regularFont,
      fontSize: 8,
      color: _textSecondary,
      lineSpacing: 1.5,
    );

    final lines = [
      settings.companyLegalName,
      settings.companyAddress,
      settings.companyTaxInfo,
      settings.companyTradeRegistry,
      settings.companyEmail1,
      settings.companyEmail2,
      settings.companyTel,
      settings.companyFax,
    ].where((line) => line.trim().isNotEmpty);

    return [
      pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: _borderColor, width: 0.5),
          ),
        ),
        padding: const pw.EdgeInsets.only(top: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final line in lines)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Text(line, style: labelStyle),
              ),
          ],
        ),
      ),
    ];
  }

  pw.Widget _buildLegalHeading(pw.Font boldFont) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 3,
          height: 16,
          color: _brandPrimary,
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          'Teklif Bilgilendirme Metni',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildLegalBody(pw.Font regularFont) {
    final style = pw.TextStyle(
      font: regularFont,
      fontSize: 8.5,
      color: _textSecondary,
      lineSpacing: 1.5,
    );

    return [
      pw.Text(offer.legalText.trim(), style: style),
    ];
  }

  String _formatQuantityWithUnit(PriceOfferItemData item) {
    final quantity = _quantityFormat.format(item.quantity);
    return '$quantity ${item.unitType}';
  }

  String _formatUnitPrice(PriceOfferItemData item) {
    final currency = _mapOfferCurrency(item.currencyType);
    return MoneyUtils.formatAmountMinor(item.priceMinor, currency);
  }

  String _formatRowTotal(PriceOfferItemData item) {
    final currency = _mapOfferCurrency(item.currencyType);
    return MoneyUtils.formatAmountMinor(
      item.rowTotalMinor.round(),
      currency,
    );
  }

  String _formatTotalAmount(int totalMinor, PriceOfferCurrencyType currency) {
    return MoneyUtils.formatAmountMinor(
      totalMinor,
      _mapOfferCurrency(currency),
    );
  }

  String _currencyTotalLabel(PriceOfferCurrencyType currency) {
    switch (currency) {
      case PriceOfferCurrencyType.eur:
        return 'Toplam (EUR)';
      case PriceOfferCurrencyType.try_:
        return 'Toplam (TRY)';
      case PriceOfferCurrencyType.usd:
        return 'Toplam (USD)';
    }
  }

  Map<PriceOfferCurrencyType, int> _computeCurrencyTotals(
    List<PriceOfferItemData> items,
  ) {
    final totals = <PriceOfferCurrencyType, double>{};

    for (final item in items) {
      final currency =
          item.currencyType ?? PriceOfferCurrencyTypeX.fromValue(item.currency);
      if (currency == null) {
        continue;
      }

      totals[currency] = (totals[currency] ?? 0) + item.rowTotalMinor;
    }

    return {
      for (final entry in totals.entries) entry.key: entry.value.round(),
    };
  }

  due_currency.CurrencyType _mapOfferCurrency(
      PriceOfferCurrencyType? currency) {
    switch (currency) {
      case PriceOfferCurrencyType.try_:
        return due_currency.CurrencyType.try_;
      case PriceOfferCurrencyType.usd:
        return due_currency.CurrencyType.usd;
      case PriceOfferCurrencyType.eur:
        return due_currency.CurrencyType.eur;
      case null:
        return due_currency.CurrencyType.try_;
    }
  }
}

final class _PartyRow {
  const _PartyRow(this.label, this.value);

  final String label;
  final String value;
}
