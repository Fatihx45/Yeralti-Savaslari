import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/features/ai_team/application/ai_team_engine.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tile_model.dart';

void main() {
  group('Sistem Destekli (AI) Ekip Kazısı Mantık Testleri', () {
    late AiTeamNotifier notifier;

    setUp(() {
      notifier = AiTeamNotifier();
    });

    test('1-10 Kişilik takım boyutu seçildiğinde doğru sayıda bot oluşturulmalı', () {
      // 4 Kişilik Takım: 1 Oyuncu + 3 Bot
      notifier.setTeamSize(4);
      expect(notifier.state.teamSize, 4);
      expect(notifier.state.activeMiners.length, 3);

      // 10 Kişilik Takım: 1 Oyuncu + 9 Bot
      notifier.setTeamSize(10);
      expect(notifier.state.teamSize, 10);
      expect(notifier.state.activeMiners.length, 9);

      // 1 Kişilik Takım: 1 Oyuncu + 0 Bot
      notifier.setTeamSize(1);
      expect(notifier.state.teamSize, 1);
      expect(notifier.state.activeMiners.length, 0);
    });

    test('Takım Tamamlama Bonusu (PDF Bölüm 3.4) doğru oranlarda hesaplanmalı', () {
      // 2 Kişi = %5 Bonus
      notifier.setTeamSize(2);
      expect(notifier.state.teamBonusPercentage, 0.05);

      // 4 Kişi = %15 Bonus
      notifier.setTeamSize(4);
      expect(notifier.state.teamBonusPercentage, closeTo(0.15, 0.001));

      // 8 Kişi = %35 Bonus (Tavan)
      notifier.setTeamSize(8);
      expect(notifier.state.teamBonusPercentage, 0.35);

      // 10 Kişi = %35 Bonus (Tavanı aşmamalı)
      notifier.setTeamSize(10);
      expect(notifier.state.teamBonusPercentage, 0.35);
    });

    test('Katkı Oranlı Ödül Paylaşımı (PDF Bölüm 3.3) hasar oranına göre ödül bölüştürmeli', () {
      notifier.setTeamSize(4);
      const tileId = 'tile_10_5';
      const tileMaxHp = 30;
      const totalRewardGold = 100;

      // Oyuncu 20 hasar, Bot_1 10 hasar vurdu
      notifier.recordDamage(tileId, 'player', 20);
      notifier.recordDamage(tileId, 'bot_1', 10);

      final distribution = notifier.calculateRewardDistribution(tileId, totalRewardGold, tileMaxHp);

      // Oyuncu %66.7 -> 67 Altın, Bot_1 %33.3 -> 34 Altın
      expect(distribution['player'], greaterThanOrEqualTo(66));
      expect(distribution['bot_1'], greaterThanOrEqualTo(33));
    });

    test('Aşamanın Yıldızı (MVP) en çok hasar veren madenciyi seçmeli', () {
      notifier.setTeamSize(4);

      notifier.recordDamage('tile_1', 'bot_1', 50);
      notifier.recordDamage('tile_2', 'bot_2', 120);

      // Oyuncu 80 hasar verdiyse, 120 hasar veren bot_2 MVP olmalı
      final mvp = notifier.calculateMvp(80);
      expect(mvp, isNotNull);
      expect(mvp!.id, 'bot_2');

      // Oyuncu 150 hasar verdiyse, oyuncu MVP olmalı
      final playerMvp = notifier.calculateMvp(150);
      expect(playerMvp, isNull);
      expect(notifier.state.mvpMinerId, 'player');
    });

    test('Akıllı Bot Karar Adımı haritadaki madenlere hasar vermeli', () {
      notifier.setTeamSize(3);
      notifier.startSimulation();

      final tiles = List.generate(
        13,
        (r) => List.generate(
          23,
          (c) => TileModel(
            id: 'tile_${r}_$c',
            type: TileType.goldOre,
            maxHp: 20,
            currentHp: 20,
            rewardGold: 15,
            isCleared: false,
          ),
        ),
      );

      final grid = GridModel(
        stage: 1,
        depth: 1,
        biomeName: 'Kızıl Toprak Vadisi',
        rows: 13,
        columns: 23,
        playerPosition: const Position(0, 0),
        tiles: tiles,
        tilesClearedInStage: 0,
        totalTilesInStage: 299,
      );

      int damagedCount = 0;
      notifier.performAiTurn(grid, (pos, damage, minerId) {
        damagedCount++;
      });

      expect(damagedCount, greaterThan(0));
    });
  });
}
