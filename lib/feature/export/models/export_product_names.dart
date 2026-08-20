abstract final class ExportProductNames {
  static const separator = ' • ';

  static List<String> parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    return trimmed
        .split(separator)
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static String join(Iterable<String> names) {
    return names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .join(separator);
  }
}
