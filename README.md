# Sivas Akıllı Durak Uygulaması 🚌

Sivas Belediyesi akıllı durak verilerini kullanarak otobüs varış sürelerini gösteren mobil uygulama.

## Özellikler

- 📍 Yakındaki durakları konum bazlı listeleme
- 🚌 Gerçek zamanlı otobüs varış süreleri
- 🗺️ Harita üzerinde durak görüntüleme
- 🎨 Özelleştirilebilir tema renkleri
- 🔄 Otomatik yenileme özelliği

## Ekran Görüntüleri

*Yakında eklenecek*

## Kurulum

### Gereksinimler
- Flutter SDK 3.10+
- Android Studio / VS Code
- Android veya iOS cihaz/emülatör

### Adımlar

```bash
# Repoyu klonla
git clone https://github.com/furkansa50/sivasbus.git
cd sivasbus

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

## Kullanılan Teknolojiler

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **flutter_map** - OpenStreetMap entegrasyonu
- **Geolocator** - Konum servisleri
- **HTTP/HTML** - Web scraping

## Veri Kaynağı

Uygulama, [Sivas Belediyesi Akıllı Duraklar](https://ulasim.sivas.bel.tr/Akilli-Duraklar-Liste) sayfasından veri çekmektedir.

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Commit edin (`git commit -m 'Yeni özellik eklendi'`)
4. Push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request açın

---

*Sivas Belediyesi ile resmi bir bağlantısı yoktur.*
