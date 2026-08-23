import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profil ve Ayarlar Mantık Testleri', () {
    test('Kullanıcı adı ve ayarlar başarıyla güncellenmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.setPlayerName('Efsane Madenci');
      notifier.updateSettings(
        musicVolume: 0.5,
        sfxVolume: 0.7,
        vibrationEnabled: false,
        batterySaverMode: true,
      );

      final state = container.read(gameNotifierProvider);
      expect(state.player.playerName, 'Efsane Madenci');
      expect(state.player.musicVolume, 0.5);
      expect(state.player.sfxVolume, 0.7);
      expect(state.player.vibrationEnabled, false);
      expect(state.player.batterySaverMode, true);
      container.dispose();
    });

    test('Başarım ödülü toplandığında elmas bakiyesi artmalı ve ID kaydedilmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final initialGems = notifier.state.player.gems;
      notifier.claimAchievement('ach_first_dig', 5);

      final state = container.read(gameNotifierProvider);
      expect(state.player.gems, initialGems + 5);
      expect(state.player.achievementIds.contains('ach_first_dig'), true);

      // Aynı başarım 2. kez alınamaz
      notifier.claimAchievement('ach_first_dig', 5);
      expect(container.read(gameNotifierProvider).player.gems, initialGems + 5);
      container.dispose();
    });

    test('Favori arkadaş ekleme ve silme çalışmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.addFavoriteFriend('AhmetMadenci');
      expect(notifier.state.player.favoriteFriends.contains('AhmetMadenci'), true);

      notifier.removeFavoriteFriend('AhmetMadenci');
      expect(notifier.state.player.favoriteFriends.contains('AhmetMadenci'), false);
      container.dispose();
    });

    test('resetAllProgress tüm ilerlemeyi başlangıç durumuna getirmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.resetAllProgress();

      final state = container.read(gameNotifierProvider);
      expect(state.player.gold, 0);
      expect(state.player.gems, 0);
      expect(state.player.rank, 1);
      expect(state.grid.stage, 1);
      container.dispose();
    });
  });
}
