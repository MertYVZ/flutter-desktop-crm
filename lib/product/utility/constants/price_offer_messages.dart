final class PriceOfferMessages {
  PriceOfferMessages._();

  static const createSuccess = 'Fiyat teklifi oluşturuldu.';
  static const createError =
      'Fiyat teklifi oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Fiyat teklifi güncellendi.';
  static const updateError =
      'Fiyat teklifi güncellenirken bir hata oluştu.';
  static const deleteSuccess = 'Fiyat teklifi silindi.';
  static const deleteError = 'Fiyat teklifi silinirken bir hata oluştu.';
  static const notFound = 'Fiyat teklifi bulunamadı.';
  static const exportSuccess = 'Fiyat teklifleri Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty =
      'Dışa aktarılacak fiyat teklifi bulunmuyor.';
  static const deleteTitle = 'Fiyat Teklifini Sil';
  static const deleteBody =
      'Bu fiyat teklifini silmek istediğinize emin misiniz? Bu işlem sonrasında kayıt listede görünmeyecektir.';
  static const deleteCancel = 'Vazgeç';
  static const deleteConfirm = 'Sil';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';
  static const noCustomersForForm =
      'Fiyat teklifi oluşturmak için önce aktif bir müşteri eklemeniz gerekir.';
  static const listEmpty = 'Henüz fiyat teklifi bulunmuyor.';
  static const listFilteredEmpty =
      'Kriterlere uygun fiyat teklifi bulunamadı.';
  static const pdfSuccess = 'PDF dosyası oluşturuldu.';
  static const pdfError = 'PDF oluşturulurken bir hata oluştu.';
  static const pdfCancelled = 'PDF kaydetme işlemi iptal edildi.';

  static const typeRequired = 'Tip seçiniz.';
  static const dateRequired = 'Tarih seçiniz.';
  static const customerRequired = 'Müşteri seçiniz.';
  static const contactPersonRequired = 'Yetkili kişi zorunludur.';
  static const legalTextRequired = 'Yasal metin zorunludur.';
  static const statusRequired = 'Durum seçiniz.';
  static const itemsRequired = 'En az bir ürün ekleyiniz.';
  static const productNameRequired = 'Ürün adı zorunludur.';
  static const unitTypeRequired = 'Birim tipi zorunludur.';
  static const quantityPositive = 'Miktar 0\'dan büyük olmalıdır.';
  static const priceNonNegative = 'Fiyat 0\'dan küçük olamaz.';
  static const currencyRequired = 'Para birimi seçiniz.';
  static const phoneTooShort = 'Telefon numarası çok kısa.';
}
