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

### 1. Flutter SDK Kurulumu

#### Linux
```bash
# Flutter SDK'yı indir
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# PATH'e ekle (~/.bashrc veya ~/.zshrc dosyasına ekle)
export PATH="$PATH:$HOME/flutter/bin"

# Değişiklikleri uygula
source ~/.bashrc
```

#### Windows
1. [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) indir
2. `C:\flutter` klasörüne çıkar
3. Sistem Ortam Değişkenleri → Path → `C:\flutter\bin` ekle

#### macOS
```bash
# Homebrew ile
brew install --cask flutter

# Veya manuel
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
```

### 2. Kurulumu Doğrula
```bash
flutter doctor
```
Tüm bileşenlerin yeşil tik (✓) gösterdiğinden emin ol.

### 3. Projeyi Klonla ve Çalıştır
```bash
# Repoyu klonla
git clone https://github.com/furkansa50/sivasbus.git
cd sivasbus

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır (debug mode)
flutter run
```

### 4. Release Build Oluşturma

#### Android APK
```bash
# APK oluştur
flutter build apk --release

# Çıktı: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (Play Store için)
```bash
flutter build appbundle --release

# Çıktı: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS gerekir)
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release

# Çıktı: build/web/
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
