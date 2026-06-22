import 'package:Ok/feature/price_offers/models/offer_type.dart';

/// Built-in legal text bodies seeded on first migration to legal_text_templates.
const defaultLegalTextTemplates = <OfferType, String>{
  OfferType.okTeknik: '''
Bu teklif, teklif tarihinden itibaren 7 gün süreyle geçerlidir . Fiyat, hurda cinsi, miktarı ve saflık oranına göre revize edilebilir .
Yükleme ve nakliye işlemleri firmamız tarafından yapılacaktır . Tartım işlemi, satıcı firma üzerinden yapılacak olup, tartım fişi esas
alınacaktır . Ödeme, hurda teslimi ve tartım sonrası aynı gün yapılacaktır . Bu teklif, sadece belirtilen hurda malzemeler için
geçerlidir; ek ürünler veya farklı cinsler ayrıca değerlendirilir . Hurda malzemelerin içinde tehlikeli, yanıcı veya çevreye zararlı
madde bulunmaması gerekmektedir .
Ok Teknik Metal; bütün teklif süreçlerinde "REVİZE, DEĞİŞİKLİK ve İPTAL" haklarını kendi bünyesinde saklı tutar .''',
  OfferType.dengTools: '''
Yukarıda belirtilen fiyatlar peşin ödeme için geçerli ve KDV hariç olup, teklif tarihinden itibaren 7 gün geçerlidir . KDV oranı %20'dir .
Sipariş onayının ardından yaklaşık 1-3 iş günü içerisinde teslimat yapılacaktır . Stok dışı ürünlerde termin süresi ayrıca
bildirilecektir . Nakliye masrafları alıcı tarafından karşılanacaktır . Kargo hasarlarından firmamız sorumlu değildir , teslimat sırasında
paketi mutlaka kontrol ediniz.
Ok Teknik Metal; bütün teklif süreçlerinde "REVİZE, DEĞİŞİKLİK ve İPTAL" haklarını kendi bünyesinde saklı tutar .''',
  OfferType.vizviz: '''
NOT: Ürünlerimiz Kore menşeilidir .
Ürünlerimize çalışma garantisi veriyoruz. Memnun kalmadığınız takdirde, iade garantilidir .
Yukarıda belirtilen fiyatlar 2 AY VADELİ ödeme için geçerli ve KDV hariç olup, teklif tarihinden itibaren 7 gün geçerlidir . KDV oranı
%20'dir . Sipariş onayının ardından yaklaşık 1-3 iş günü içerisinde teslimat yapılacaktır . Stok dışı ürünlerde termin süresi ayrıca
bildirilecektir . Nakliye masrafları alıcı tarafından karşılanacaktır . Kargo hasarlarından firmamız sorumlu değildir , teslimat sırasında
paketi mutlaka kontrol ediniz.
Ok Teknik Metal; bütün teklif süreçlerinde "REVİZE, DEĞİŞİKLİK ve İPTAL" haklarını kendi bünyesinde saklı tutar .''',
  OfferType.general: '''
Bu teklif, teklif tarihinden itibaren 7 gün süreyle geçerlidir . Fiyat, hurda cinsi, miktarı ve saflık oranına göre revize edilebilir .
Yükleme ve nakliye işlemleri firmamız tarafından yapılacaktır . Tartım işlemi, satıcı firma üzerinden yapılacak olup, tartım fişi esas
alınacaktır . Ödeme, hurda teslimi ve tartım sonrası aynı gün yapılacaktır . Bu teklif, sadece belirtilen hurda malzemeler için
geçerlidir; ek ürünler veya farklı cinsler ayrıca değerlendirilir . Hurda malzemelerin içinde tehlikeli, yanıcı veya çevreye zararlı
madde bulunmaması gerekmektedir .
Ok Teknik Metal; bütün teklif süreçlerinde "REVİZE, DEĞİŞİKLİK ve İPTAL" haklarını kendi bünyesinde saklı tutar .''',
};
