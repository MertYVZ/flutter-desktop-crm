final class PriceListMessages {
  PriceListMessages._();

  static const titleRequired = 'Fiyat listesi adı zorunludur.';
  static const effectiveDateRequired = 'Geçerlilik tarihi seçiniz.';
  static const productNameRequired = 'Ürün adı zorunludur.';
  static const currencyRequired = 'Para birimi seçiniz.';
  static const minPriceRequired = 'Min fiyat zorunludur.';
  static const minPriceInvalid = 'Min fiyat geçerli bir sayı olmalıdır.';
  static const minPricePositive = 'Min fiyat 0\'dan büyük olmalıdır.';
  static const maxPriceRequired = 'Max fiyat zorunludur.';
  static const maxPriceInvalid = 'Max fiyat geçerli bir sayı olmalıdır.';
  static const maxPricePositive = 'Max fiyat 0\'dan büyük olmalıdır.';
  static const maxPriceLessThanMin = 'Max fiyat min fiyattan küçük olamaz.';
  static const duplicateProduct =
      'Bu ürün adı ve para birimi kombinasyonu zaten mevcut.';

  static const createSuccess = 'Fiyat listesi oluşturuldu.';
  static const createError = 'Fiyat listesi oluşturulurken bir hata oluştu.';
  static const updateSuccess = 'Fiyat listesi güncellendi.';
  static const updateError = 'Fiyat listesi güncellenirken bir hata oluştu.';
  static const archiveSuccess = 'Fiyat listesi arşivlendi.';
  static const archiveError = 'Fiyat listesi arşivlenirken bir hata oluştu.';
  static const notFound = 'Fiyat listesi bulunamadı.';
  static const notEditable = 'Arşivlenmiş fiyat listeleri düzenlenemez.';
  static const itemCreateSuccess = 'Ürün eklendi.';
  static const itemCreateError = 'Ürün eklenirken bir hata oluştu.';
  static const itemUpdateSuccess = 'Ürün güncellendi.';
  static const itemUpdateError = 'Ürün güncellenirken bir hata oluştu.';
  static const itemDeleteSuccess = 'Ürün silindi.';
  static const itemDeleteError = 'Ürün silinirken bir hata oluştu.';
  static const exportSuccess = 'Fiyat listesi Excel\'e aktarıldı.';
  static const exportError = 'Excel\'e aktarılırken bir hata oluştu.';
  static const exportEmpty = 'Dışa aktarılacak ürün bulunmuyor.';
  static const dateRangeError =
      'Başlangıç tarihi bitiş tarihinden büyük olamaz.';

  static const archiveTitle = 'Fiyat Listesini Arşivle';
  static const archiveBody =
      'Aktif fiyat listesini arşivlemek istediğinize emin misiniz? Arşivlenen listeler düzenlenemez.';
  static const archiveCancel = 'Vazgeç';
  static const archiveConfirm = 'Arşivle';

  static const deleteItemTitle = 'Ürünü Sil';
  static const deleteItemBody =
      'Bu ürünü fiyat listesinden silmek istediğinize emin misiniz?';
  static const deleteItemCancel = 'Vazgeç';
  static const deleteItemConfirm = 'Sil';
}
