final class MeetingMessages {
  MeetingMessages._();

  static const createSuccess = 'Görüşme kaydı oluşturuldu.';
  static const createError = 'Görüşme kaydı oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Görüşme kaydı güncellendi.';
  static const updateError = 'Görüşme kaydı güncellenirken bir hata oluştu.';
  static const deleteSuccess = 'Görüşme kaydı silindi.';
  static const deleteError = 'Görüşme kaydı silinirken bir hata oluştu.';
  static const notFound = 'Görüşme kaydı bulunamadı.';
  static const exportSuccess = 'Görüşmeler Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty = 'Dışa aktarılacak görüşme kaydı bulunmuyor.';
  static const deleteTitle = 'Görüşmeyi Sil';
  static const deleteBody =
      'Bu görüşmeyi silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';
  static const noCustomersForForm =
      'Görüşme kaydı oluşturmak için önce aktif bir müşteri eklemeniz gerekir.';
  static const listEmpty = 'Henüz görüşme kaydı bulunmuyor.';
  static const listFilteredEmpty =
      'Kriterlere uygun görüşme kaydı bulunamadı.';

  static const customerRequired = 'Müşteri seçiniz.';
  static const dateRequired = 'Tarih seçiniz.';
  static const methodRequired = 'Yöntem seçiniz.';
  static const subjectRequired = 'Konu seçiniz.';
}
