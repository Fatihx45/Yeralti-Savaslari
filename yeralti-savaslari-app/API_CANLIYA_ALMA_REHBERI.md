# 🌐 Yeraltı Savaşları - cPanel API Canlıya Alma Rehberi

Bu rehber, **Yeraltı Savaşları (Derin Kazı)** oyununun çok oyunculu (multiplayer), oda sistemi ve arkadaşlık API'sini cPanel sunucunuza yükleyip canlıya almanız için adım adım hazırlanmıştır.

---

## 📁 1. Gereksinimler & Hazır Dosyalar

Projenin içinde yer alan dosyalar:
- **`backend/database.sql`**: MySQL tablolarını oluşturan şema dosyası.
- **`backend/config/database.php`**: Veritabanı bağlantı ve CORS ayarları.
- **`backend/api/auth.php`**: Kullanıcı kayıt, giriş ve profil servisi.
- **`backend/api/rooms.php`**: Çok oyunculu oda kurma, listeleme ve katılma servisi.
- **`backend/api/game_sync.php`**: Oyun içi canlı hasar, can, vuruş ve olay senkronizasyonu.
- **`backend/api/friends.php`**: Arkadaş ekleme, hediyeleşme ve sosyal liste servisi.

---

## 🛠️ 2. Adım Adım Kurulum

### Adım 1: cPanel'de Veritabanı Oluşturma
1. cPanel kontrol panelinize giriş yapın.
2. **Veritabanları (Databases)** başlığı altındaki **MySQL® Veritabanı Sihirbazı (MySQL Database Wizard)** veya **MySQL® Veritabanları** bölümüne tıklayın.
3. Yeni bir veritabanı adı belirleyin (Örnek: `olmeztec_yeralti_savaslari`).
4. Bir veritabanı kullanıcısı ve güçlü bir şifre oluşturun (Örnek Kullanıcı: `olmeztec_yeralti_user`, Şifre: `Fatih369488!` vb.).
5. Kullanıcıyı bu veritabanına ekleyin ve **"Tüm Ayrıcalıklar" (ALL PRIVILEGES)** kutucuğunu işaretleyip kaydedin.

---

### Adım 2: Tabloları İçe Aktarma (phpMyAdmin)
1. cPanel ana sayfasına dönüp **phpMyAdmin**'i açın.
2. Sol menüden az önce oluşturduğunuz veritabanını (`olmeztec_yeralti_savaslari`) seçin.
3. Üst menüdeki **İçe Aktar (Import)** sekmesine tıklayın.
4. **Dosya Seç** butonuna tıklayarak projenizdeki `backend/database.sql` dosyasını seçin.
5. Sayfanın en altındaki **İçe Aktar (Go)** butonuna tıklayın.
   - Aşağıdaki 5 tablonun başarıyla oluştuğunu göreceksiniz:
     - `players`
     - `rooms`
     - `room_players`
     - `game_events`
     - `friends`

---

### Adım 3: Dosyaları Sunucuya Yükleme (Dosya Yöneticisi / File Manager)
1. cPanel -> **Dosya Yöneticisi (File Manager)** bölümünü açın.
2. API için kullanmak istediğiniz dizine gidin:
   - **Subdomain kullanıyorsanız** (Örn: `api.yeraltisavaslari.olmeztech.com.tr`): İlgili subdomain klasörünün içine girin.
   - **Ana site altında kullanıyorsanız**: `public_html/api/` klasörü oluşturup içine girin.
3. Projedeki `backend/` klasörünün içindeki iki klasörü yükleyin:
   - `config/`
   - `api/`

---

### Adım 4: Veritabanı Bilgilerini Düzenleme
Sunucudaki `config/database.php` dosyasını sağ tıklayıp **Edit (Düzenle)** deyin ve Adım 1'de oluşturduğunuz bilgileri yazın:

```php
    private $host = "localhost";
    private $db_name = "olmeztec_yeralti_savaslari"; // Sizin oluşturduğunuz DB adı
    private $username = "olmeztec_yeralti_user";    // Sizin DB kullanıcınız
    private $password = "Fatih369488!";             // Sizin belirlediğiniz DB şifresi
```
Kaydedip kapatın.

---

### Adım 5: SSL (HTTPS) ve Canlı Test
1. cPanel -> **SSL/TLS Durumu** bölümünden ilgili adres için ücretsiz **AutoSSL (Let's Encrypt / cPanel SSL)** kurulu olduğunu doğrulayın. Mobil uygulamalar güvenli bağlantı (`https://`) zorunlu tutar.
2. Tarayıcınızı açıp şu adrese gidin:
   `https://api.yeraltisavaslari.olmeztech.com.tr/api/auth.php`
3. Ekranda şu şekilde bir JSON çıktısı görüyorsanız API'niz canlıda ve sorunsuz çalışıyor demektir:
   ```json
   {
     "success": false,
     "message": "Geçersiz istek metodu. POST veya GET bekleniyor.",
     "data": null,
     "timestamp": 1726929999
   }
   ```

---

### Adım 6: Flutter Uygulaması ile Eşleştirme
Flutter uygulamanızda `lib/core/config/app_config.dart` dosyasını açın ve `cpanelBaseUrl` değerinin canlı adresinizle aynı olduğundan emin olun:

```dart
class AppConfig {
  static const String cpanelBaseUrl = 'https://api.yeraltisavaslari.olmeztech.com.tr/api';
  ...
}
```

Tebrikler! Canlı API entegrasyonunuz tamamlandı.
