final class CustomerExcelImportResult {
  const CustomerExcelImportResult({
    this.cancelled = false,
    this.imported = 0,
    this.skippedDuplicate = 0,
    this.skippedInvalid = 0,
  });

  const CustomerExcelImportResult.cancelled() : this(cancelled: true);

  final bool cancelled;
  final int imported;
  final int skippedDuplicate;
  final int skippedInvalid;

  bool get hasImported => imported > 0;
}
