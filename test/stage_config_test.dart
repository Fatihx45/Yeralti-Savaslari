import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/features/mining/domain/models/stage_config_model.dart';
import 'package:derin_kazi/features/mining/domain/services/grid_generator.dart';

void main() {
  group('500 Bölüm Seviye Tasarımı ve Biyom Testleri', () {
    test('1. Bölüm Kolay Katman (Kızıl Toprak Vadisi, 13x23, 1.00x HP) olmalı', () {
      final config = StageConfigService.getConfig(1);
      expect(config.stage, 1);
      expect(config.tier, StageTier.easy);
      expect(config.biomeName, 'Kızıl Toprak Vadisi');
      expect(config.rows, 13);
      expect(config.columns, 23);
      expect(config.hpMultiplier, 1.00);
      expect(config.bossType, BossType.none);
    });

    test('10. Bölüm Mini-Boss ve 50. Bölüm Biyom Boss olmalı', () {
      final config10 = StageConfigService.getConfig(10);
      expect(config10.bossType, BossType.miniBoss);
      expect(config10.isBossStage, true);
      expect(config10.bossHp > 300, true);

      final config50 = StageConfigService.getConfig(50);
      expect(config50.bossType, BossType.biomeBoss);
      expect(config50.isBossStage, true);
      expect(config50.bossHp >= 500, true);
    });

    test('100., 200., 300., 400. Bölümler ilgili biyomların Biyom Boss\'u olmalı', () {
      final config100 = StageConfigService.getConfig(100);
      expect(config100.biomeName, 'Bakır Yamaçları');
      expect(config100.bossType, BossType.biomeBoss);

      final config200 = StageConfigService.getConfig(200);
      expect(config200.biomeName, 'Demir Kemer');
      expect(config200.bossType, BossType.biomeBoss);

      final config300 = StageConfigService.getConfig(300);
      expect(config300.biomeName, 'Obsidyen Yarıkları');
      expect(config300.bossType, BossType.biomeBoss);

      final config400 = StageConfigService.getConfig(400);
      expect(config400.biomeName, 'Buzul Çekirdeği');
      expect(config400.bossType, BossType.biomeBoss);
    });

    test('500. Bölüm Titan\'ın Kalbi, 17x31 harita ve 1120 HP BÜYÜK TİTAN Final Boss olmalı', () {
      final config500 = StageConfigService.getConfig(500);
      expect(config500.tier, StageTier.chaos);
      expect(config500.biomeName, "Titan'ın Kalbi");
      expect(config500.rows, 17);
      expect(config500.columns, 31);
      expect(config500.bossType, BossType.finalBoss);
      expect(config500.bossHp, 1120);
      expect(config500.specialNote.contains('FINAL BOSS'), true);
    });

    test('GridGenerator 500. bölümü ürettiğinde merkezde 1120 HP bossCore olmalı', () {
      final grid500 = GridGenerator.generateStage(stage: 500);
      expect(grid500.rows, 17);
      expect(grid500.columns, 31);
      expect(grid500.biomeName, "Titan'ın Kalbi");

      final centerTile = grid500.tiles[17 ~/ 2][31 ~/ 2];
      expect(centerTile.maxHp, 1120);
      expect(centerTile.currentHp, 1120);
      expect(centerTile.rewardGold >= 10000, true);
    });
  });
}
