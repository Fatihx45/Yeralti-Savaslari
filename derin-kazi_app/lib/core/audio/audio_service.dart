import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/mining/domain/models/weapon_model.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static bool isTestMode = false;

  AudioPlayer? _bgmPlayer;

  bool soundEnabled = true;
  double sfxVolume = 1.0;
  double musicVolume = 0.8;
  bool _isBgmPlaying = false;

  AudioPlayer? _getOrCreateBgmPlayer() {
    if (isTestMode) return null;
    try {
      _bgmPlayer ??= AudioPlayer();
      return _bgmPlayer;
    } catch (_) {
      return null;
    }
  }

  void updateSettings({
    required bool enabled,
    required double sfxVol,
    required double musicVol,
  }) {
    soundEnabled = enabled;
    sfxVolume = sfxVol.clamp(0.0, 1.0);
    musicVolume = musicVol.clamp(0.0, 1.0);

    if (isTestMode) return;

    try {
      final bgm = _getOrCreateBgmPlayer();
      bgm?.setVolume(soundEnabled ? musicVolume : 0.0);
      if (!soundEnabled && _isBgmPlaying) {
        stopBgm();
      }
    } catch (_) {}
  }

  Future<void> playSfx(String soundName) async {
    if (!soundEnabled || sfxVolume <= 0.0 || isTestMode) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(sfxVolume);
      await player.play(AssetSource('sounds/$soundName'));
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (_) {
      // Test ve platform desteği olmayan ortamlarda sessiz kalır
    }
  }

  void playDig() => playSfx('dig.wav');

  void playShoot(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.pistol:
        playSfx('shoot_pistol.wav');
        break;
      case WeaponType.rifle:
        playSfx('shoot_rifle.wav');
        break;
      case WeaponType.shotgun:
        playSfx('shoot_shotgun.wav');
        break;
      case WeaponType.laserGun:
        playSfx('shoot_laser.wav');
        break;
      case WeaponType.rocketLauncher:
        playSfx('shoot_rocket.wav');
        break;
    }
  }

  void playExplosion() => playSfx('explosion.wav');
  void playGold() => playSfx('gold_pickup.wav');
  void playHit() => playSfx('hit_enemy.wav');
  void playEnemyRoar() => playSfx('enemy_roar.wav');
  void playUpgrade() => playSfx('upgrade_success.wav');
  void playStageClear() => playSfx('stage_clear.wav');
  void playHurt() => playSfx('player_hurt.wav');
  void playClick() => playSfx('button_click.wav');

  Future<void> startBgm() async {
    if (!soundEnabled || musicVolume <= 0.0 || _isBgmPlaying || isTestMode) return;
    try {
      final bgm = _getOrCreateBgmPlayer();
      if (bgm != null) {
        await bgm.setReleaseMode(ReleaseMode.loop);
        await bgm.setVolume(musicVolume);
        await bgm.play(AssetSource('sounds/cave_bgm.wav'));
        _isBgmPlaying = true;
      }
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    if (isTestMode) return;
    try {
      await _bgmPlayer?.stop();
      _isBgmPlaying = false;
    } catch (_) {}
  }

  void dispose() {
    try {
      _bgmPlayer?.dispose();
    } catch (_) {}
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

