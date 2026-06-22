final class ReminderMessages {
  ReminderMessages._();

  static const createSuccess = 'Hatırlatma kaydı oluşturuldu.';
  static const createError = 'Hatırlatma kaydı oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Hatırlatma kaydı güncellendi.';
  static const updateError = 'Hatırlatma kaydı güncellenirken bir hata oluştu.';
  static const completeSuccess = 'Hatırlatma tamamlandı.';
  static const completeError = 'Hatırlatma tamamlanırken bir hata oluştu.';
  static const deleteSuccess = 'Hatırlatma kaydı silindi.';
  static const deleteError = 'Hatırlatma kaydı silinirken bir hata oluştu.';
  static const notFound = 'Hatırlatma kaydı bulunamadı.';
  static const exportSuccess = 'Hatırlatmalar Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty = 'Dışa aktarılacak hatırlatma kaydı bulunmuyor.';
  static const deleteTitle = 'Hatırlatmayı Sil';
  static const deleteBody =
      'Bu hatırlatmayı silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const completeTitle = 'Hatırlatmayı Tamamla';
  static const completeBody =
      'Bu hatırlatmayı tamamlandı olarak işaretlemek istediğinize emin misiniz? Bir sonraki hatırlatma tarihi bir periyot ileri alınacaktır.';
  static const completeCancel = 'Vazgeç';
  static const completeConfirm = 'Tamamlandı';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';
  static const noCustomersForForm =
      'Hatırlatma kaydı oluşturmak için önce aktif bir müşteri eklemeniz gerekir.';
  static const listEmpty = 'Henüz hatırlatma kaydı bulunmuyor.';
  static const listFilteredEmpty =
      'Kriterlere uygun hatırlatma kaydı bulunamadı.';

  static const customerRequired = 'Müşteri seçiniz.';
  static const titleRequired = 'Başlık giriniz.';
  static const titleMinLength = 'Başlık en az 2 karakter olmalıdır.';
  static const periodRequired = 'Periyot seçiniz.';
  static const startDateRequired = 'İlk hatırlatma tarihi seçiniz.';
  static const nextReminderDateRequired =
      'Bir sonraki hatırlatma tarihi seçiniz.';
  static const statusRequired = 'Durum seçiniz.';
}
