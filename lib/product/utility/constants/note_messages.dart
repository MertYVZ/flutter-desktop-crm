final class NoteMessages {
  NoteMessages._();

  static const createSuccess = 'Not kaydı oluşturuldu.';
  static const createError = 'Not kaydı oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Not kaydı güncellendi.';
  static const updateError = 'Not kaydı güncellenirken bir hata oluştu.';
  static const deleteSuccess = 'Not kaydı silindi.';
  static const deleteError = 'Not kaydı silinirken bir hata oluştu.';
  static const notFound = 'Not kaydı bulunamadı.';
  static const exportSuccess = 'Notlar Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty = 'Dışa aktarılacak not kaydı bulunmuyor.';
  static const deleteTitle = 'Notu Sil';
  static const deleteBody =
      'Bu notu silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';
  static const listEmpty = 'Henüz not kaydı bulunmuyor.';
  static const listFilteredEmpty = 'Kriterlere uygun not kaydı bulunamadı.';

  static const titleRequired = 'Başlık giriniz.';
  static const titleMinLength = 'Başlık en az 2 karakter olmalıdır.';
  static const contentRequired = 'İçerik giriniz.';
  static const contentMinLength = 'İçerik en az 3 karakter olmalıdır.';
}
