import 'dart:io';

import 'package:Ok/feature/customers/models/customer_excel_import_result.dart';
import 'package:Ok/feature/customers/models/customer_type.dart';
import 'package:Ok/feature/customers/services/customer_detail_service.dart';
import 'package:Ok/feature/customers/services/customers_service.dart';
import 'package:Ok/product/utility/constants/customer_messages.dart';
import 'package:Ok/product/utility/validators.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

enum _ExcelColumn {
  name,
  type,
  phone,
  email,
  city,
  country,
  address,
  contactName,
  contactTitle,
  contactPhone,
  contactEmail,
}

final class CustomersExcelImportService {
  CustomersExcelImportService(
    this._customersService,
    this._customerDetailService,
  );

  final CustomersService _customersService;
  final CustomerDetailService _customerDetailService;

  Future<CustomerExcelImportResult> importFromExcel() async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Müşteri Excel dosyasını seçin',
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );

    if (picked == null || picked.files.isEmpty) {
      return const CustomerExcelImportResult.cancelled();
    }

    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null || bytes.isEmpty) {
      throw StateError(CustomerMessages.excelImportError);
    }

    return importBytes(bytes);
  }

  Future<CustomerExcelImportResult> importBytes(List<int> bytes) async {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      throw StateError(CustomerMessages.excelInvalidFormat);
    }

    final sheet = excel.tables.values.first;
    if (sheet.rows.isEmpty) {
      throw StateError(CustomerMessages.excelEmpty);
    }

    final headerIndex = _headerRowIndex(sheet.rows);
    if (headerIndex == null) {
      throw StateError(CustomerMessages.excelInvalidFormat);
    }

    final columns = _mapColumns(sheet.rows[headerIndex]);
    if (!columns.containsKey(_ExcelColumn.name) ||
        !columns.containsKey(_ExcelColumn.type)) {
      throw StateError(CustomerMessages.excelInvalidFormat);
    }

    var imported = 0;
    var skippedDuplicate = 0;
    var skippedInvalid = 0;
    final seenNames = <String>{};

    for (var rowIndex = headerIndex + 1;
        rowIndex < sheet.rows.length;
        rowIndex++) {
      final row = sheet.rows[rowIndex];
      final name = _cell(row, columns[_ExcelColumn.name]);
      if (name.isEmpty) {
        continue;
      }

      final type = _parseType(_cell(row, columns[_ExcelColumn.type]));
      final phone = _cell(row, columns[_ExcelColumn.phone]);
      final email = _cell(row, columns[_ExcelColumn.email]);
      final city = _cell(row, columns[_ExcelColumn.city]);
      var country = _cell(row, columns[_ExcelColumn.country]);
      if (country.isEmpty) {
        country = 'Türkiye';
      }
      final address = _cell(row, columns[_ExcelColumn.address]);

      final validationError = Validators.validateCustomerForm(
        name: name,
        type: type,
        city: city,
        country: country,
        phone: phone,
        email: email,
      );
      if (validationError != null) {
        skippedInvalid += 1;
        continue;
      }

      final normalizedName = name.toLowerCase();
      if (seenNames.contains(normalizedName)) {
        skippedDuplicate += 1;
        continue;
      }

      final existing =
          await _customersService.getActiveCustomerByName(name);
      if (existing != null) {
        seenNames.add(normalizedName);
        skippedDuplicate += 1;
        continue;
      }

      final customerId = await _customersService.createCustomer(
        name: name,
        type: type!,
        phone: phone,
        email: email,
        city: city,
        country: country,
        address: address,
      );
      seenNames.add(normalizedName);
      imported += 1;

      await _importContactIfPresent(
        customerId: customerId,
        row: row,
        columns: columns,
      );
    }

    if (imported == 0 && skippedDuplicate == 0 && skippedInvalid == 0) {
      throw StateError(CustomerMessages.excelEmpty);
    }

    return CustomerExcelImportResult(
      imported: imported,
      skippedDuplicate: skippedDuplicate,
      skippedInvalid: skippedInvalid,
    );
  }

  Future<void> _importContactIfPresent({
    required String customerId,
    required List<Data?> row,
    required Map<_ExcelColumn, int> columns,
  }) async {
    final fullName = _cell(row, columns[_ExcelColumn.contactName]);
    final title = _cell(row, columns[_ExcelColumn.contactTitle]);
    final phone = _cell(row, columns[_ExcelColumn.contactPhone]);
    final email = _cell(row, columns[_ExcelColumn.contactEmail]);
    if (fullName.isEmpty) {
      return;
    }

    final contactError = Validators.validateCustomerContactForm(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    if (contactError != null) {
      return;
    }

    await _customerDetailService.createCustomerContact(
      customerId: customerId,
      fullName: fullName,
      title: title,
      email: email,
      phone: phone,
      isPrimary: true,
    );
  }

  int? _headerRowIndex(List<List<Data?>> rows) {
    for (var index = 0; index < rows.length && index < 10; index++) {
      final columns = _mapColumns(rows[index]);
      if (columns.containsKey(_ExcelColumn.name)) {
        return index;
      }
    }
    return null;
  }

  Map<_ExcelColumn, int> _mapColumns(List<Data?> row) {
    final mapped = <_ExcelColumn, int>{};
    for (var index = 0; index < row.length; index++) {
      final column = _columnFromHeader(_cellText(row[index]));
      if (column != null && !mapped.containsKey(column)) {
        mapped[column] = index;
      }
    }
    return mapped;
  }

  _ExcelColumn? _columnFromHeader(String raw) {
    final header = _normalize(raw);
    switch (header) {
      case 'musteriadi':
      case 'musteri':
      case 'firmaadi':
        return _ExcelColumn.name;
      case 'musteritipi':
      case 'tip':
      case 'tipi':
        return _ExcelColumn.type;
      case 'telefon':
      case 'tel':
        return _ExcelColumn.phone;
      case 'eposta':
      case 'email':
      case 'mail':
        return _ExcelColumn.email;
      case 'sehir':
        return _ExcelColumn.city;
      case 'ulke':
        return _ExcelColumn.country;
      case 'adres':
        return _ExcelColumn.address;
      case 'yetkiliadsoyad':
      case 'yetkiliadi':
      case 'yetkili':
        return _ExcelColumn.contactName;
      case 'yetkiliunvan':
        return _ExcelColumn.contactTitle;
      case 'yetkilitelefon':
      case 'yetkilitelefonu':
        return _ExcelColumn.contactPhone;
      case 'yetkilieposta':
      case 'yetkiliemail':
        return _ExcelColumn.contactEmail;
      default:
        return null;
    }
  }

  CustomerType? _parseType(String raw) {
    switch (_normalize(raw)) {
      case 'k':
      case 'kurumsal':
      case 'corporate':
      case 'sirket':
        return CustomerType.corporate;
      case 'b':
      case 'bireysel':
      case 'individual':
      case 'sahis':
        return CustomerType.individual;
      case 'y':
      case 'yabanci':
      case 'foreign':
        return CustomerType.foreign;
      default:
        return null;
    }
  }

  String _cell(List<Data?> row, int? index) {
    if (index == null || index < 0 || index >= row.length) {
      return '';
    }
    return _cellText(row[index]);
  }

  String _cellText(Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return '';
    }
    if (value is TextCellValue) {
      return value.value.toString().trim();
    }
    if (value is IntCellValue) {
      return '${value.value}'.trim();
    }
    if (value is DoubleCellValue) {
      return value.value.toString().trim();
    }
    return value.toString().trim();
  }

  String _normalize(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
