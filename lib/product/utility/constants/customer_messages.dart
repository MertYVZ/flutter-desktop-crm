abstract final class CustomerMessages {
  static const emptyList = 'Henüz müşteri kaydı bulunmuyor.';
  static const noSearchResults = 'Kriterlere uygun müşteri bulunamadı.';
  static const notFound = 'Müşteri kaydı bulunamadı.';

  static const createSuccess = 'Müşteri kaydı oluşturuldu.';
  static const createError = 'Müşteri kaydı oluşturulurken bir hata oluştu.';

  static const updateSuccess = 'Müşteri bilgileri güncellendi.';
  static const updateError = 'Müşteri bilgileri güncellenirken bir hata oluştu.';

  static const deleteSuccess = 'Müşteri kaydı silindi.';
  static const deleteError = 'Müşteri kaydı silinirken bir hata oluştu.';

  static const deleteTitle = 'Müşteriyi Sil';
  static const deleteBody =
      'Bu müşteri kaydını silmek istediğinize emin misiniz? '
      'Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';

  static const nameRequired = 'Müşteri adı zorunludur.';
  static const typeRequired = 'Müşteri tipi seçiniz.';
  static const cityRequired = 'Şehir zorunludur.';
  static const countryRequired = 'Ülke zorunludur.';
  static const invalidEmail = 'Geçerli bir e-posta adresi giriniz.';
  static const phoneTooShort = 'Telefon numarası çok kısa.';

  static const excelInvalidFormat =
      'Excel formatı geçersiz. İlk satırda Müşteri Adı ve Müşteri Tipi sütunları olmalıdır.';
  static const excelEmpty = 'Excel dosyasında içe aktarılacak müşteri satırı yok.';
  static const excelImportError =
      'Müşteriler Excel\'den içe aktarılırken bir hata oluştu.';

  static String excelImportSummary({
    required int imported,
    required int skippedDuplicate,
    required int skippedInvalid,
  }) {
    final parts = <String>[
      '$imported müşteri eklendi',
    ];
    if (skippedDuplicate > 0) {
      parts.add('$skippedDuplicate zaten kayıtlı');
    }
    if (skippedInvalid > 0) {
      parts.add('$skippedInvalid satır atlandı');
    }
    return '${parts.join(', ')}.';
  }
}
