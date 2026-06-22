final class ScrapQualityMessages {
  ScrapQualityMessages._();

  static const createSuccess = 'Hurda kalite kaydı oluşturuldu.';
  static const createError =
      'Hurda kalite kaydı oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Hurda kalite kaydı güncellendi.';
  static const updateError =
      'Hurda kalite kaydı güncellenirken bir hata oluştu.';
  static const deleteSuccess = 'Hurda kalite kaydı silindi.';
  static const deleteError = 'Hurda kalite kaydı silinirken bir hata oluştu.';
  static const notFound = 'Hurda kalite kaydı bulunamadı.';
  static const exportSuccess = 'Hurda kalite kayıtları Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty =
      'Dışa aktarılacak hurda kalite kaydı bulunmuyor.';
  static const deleteTitle = 'Hurda Kalite Kaydını Sil';
  static const deleteBody =
      'Bu hurda kalite kaydını silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';
  static const noCustomersForForm =
      'Hurda kalite kaydı oluşturmak için önce aktif bir müşteri eklemeniz gerekir.';

  static const customerRequired = 'Müşteri seçiniz.';
  static const qualityRequired = 'Kalite giriniz.';
  static const qualityMinLength = 'Kalite en az 2 karakter olmalıdır.';
  static const quantityRequired = 'Miktar zorunludur.';
  static const quantityPositive = 'Miktar 0\'dan büyük olmalıdır.';
  static const unitRequired = 'Birim seçiniz.';
  static const customUnitRequired = 'Özel birim adı giriniz.';
}
