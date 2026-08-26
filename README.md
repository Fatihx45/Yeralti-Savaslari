# ⛏️ Yeraltı Savaşları (Underground Wars)
### *500 Katmanlı Derin Madencilik, Battle Royale & Eşli Mücadele*

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.5-40c4ff?style=for-the-badge)](https://riverpod.dev)
[![PHP](https://img.shields.io/badge/Backend-PHP_8.x-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/Database-MySQL_8.x-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://mysql.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-green?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Yeraltı Savaşları</b>; derin maden katmanlarına doğru kazı yaparak değerli cevherler topladığınız, ölümcül yer altı yaratıkları ve Titan bosslar ile savaştığınız, 9 kişilik AI madenci takımı kurduğunuz ve gerçek zamanlı <b>Battle Royale / Eşli (Co-op)</b> modlarda rekabet ettiğiniz kapsamlı bir mobil & çapraz platform oyunudur.
</p>

[🎮 Özellikler](#-öne-çıkan-özellikler) • [🏗️ Proje Mimarisi](#️-proje-mimarisi) • [🛠️ Teknolojiler](#️-kullanılan-teknolojiler) • [🚀 Hızlı Başlangıç](#-hızlı-başlangıç) • [🌐 Web Vitrini](#-web-tanıtım-sitesi) • [⚙️ Backend Kurulumu](#️-backend--api-kurulumu)

---

</div>

## 🌟 Öne Çıkan Özellikler

### ⛏️ 1. 500 Katmanlı Prosedürel Madencilik
- **10 Farklı Eşsiz Biyom:** Yüzey toprağından Kadim Çekirdeğe, Magma Odalarından Kristal Mağaralarına kadar kademeli derinlik seviyeleri.
- **Dinamik Izgara ve Fizik:** Her katmanda değişen sertlik katsayıları, patlayıcı gaz cepleri, lav sızıntıları ve gizli hazine sandıkları.
- **Cevher ve Kaynak Çeşitliliği:** Kömür, Bakır, Demir, Altın, Elmas, Zümrüt, Obsidyen ve Efsanevi Kristaller.

### ⚔️ 2. Battle Royale & Eşli (Co-op) Çok Oyunculu Mod
- **1v1 ve Çok Oyunculu Arena:** Yeraltında hayatta kalan son madenci olmak için kıyasıya mücadele edin.
- **Eş Zamanlı Senkronizasyon:** cPanel / REST API mimarisi üzerinden oda kurma, odaya katılma, arkadaş davet etme ve liderlik tablosu.
- **Dinamik Tehditler:** Yükselen lav seviyesi ve daralan güvenli bölge mekanikleri.

### 🤖 3. 9 Kişilik AI Takımı & Otomasyon
- Otomasyon destekli yapay zekâ madenci ekibi (Kazıcı, Taşıyıcı, Koruyucu, Kaşif vb.).
- Çevrimdışı ve çevrimiçi maden çıkarma desteğiyle pasif gelir ve filo yönetimi.

### 🔨 4. Demirhane (Forge) & Gelişmiş Teçhizat Ağacı
- Kazmalar, Matkaplar, Lazer Kazıcılar ve Plazma Kesiciler.
- Zırh setleri, oksijen tüpleri, dinamitler, maden radarları ve büyülemeler (Enchantments).
- Silah dükkanı ve eşya geliştirme istasyonları.

### 🎯 5. Günlük Görevler, Başarımlar & Özelleştirme
- Dinamik günlük görev zincirleri ve ödül kasaları.
- Farklı madenci kostümleri, ekipman kaplamaları ve profil istatistik kartları.

---

## 🏗️ Proje Mimarisi

Repository, mobil oyun istemcisi, web tanıtım sitesi ve bağımsız backend API'sini içeren monorepo düzenine sahiptir:

```plaintext
Yeralti-Savaslari/
│
├── 📱 yeralti-savaslari-app/      # Flutter Mobil & Masaüstü Uygulaması
│   ├── lib/
│   │   ├── core/                  # Temel yapılandırma, temalar, ses yöneticisi
│   │   ├── features/
│   │   │   ├── mining/            # Kazı ızgarası, modeller, forge, dükkan
│   │   │   ├── multiplayer/       # Çok oyunculu oda yönetimi, lobi, pvp/co-op
│   │   │   ├── profile/           # Oyuncu profili, istatistikler
│   │   │   ├── quests/            # Günlük görev mekanikleri
│   │   │   ├── settings/          # Ayarlar ve ses kontrolleri
│   │   │   └── splash/            # Açılış ve lav parçacık animasyonları
│   │   └── main.dart              # Uygulama giriş noktası
│   ├── assets/                    # Görseller, ikonlar, SFX ve BGM sesleri
│   ├── backend/                   # cPanel PHP REST API kaynak dosyaları
│   └── pubspec.yaml               # Flutter bağımlılıkları
│
├── 🌐 yeralti-savaslari-web/      # Modern Tanıtım ve Pazarlama Web Sitesi
│   ├── css/                       # Cyberpunk / Yeraltı temalı stiller
│   ├── js/                        # Parçacık motoru, filtreleme ve etkileşimler
│   ├── img/                       # Ekran görüntüleri, logo ve medya varlıkları
│   ├── index.html                 # Ana vitrin & indirme sayfası
│   └── gizlilik-politikasi.html   # Mağaza gereksinimleri Gizlilik Politikası
│
├── 📄 .gitignore                  # Kapsamlı Git yoksayma kuralları
└── 📄 README.md                   # Proje dokümantasyonu
```

---

## 🛠️ Kullanılan Teknolojiler

| Katman | Teknoloji / Kütüphane | Açıklama |
|---|---|---|
| **Mobil UI & Engine** | Flutter 3.10+ / Dart 3 | Yüksek performanslı çapraz platform oyun arayüzü |
| **State Management** | Flutter Riverpod 2.5+ | Reaktif ve ayrıştırılmış durum yönetimi |
| **Ses & Efekt** | Audioplayers 6.0+ | Arka plan müzikleri, kazı ve patlama SFX'leri |
| **Veri Depolama** | SharedPreferences | Yerel oyuncu verileri, ayarlar ve envanter kaydı |
| **Ağ & API** | HTTP Client | REST API üzerinden oda ve durum senkronizasyonu |
| **Backend** | PHP 8.x + MySQL 8.x | cPanel uyumlu RESTful mikro servisler |
| **Web Sitesi** | HTML5 / CSS3 / Vanilla JS | Canvas kıvılcım efektli responsive tanıtım sitesi |

---

## 🚀 Hızlı Başlangıç

### 1. Ön Koşullar
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.4 veya üzeri)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code (Flutter & Dart eklentileri kurulu)
- Fiziksel cihaz veya Emülatör

### 2. Projeyi Klonlama
```bash
git clone https://github.com/Fatihx45/Yeralti-Savaslari.git
cd Yeralti-Savaslari/yeralti-savaslari-app
```

### 3. Bağımlılıkları Yükleme ve Çalıştırma
```bash
# Paketleri indir
flutter pub get

# Testleri çalıştır
flutter test

# Cihazda başlat (Debug)
flutter run
```

---

## ⚙️ Backend & API Kurulumu

Oyunun çok oyunculu ve arkadaşlık özelliklerini kendi sunucunuzda çalıştırmak için:

1. **MySQL Veritabanı:** Sunucunuzda (cPanel/DirectAdmin/VPS) yeni bir MySQL veritabanı oluşturun.
2. **Şema Yükleme:** `yeralti-savaslari-app/backend/database.sql` dosyasını phpMyAdmin üzerinden içe aktarın.
3. **API Dosyaları:** `backend/api/` ve `backend/config/` klasörlerini sunucunuzun `public_html/derin_kazi_api/` dizinine yükleyin.
4. **Veritabanı Ayarı:** `config/database.php` içindeki veritabanı kullanıcı adı ve şifresini güncelleyin.
5. **Uygulama Bağlantısı:** `lib/core/config/app_config.dart` dosyasındaki `cpanelBaseUrl` değerini kendi API adresinizle güncelleyin:
   ```dart
   static const String cpanelBaseUrl = 'https://siteadresiniz.com/derin_kazi_api/api';
   ```

---

## 🌐 Web Tanıtım Sitesi

Projenin web vitrini `yeralti-savaslari-web/` klasöründe yer alır. Doğrudan herhangi bir statik web sunucusunda (GitHub Pages, Netlify, Vercel, cPanel) çalıştırılabilir:

- **Canlı Önizleme:** `yeralti-savaslari-web/index.html` dosyasını tarayıcınızda açmanız yeterlidir.
- **Özellikler:** Dinamik canvas ateş böceği/kıvılcım parçacıkları, biyom kartları, galeri lightbox'ı, sesli efekt entegrasyonu ve mobil uyumlu responsive tasarım.

---

## 🧪 Testler

Oyun mantığı, envanter, demirhane yükseltmeleri ve çok oyunculu modeller için yazılmış testleri çalıştırmak için:

```bash
cd yeralti-savaslari-app
flutter test
```

Tüm test paketleri:
- `game_logic_test.dart`
- `forge_upgrade_test.dart`
- `ai_team_mining_test.dart`
- `multiplayer_logic_test.dart`
- `friends_system_test.dart`
- `cpanel_backend_integration_test.dart`

---

## 🤝 Katkıda Bulunma

1. Bu depoyu Fork'layın (`Fork` butonuna basın)
2. Yeni bir Özellik Dalı oluşturun (`git checkout -b feature/HarikaOzellik`)
3. Değişikliklerinizi commit'leyin (`git commit -m 'feat: Yeni bir maden tipi eklendi'`)
4. Dalınıza push yapın (`git push origin feature/HarikaOzellik`)
5. Bir **Pull Request (PR)** açın

---

## 📜 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır. Detaylar için lisans dosyasına göz atabilirsiniz.

<div align="center">
  <sub>Geliştirici: <b>Fatihx45</b> • Yeraltı Savaşları Ekibi © 2026</sub>
</div>
