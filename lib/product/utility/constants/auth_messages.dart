/// Turkish auth and validation messages.
abstract final class AuthMessages {
  static const invalidCredentials = 'Kullanıcı adı veya şifre hatalı.';
  static const accountLocked =
      'Hesap kısa süreliğine kilitlendi. Lütfen birkaç dakika sonra tekrar deneyin.';
  static const accountInactive = 'Bu hesap devre dışı bırakılmış.';
  static const passwordChanged = 'Şifreniz başarıyla değiştirildi.';
  static const sessionExpired = 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.';
  static const genericError = 'Bir hata oluştu. Lütfen tekrar deneyin.';
}

abstract final class PasswordValidationMessages {
  static const minLength = 'Şifre en az 8 karakter olmalıdır.';
  static const uppercase = 'Şifre en az 1 büyük harf içermelidir.';
  static const lowercase = 'Şifre en az 1 küçük harf içermelidir.';
  static const digit = 'Şifre en az 1 rakam içermelidir.';
  static const specialChar = 'Şifre en az 1 özel karakter içermelidir.';
  static const mismatch = 'Şifreler eşleşmiyor.';
  static const sameAsOld = 'Yeni şifre eski şifre ile aynı olamaz.';
  static const rulesInfo =
      'Şifreniz en az 8 karakter, 1 büyük harf, 1 küçük harf, 1 rakam ve 1 özel karakter içermelidir.';
}
