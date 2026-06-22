import 'package:intl/intl.dart';

final class AppDateUtils {
  AppDateUtils._();

  static final DateFormat displayDate = DateFormat('dd.MM.yyyy', 'tr_TR');
  static final DateFormat displayDateTime =
      DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');
  static final DateFormat exportTimestamp =
      DateFormat('yyyyMMdd_HHmmss', 'tr_TR');

  static String formatDate(DateTime date) => displayDate.format(date);

  static String formatDateTime(DateTime date) => displayDateTime.format(date);

  static const turkishMonths = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const turkishWeekdaysShort = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  static String monthYearLabel(DateTime date) =>
      '${turkishMonths[date.month - 1]} ${date.year}';

  static DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
