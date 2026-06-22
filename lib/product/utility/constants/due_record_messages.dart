final class DueRecordMessages {
  DueRecordMessages._();

  static const createSuccess = 'Vade kaydı oluşturuldu.';
  static const createError = 'Vade kaydı oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Vade kaydı güncellendi.';
  static const updateError = 'Vade kaydı güncellenirken bir hata oluştu.';
  static const deleteSuccess = 'Vade kaydı silindi.';
  static const deleteError = 'Vade kaydı silinirken bir hata oluştu.';
  static const notFound = 'Vade kaydı bulunamadı.';
  static const exportSuccess = 'Vade kayıtları Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty = 'Dışa aktarılacak vade kaydı bulunmuyor.';
  static const deleteTitle = 'Vade Kaydını Sil';
  static const deleteBody =
      'Bu vade kaydını silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';
  static const noCustomersForForm =
      'Vade kaydı oluşturmak için önce aktif bir müşteri eklemeniz gerekir.';

  static const customerRequired = 'Müşteri seçiniz.';
  static const dueDateRequired = 'Vade tarihi seçiniz.';
  static const amountRequired = 'Tutar zorunludur.';
  static const amountPositive = 'Tutar 0\'dan büyük olmalıdır.';
  static const currencyRequired = 'Para birimi seçiniz.';
  static const invoiceNoRequired = 'Fatura no zorunludur.';
  static const statusRequired = 'Durum seçiniz.';
}
