/// Date and time helpers for auth flows.
abstract final class DateTimeUtils {
  static bool isInFuture(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    return dateTime.isAfter(DateTime.now());
  }

  static bool isInPast(DateTime dateTime) => dateTime.isBefore(DateTime.now());
}
