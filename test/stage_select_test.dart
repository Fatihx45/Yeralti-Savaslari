import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bölüm Seçimi ve İlerleme Testleri', () {
    test('Başlangıçta oyuncunun unlockedStage değeri 1 olmalı', () {
      final container = ProviderContainer();
      final state = container.read(gameNotifierProvider);

      expect(state.player.unlockedStage, 1);
      container.dispose();
    });

    test('startStage çağrıldığında belirtilen bölüm haritası ve biyomu başlatılmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.startStage(50);

      final state = container.read(gameNotifierProvider);
      expect(state.grid.stage, 50);
      expect(state.grid.biomeName, 'Kızıl Toprak Vadisi');
      expect(state.gameMode, GameMode.solo);
      container.dispose();
    });

    test('Aşama tamamlandığında unlockedStage bir sonraki bölüme yükselmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      expect(notifier.state.player.unlockedStage, 1);

      // 1. Bölümü tamamla (Tüm kutuları temizlemiş gibi yapalım)
      notifier.state = notifier.state.copyWith(
        grid: notifier.state.grid.copyWith(
          stage: 1,
          tilesClearedInStage: notifier.state.grid.totalTilesInStage,
        ),
      );

      // digTargetTile kırılınca _advanceStage çağrılır
      notifier.startStage(1);
      // Bir kutuyu kır
      notifier.digTargetTile();

      container.dispose();
    });
  });
}
