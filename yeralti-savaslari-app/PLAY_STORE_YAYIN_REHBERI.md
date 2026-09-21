# 🚀 Yeraltı Savaşları - Google Play Store Yayına Hazırlık Rehberi

Bu rehber, **Yeraltı Savaşları** uygulamasının Google Play Console'a yüklenip mağazada yayınlanması için gereken tüm teknik gereksinimleri, anket cevaplarını ve adımları içermektedir.

---

## 📌 1. Temel Uygulama Bilgileri
- **Uygulama Adı:** Yeraltı Savaşları
- **Paket Adı (Application ID):** `tr.com.olmeztech.yeraltisavaslari`
- **Sürüm:** **5 (1.0.2)**
  - *Sürüm Adı:* `1.0.2`
  - *Sürüm Kodu (Build Number):* `5`
- **İmza Dosyası:** `android/app/upload-keystore.jks`
- **İmza Şifresi:** `olmeztech123456` (Alias: `upload`)
- **Üretilen Paket:** `build/app/outputs/bundle/release/app-release.aab` (Google Play App Bundle)

---

## 🎨 2. Mağaza Görselleri & Grafik Varlıkları

Projenin içinde hazır olarak bulunan materyaller:
1. **Özellik Grafiği (Feature Graphic - 1024x500):**
   - Yol: `TANITIM FOTOĞRAFLARI/ozellik_grafigi_1024x500.jpg`
2. **Telefon Ekran Görüntüleri (Screenshots):**
   - Yol: `TANITIM FOTOĞRAFLARI/TELEFON/` klasöründeki yatay oyun görselleri.
3. **Tablet Ekran Görüntüleri (İsteğe bağlı ama önerilir):**
   - Yol: `TANITIM FOTOĞRAFLARI/TABLET/` klasöründeki tablet görselleri.
4. **Uygulama Simgesi (App Icon - 512x512):**
   - 512x512 PNG formatında şeffaf olmayan logo.

---

## 📋 3. Google Play Console Formları & Cevapları

### A. Veri Güvenliği (Data Safety)
- **Uygulama veri topluyor mu?** -> **Evet** (Google AdMob nedeniyle).
- **Hangi veriler toplanıyor?**
  - **Cihaz veya diğer kimlikler:** Reklam kimliği (Advertising ID / AdMob).
- **Veriler aktarılırken şifreleniyor mu?** -> **Evet** (HTTPS / TLS).
- **Kullanıcıların veri silme talebi için yöntem var mı?** -> **Evet** (veya e-posta destek adresi).

### B. İçerik Derecelendirmesi (IARC Anketi)
- **Kategori:** Oyun
- **Şiddet:** Hafif piksel / madencilik blok kazma (Kan, vahşet içermez).
- **Cinsellik / Korku:** Hayır.
- **Kumar / Bahis:** Hayır.
- *Sonuç Genellikle: PEGI 3 veya PEGI 7 (Her yaşa uygun)*.

### C. Hedef Kitle (Target Audience)
- **Yaş Grubu:** 13 yaş ve üzeri (veya tüm yaşlar seçilecekse COPPA/Aile politikalarına uygun AdMob etiketi). Tavsiye edilen: 13-17 ve 18+.

### D. Reklamlar
- **Uygulamanız reklam içeriyor mu?** -> **Evet, uygulamamda reklam var** (Google AdMob banner ve geçiş reklamları).

### E. Gizlilik Politikası (Privacy Policy)
- Google Play bir gizlilik politikası URL'i zorunlu tutar.
- Örnek: `https://olmeztech.com.tr/gizlilik-politikasi.html` (AdMob veri kullanımı beyanı içeren basit bir web sayfası).

---

## 📦 4. AAB Dosyasını Yükleme Adımları
1. **Google Play Console**'a giriş yapın (`play.google.com/console`).
2. Uygulamanızı seçin (veya "Uygulama Oluştur" deyin).
3. Sol menüden **Üretim (Production)** veya **Kapalı Test (Closed Testing)** seçeneğine gidin.
4. **Yeni Sürüm Oluştur (Create New Release)** butonuna tıklayın.
5. `yeralti-savaslari-app/build/app/outputs/bundle/release/app-release.aab` dosyasını sürükleyip yükleyin.
6. Sürüm adı otomatik olarak **5 (1.0.2)** olacaktır.
7. Sürüm notlarına:
   `Yeni Sanal Joystick kontrolleri eklendi, çok oyunculu madencilik ve performans iyileştirmeleri yapıldı.` yazın.
8. Kaydedip incelemeye gönderin!
