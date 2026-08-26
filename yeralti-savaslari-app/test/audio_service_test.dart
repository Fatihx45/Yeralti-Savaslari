import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/core/audio/audio_service.dart';
import 'package:derin_kazi/features/mining/domain/models/weapon_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioService.isTestMode = true;

  group('AudioService Ses Motoru Testleri', () {
    test('AudioService singleton örneği başarıyla başlatılmalı', () {
      final audio1 = AudioService();
      final audio2 = AudioService();
      expect(identical(audio1, audio2), true);
    });

    test('updateSettings ses seviyelerini doğru sınırlandırmalı', () {
      final audio = AudioService();
      audio.updateSettings(enabled: false, sfxVol: 1.5, musicVol: -0.2);

      expect(audio.soundEnabled, false);
      expect(audio.sfxVolume, 1.0);
      expect(audio.musicVolume, 0.0);
    });

    test('Ses çalma metotları sessiz modda hatasız çalışmalı', () {
      final audio = AudioService();
      audio.updateSettings(enabled: false, sfxVol: 0.0, musicVol: 0.0);

      expect(() => audio.playDig(), returnsNormally);
      expect(() => audio.playShoot(WeaponType.pistol), returnsNormally);
      expect(() => audio.playShoot(WeaponType.rifle), returnsNormally);
      expect(() => audio.playShoot(WeaponType.shotgun), returnsNormally);
      expect(() => audio.playShoot(WeaponType.laserGun), returnsNormally);
      expect(() => audio.playShoot(WeaponType.rocketLauncher), returnsNormally);
      expect(() => audio.playExplosion(), returnsNormally);
      expect(() => audio.playGold(), returnsNormally);
      expect(() => audio.playHit(), returnsNormally);
      expect(() => audio.playEnemyRoar(), returnsNormally);
      expect(() => audio.playUpgrade(), returnsNormally);
      expect(() => audio.playStageClear(), returnsNormally);
      expect(() => audio.playHurt(), returnsNormally);
      expect(() => audio.playClick(), returnsNormally);
      expect(() => audio.startBgm(), returnsNormally);
      expect(() => audio.stopBgm(), returnsNormally);
    });
  });
}
