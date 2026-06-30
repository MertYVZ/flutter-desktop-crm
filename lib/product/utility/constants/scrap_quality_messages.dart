final class ScrapQualityMessages {
  ScrapQualityMessages._();

  static const createSuccess = 'Hurda kaydı oluşturuldu.';
  static const createError = 'Hurda kaydı oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Hurda kaydı güncellendi.';
  static const updateError = 'Hurda kaydı güncellenirken bir hata oluştu.';
  static const deleteSuccess = 'Hurda kaydı silindi.';
  static const deleteError = 'Hurda kaydı silinirken bir hata oluştu.';
  static const notFound = 'Hurda kaydı bulunamadı.';
  static const loadError = 'Hurda kayıtları yüklenirken bir hata oluştu.';
  static const exportSuccess = 'Hurda takip kayıtları Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty = 'Dışa aktarılacak hurda kaydı bulunmuyor.';
  static const deleteTitle = 'Hurda Kaydını Sil';
  static const deleteBody =
      'Bu hurda kaydını silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const offerPriceRangeError =
      'Minimum teklif fiyatı maksimum teklif fiyatından büyük olamaz.';
  static const noCustomersForForm =
      'Hurda kaydı oluşturmak için önce aktif bir müşteri eklemeniz gerekir.';
  static const listEmptyTitle = 'Bu ay için henüz hurda kaydı yok.';
  static const listEmptyBody =
      'Yeni kayıt ekleyerek takip oluşturmaya başlayabilirsiniz.';
  static const listFilteredEmpty =
      'Kriterlere uygun hurda kaydı bulunamadı.';

  static const customerRequired = 'Müşteri seçiniz.';
  static const scrapTypeRequired = 'Hurda türü giriniz.';
  static const scrapTypeMinLength =
      'Hurda türü en az 2 karakter olmalıdır.';
  static const quantityRequired = 'Miktar zorunludur.';
  static const quantityPositive = 'Miktar 0\'dan büyük olmalıdır.';
  static const quantityKgRequired = 'KG karşılığı giriniz.';
  static const unitRequired = 'Birim seçiniz.';
  static const customUnitRequired = 'Özel birim adı giriniz.';
  static const recordDateRequired = 'Tarih seçiniz.';
  static const salesStatusRequired = 'Satış durumu seçiniz.';

  @Deprecated('Use scrapTypeRequired')
  static const qualityRequired = scrapTypeRequired;

  @Deprecated('Use scrapTypeMinLength')
  static const qualityMinLength = scrapTypeMinLength;

  @Deprecated('Use offerPriceRangeError')
  static const dateRangeError = offerPriceRangeError;
}
