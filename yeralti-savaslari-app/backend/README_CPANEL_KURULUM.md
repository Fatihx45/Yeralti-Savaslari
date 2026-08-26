# 🌐 Yeraltı Savaşları - cPanel Backend Kurulum Kılavuzu

Bu belge, oyununuzun Multiplayer ve Sosyal Sistem Backend'ini **cPanel** barındırma hesabınıza 3 adımda nasıl kuracağınızı anlatır.

---

## 📌 Adım 1: MySQL Veritabanı Oluşturma

1. cPanel panelinize giriş yapın.
2. **"MySQL® Veritabanı Sihirbazı" (MySQL Database Wizard)** ikonuna tıklayın.
3. Bir veritabanı adı belirleyin (Örn: `siteadi_derinkazi`).
4. Bir kullanıcı adı ve güçlü bir şifre oluşturun (Örn: `siteadi_dbuser` / `GucluSifre123!`).
5. Kullanıcıya **"TÜM AYRICALIKLAR" (ALL PRIVILEGES)** yetkisini verip kaydedin.

---

## 🗄️ Adım 2: Veritabanı Şemasını Yükleme (`database.sql`)

1. cPanel ana sayfasından **"phpMyAdmin"** aracını açın.
2. Sol menüden 1. adımda oluşturduğunuz veritabanını seçin.
3. Üst menüden **"İçe Aktar" (Import)** sekmesine tıklayın.
4. Bu klasördeki `database.sql` dosyasını seçin ve en alttaki **"İçe Aktar"** butonuna basın.
5. `players`, `rooms`, `room_players`, `friends`, `game_events` tabloları başarıyla oluşturulacaktır.

---

## 📁 Adım 3: Dosyaları Sunucuya Yükleme & Yapılandırma

1. cPanel **"Dosya Yöneticisi" (File Manager)** aracını açın.
2. `public_html/` dizinine gidin ve `derin_kazi_api` adında yeni bir klasör oluşturun.
3. `backend/` klasörü içindeki `config/` ve `api/` klasörlerini buraya yükleyin:
   ```
   public_html/
   └── derin_kazi_api/
       ├── config/
       │   └── database.php
       └── api/
           ├── auth.php
           ├── friends.php
           ├── rooms.php
           └── game_sync.php
   ```
4. `config/database.php` dosyasını açıp 1. Adımda belirlediğiniz bilgileri girin:
   ```php
   private string $host = "localhost";
   private string $db_name = "siteadi_derinkazi";
   private string $username = "siteadi_dbuser";
   private string $password = "GucluSifre123!";
   ```
5. Kaydedin. Artık backend API adresiniz:
   👉 `https://siteadresiniz.com/derin_kazi_api/api/`

---

## 📱 Flutter Uygulamasını Sunucunuza Bağlama:
`lib/core/config/app_config.dart` dosyasını açıp kendi site adresinizi yazmanız yeterlidir:
```dart
static const String cpanelBaseUrl = 'https://siteadresiniz.com/derin_kazi_api/api';
```
