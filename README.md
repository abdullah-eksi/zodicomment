
---

# ZodiComment 🔮✨

**Burç, Fal ve Rüya Yorum Asistanı**

ZodiComment, yapay zekâ destekli burç yorumları  kişisel fal ve hayat tavsiyeleri sunar.
Hem eğlenceli hem de mistik bir sohbet deneyimi yaşatır.

![ZodiComment Logo](assets/images/maskot.png)

## 📱 Özellikler


* **Farklı tonlarda yanıtlar** (eğlenceli, romantik, bilge, eleştirel)
* **Sohbet arayüzü** ile kolay kullanım
* **Hesap sistemi** ve güvenli saklanan sohbet geçmişi
* **Çoklu platform desteği** (Android, iOS, Web, Desktop)
* **Karanlık tema** ile göz yormayan tasarım

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler

- **Flutter**: Çoklu platform desteği için Flutter framework'ü
- **Dart**: Uygulama geliştirme dili
- **Google Gemini API**: Yapay zeka destekli yanıtlar için
- **SQLite**: Yerel veritabanı desteği
- **Provider**: Durum yönetimi
- **Flutter Secure Storage**: Hassas verilerin güvenli saklanması

### Proje Yapısı

```
lib/
├── main.dart           # Uygulama başlangıç noktası
├── routes.dart         # Yönlendirme ve rota yönetimi
├── model/             
│   ├── databaseModel.dart # Veritabanı işlemleri
│   ├── messageModel.dart  # Mesaj yönetimi
│   └── userModel.dart     # Kullanıcı modeli ve kimlik doğrulama
├── service/
│   └── gemini.dart     # Gemini AI API entegrasyonu
├── view/
│   ├── components/     # Yeniden kullanılabilir UI bileşenleri
│   └── pages/          # Uygulama sayfaları
└── viewmodel/          # Sayfa durum yönetimi
```


## 🔧 Teknolojiler

* Flutter & Dart
* Google Gemini API
* SQLite
* Provider

## 🚀 Kurulum

1. Projeyi klonla:

   ```bash
   git clone https://github.com/username/zodicomment.git
   cd zodicomment
   ```

2. Paketleri yükle:

   ```bash
   flutter pub get
   ```

3. `.env` içine Gemini API anahtarını ekle.

4. Çalıştır:

   ```bash
   flutter run
   ```

## 📦 Derleme

* Android: `flutter build apk --release`
* iOS: `flutter build ipa --release`
* Masaüstü: `flutter build windows --release`

## 👨‍💻 Geliştirici

Abdullah Ekşi tarafından geliştirildi.

## 📄 Lisans

MIT Lisansı. Daha fazla bilgi için [LICENSE](LICENSE).

