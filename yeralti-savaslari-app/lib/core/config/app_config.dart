class AppConfig {
  // cPanel API Base URL (Sunucunuza yüklediğinizde bu adresi güncelleyin)
  static const String cpanelBaseUrl = 'https://siteadresiniz.com/derin_kazi_api/api';

  // İstek zaman aşımı süresi
  static const Duration apiTimeout = Duration(seconds: 8);

  // Canlı polling yenileme aralığı (Lobi & Maç İçi)
  static const Duration lobbyPollingInterval = Duration(milliseconds: 1200);
  static const Duration gameSyncPollingInterval = Duration(milliseconds: 500);

  // Offline toleransı ve bot desteği
  static const bool fallbackToOfflineBotsIfNoServer = true;
}
