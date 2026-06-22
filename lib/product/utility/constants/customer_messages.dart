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
}
