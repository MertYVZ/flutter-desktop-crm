/// Turkish messages for the settings module.
abstract final class SettingsMessages {
  static const passwordChanged = 'Şifre başarıyla değiştirildi.';
  static const emptyPasswordFields = 'Tüm alanları doldurun.';
  static const backupSuccess = 'Veritabanı yedeği başarıyla oluşturuldu.';
  static const backupError = 'Yedek oluşturulurken bir hata oluştu.';
  static const restoreSuccess =
      'Yedek başarıyla geri yüklendi. Değişikliklerin uygulanması için uygulamayı kapatıp tekrar açın.';
  static const restoreError = 'Yedek geri yüklenirken bir hata oluştu.';
  static const invalidBackupFile =
      'Lütfen .sqlite uzantılı bir yedek dosyası seçin.';
  static const restoreConfirmTitle = 'Yedekten Geri Yükle';
  static const restoreConfirmBody =
      'Mevcut veriler seçtiğiniz yedek ile değiştirilecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?';
  static const restoreConfirmCancel = 'Vazgeç';
  static const restoreConfirmProceed = 'Devam Et';
  static const concurrentOperation =
      'Başka bir işlem devam ediyor. Lütfen bekleyin.';

  static const pdfSettingsSaved = 'Teklif PDF bilgileri kaydedildi.';
  static const pdfSettingsSaveError =
      'Teklif PDF bilgileri kaydedilirken bir hata oluştu.';
  static const pdfSettingsLoadError =
      'Teklif PDF bilgileri yüklenirken bir hata oluştu.';
  static const pdfSettingsRequiredField = 'Bu alan zorunludur.';
  static const legalTemplateSaved = 'Yasal metin şablonu kaydedildi.';
  static const legalTemplateSaveError =
      'Yasal metin şablonu kaydedilirken bir hata oluştu.';
  static const legalTemplateLoadError =
      'Yasal metin şablonları yüklenirken bir hata oluştu.';
  static const legalTemplateRequired = 'Yasal metin boş olamaz.';
}
