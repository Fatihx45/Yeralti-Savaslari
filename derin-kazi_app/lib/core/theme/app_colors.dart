import 'package:flutter/material.dart';

/// Yeraltı Savaşları Resmi Logo Uyumlu Renk Paleti
/// (Volkanik Obsidyen, Akkor Lav Turuncusu, Dövme Çelik & Antik Altın)
class AppColors {
  AppColors._();

  // 🌋 Ana Zeminler & Obsidyen Taş Tonları
  static const Color background = Color(0xFF0E0A14); // Derin Volkanik Obsidyen
  static const Color hudPanel = Color(0xFF161120);   // Yontulmuş Bazalt Taşı
  static const Color shopPanel = Color(0xFF1B1426);  // Karanlık Ocak / Maden Taşı
  static const Color panelBox = Color(0xFF241C33);   // Koyu Taş Çerçeve Kutusu

  // 🔥 Akkor Lav & Kor Ateşi Vurguları (Logodaki Alev & Çatlak Lavları)
  static const Color lavaOrange = Color(0xFFFF5722); // Akkor Lav Turuncusu
  static const Color lavaFlame = Color(0xFFFF3D00);  // Kor Ateşi Kızılı
  static const Color lavaGlow = Color(0xFFFF8A50);   // Parlayan Lav Işıltısı
  static const Color resetRed = Color(0xFFFF2A00);   // Sıfırla / Tehlike Kızılı

  // ⚔️ Dövme Çelik & Antik Altın / Bronz (Logodaki Harfler, Kılıç ve Kazma)
  static const Color goldText = Color(0xFFFFB300);   // Antik Dövme Altın
  static const Color goldOre = Color(0xFFFFD54F);    // Parlak Altın Damarı
  static const Color steelLight = Color(0xFFCFD8DC); // Parlak Savaş Çeliği
  static const Color steelGray = Color(0xFF78909C);  // Dövme Çelik Grisi

  // 💎 Büyülü Kristal & Zümrüt Madenleri (Kontrast Renkler)
  static const Color neonGreen = Color(0xFF00E676);  // Parlayan Zümrüt Yeşili
  static const Color neonGreenAccent = Color(0xFF69F0AE);
  static const Color cyanText = Color(0xFF00E5FF);   // Büyülü Elmas Camgöbeği

  // 🟫 Maden ve Zemin Tonları
  static const Color soilGround = Color(0xFF6E3214); // Kızıl Maden Toprağı
  static const Color tileFrame = Color(0xFF421515);  // Koyu Kor Taş Çerçevesi
  static const Color tileRock = Color(0xFF5A2210);   // Sert Volkanik Kaya
  static const Color emptyTile = Color(0xFF08060B);  // Kazılmış Derin Boşluk

  // 📝 Metin ve Rozet Renkleri
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0A4C0);
  static const Color levelBarEmpty = Color(0xFF261D36);
  static const Color levelBarFill = Color(0xFFFF5722);
  static const Color progressFill = Color(0xFFFFB300);
  static const Color badgeRed = Color(0xFFFF3D00);
  static const Color badgeGreen = Color(0xFF00E676);
}
