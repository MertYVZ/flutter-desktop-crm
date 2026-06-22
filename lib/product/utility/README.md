# Auth Helper Kullanım Kılavuzu

## Genel Bakış

`AuthHelper` sınıfı, uygulamanın her yerinde kullanıcı bilgilerini güvenli bir şekilde almak için tasarlanmıştır. Error durumunda otomatik olarak token'ı siler ve kullanıcıyı login ekranına yönlendirir.

## Özellikler

- ✅ Bloc tabanlı state management
- ✅ Otomatik error handling
- ✅ Token süresi dolduğunda otomatik temizlik
- ✅ Login ekranına otomatik yönlendirme
- ✅ Type-safe kullanım
- ✅ Her seferinde fresh data (cache yok)
- ✅ API'den güncel profil bilgileri

## Kullanım Örnekleri

### 1. Basit Kullanım

```dart
// Widget içinde kullanım
class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginViewModel, LoginState>(
      builder: (context, state) {
        if (state is GetUserLoading) {
          return CircularProgressIndicator();
        } else if (state is GetUserSuccess) {
          return Text('Hoş geldin ${state.user.name}');
        } else if (state is AuthTokenExpired) {
          return Text('Oturum süreniz dolmuş');
        }
        return Text('Kullanıcı bilgileri yükleniyor...');
      },
    );
  }
}
```

### 2. Helper Method ile Kullanım

```dart
// AuthHelper ile kullanım
class SomeService {
  Future<void> loadUserData(BuildContext context) async {
    final user = await AuthHelper.getUserDataAsync(context);
    
    if (user != null) {
      // Kullanıcı bilgileri başarıyla alındı
      print('Kullanıcı: ${user.name}');
    } else {
      // Hata oluştu veya token süresi doldu
      print('Kullanıcı bilgileri alınamadı');
    }
  }
}
```

### 3. Event Tetikleme

```dart
// Manuel olarak getUser event'ini tetikleme
class SomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<LoginViewModel>().add(const GetUserRequested());
      },
      child: Text('Kullanıcı Bilgilerini Getir'),
    );
  }
}
```

## State'ler

### GetUserLoading
- Kullanıcı bilgileri alınırken gösterilir

### GetUserSuccess
- Kullanıcı bilgileri başarıyla alındığında
- `user` property'si ile kullanıcı bilgilerine erişim

### GetUserFailure
- Genel hata durumlarında
- `message` ve `errorCode` property'leri ile hata detayları

### AuthTokenExpired
- Token süresi dolduğunda
- Otomatik olarak token'lar temizlenir
- Login ekranına yönlendirme yapılır

## Error Handling

Sistem otomatik olarak şu durumları handle eder:

1. **401 Unauthorized**: Token geçersiz
2. **403 Forbidden**: Token süresi dolmuş
3. **Network Error**: İnternet bağlantı hatası
4. **Server Error**: Sunucu hatası

Tüm error durumlarında kullanıcıya uygun mesaj gösterilir ve gerekirse login ekranına yönlendirme yapılır.

## Güvenlik

- Token'lar güvenli bir şekilde cache'den silinir
- Error durumunda tüm auth bilgileri temizlenir
- Kullanıcı otomatik olarak login ekranına yönlendirilir
- Profil bilgileri her seferinde API'den çekilir (güncel veri)
- Local cache kullanılmaz (güvenlik ve tutarlılık için)
