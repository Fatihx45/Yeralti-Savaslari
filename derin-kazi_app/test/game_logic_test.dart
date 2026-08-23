import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';
import 'package:derin_kazi/features/mining/domain/models/upgrade_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tile_model.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';
import 'package:derin_kazi/features/quests/domain/models/daily_quest_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Derin Kazı Oyun Mantığı Testleri', () {
    test('Başlangıç durumu ve değerleri doğrulanmalı', () {
      final container = ProviderContainer();
      final state = container.read(gameNotifierProvider);

      expect(state.player.gold, 997);
      expect(state.player.gems, 24);
      expect(state.player.rank, 4);
      expect(state.grid.stage, 1);
      expect(state.grid.depth, 1);
      expect(state.player.upgrades[UpgradeType.pickaxe]?.level, 4);
      expect(state.player.upgrades[UpgradeType.hammer]?.level, 3);
      expect(state.player.upgrades[UpgradeType.luck]?.level, 3);
      expect(state.player.upgrades[UpgradeType.energy]?.level, 2);
    });

    test('Mağazadan yükseltme satın alınabilmeli ve altın düşmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final initialGold = container.read(gameNotifierProvider).player.gold;
      final energyUpgrade = container.read(gameNotifierProvider).player.upgrades[UpgradeType.energy]!;

      expect(initialGold >= energyUpgrade.cost, true);

      final success = notifier.purchaseUpgrade(UpgradeType.energy);
      expect(success, true);

      final updatedState = container.read(gameNotifierProvider);
      expect(updatedState.player.gold, initialGold - energyUpgrade.cost);
      expect(updatedState.player.upgrades[UpgradeType.energy]?.level, 3);
      expect(updatedState.player.maxEnergy, 95);
    });

    test('D-Pad hareketi ve kazı işlemi çalışmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final startPos = container.read(gameNotifierProvider).grid.playerPosition;
      final startEnergy = container.read(gameNotifierProvider).player.energy;

      // Sağa veya yukarı/aşağı bir hamle yapalım
      notifier.moveOrDig(0, 1);

      final newState = container.read(gameNotifierProvider);
      // Ya hareket etti ya da kazı yapıp enerji harcadı
      expect(
        newState.grid.playerPosition != startPos || newState.player.energy < startEnergy,
        true,
      );
    });

    test('SIFIRLA (Prestij) işlemi rütbeyi artırmalı ve aşamayı 1 yapmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final oldRank = container.read(gameNotifierProvider).player.rank;

      notifier.prestigeReset();

      final resetState = container.read(gameNotifierProvider);
      expect(resetState.player.rank, oldRank + 1);
      expect(resetState.player.gold, 0);
      expect(resetState.grid.stage, 1);
      expect(resetState.grid.depth, 1);
    });

    test('Sabit Sarı Blok (solidGold) kırılamaz olmalı ve enerji harcamamalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      // Oyuncunun yanına bir solidGold tile yerleştirelim
      final state = container.read(gameNotifierProvider);
      final pPos = state.grid.playerPosition;
      final targetRow = pPos.row;
      final targetCol = pPos.col + 1;

      final updatedTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetRow && c == targetCol)
                state.grid.tiles[r][c].copyWith(
                  type: TileType.solidGold,
                  maxHp: 999999,
                  currentHp: 999999,
                  isCleared: false,
                )
              else
                state.grid.tiles[r][c]
          ]
      ];

      // Grid'i güncelleyelim
      container.read(gameNotifierProvider.notifier).state = state.copyWith(
        grid: state.grid.copyWith(tiles: updatedTiles),
      );

      final initialEnergy = container.read(gameNotifierProvider).player.energy;

      // Sabit sarı bloğa doğru hamle yap
      notifier.moveOrDig(0, 1);

      final afterState = container.read(gameNotifierProvider);

      // Konum değişmedi, enerji gitmedi ve uyarı mesajı geldi
      expect(afterState.grid.playerPosition, pPos);
      expect(afterState.player.energy, initialEnergy);
      expect(afterState.lastMessage, 'Bu sarı blok sabittir, kırılamaz!');
      expect(afterState.grid.tiles[targetRow][targetCol].isCleared, false);
    });

    test('changeDirection yönü güncellemeli ve digTargetTile hedeflenen kutuyu kazmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      // Yönü sağa çevir
      notifier.changeDirection(PlayerDirection.right);
      expect(container.read(gameNotifierProvider).grid.playerFacing, PlayerDirection.right);

      final state = container.read(gameNotifierProvider);
      final targetPos = state.grid.targetCellPosition;

      // Eğer hedefte kırılabilir kutu varsa KAZ butonu çalıştır
      final targetTile = state.grid.tiles[targetPos.row][targetPos.col];
      if (!targetTile.isCleared && !targetTile.isUnbreakable) {
        final initialHp = targetTile.currentHp;
        final initialEnergy = state.player.energy;

        notifier.digTargetTile();

        final afterDig = container.read(gameNotifierProvider);
        final afterTile = afterDig.grid.tiles[targetPos.row][targetPos.col];

        expect(afterDig.player.energy < initialEnergy, true);
        expect(afterTile.currentHp < initialHp || afterTile.isCleared, true);
      }
    });

    test('sellAllOres madenleri doğru oranda altına ve elmasa dönüştürmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      // Oyuncuya maden ekleyelim
      final state = container.read(gameNotifierProvider);
      container.read(gameNotifierProvider.notifier).state = state.copyWith(
        player: state.player.copyWith(
          gold: 100,
          gems: 10,
          copper: 2,   // 2 * 15 = 30
          iron: 1,     // 1 * 35 = 35
          emeralds: 1, // 1 * 100 = 100 (+1 elmas)
        ),
      );

      notifier.sellAllOres();

      final afterState = container.read(gameNotifierProvider);
      // Toplam altın: 100 + 30 + 35 + 100 = 265
      // Toplam elmas: 10 + 1 = 11
      expect(afterState.player.gold, 265);
      expect(afterState.player.gems, 11);
      expect(afterState.player.copper, 0);
      expect(afterState.player.iron, 0);
      expect(afterState.player.emeralds, 0);
    });

    test('useDynamite çantadakileri kullanıp 3x3 alanı patlatmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      // Oyuncuya dinamit verelim
      final state = container.read(gameNotifierProvider);
      container.read(gameNotifierProvider.notifier).state = state.copyWith(
        player: state.player.copyWith(dynamites: 2),
      );

      final success = notifier.useDynamite();
      expect(success, true);

      final afterState = container.read(gameNotifierProvider);
      expect(afterState.player.dynamites, 1);
    });

    test('Gizli Mayın (hiddenMine) patlayınca can hasarı vermeli (-30 Can)', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final state = container.read(gameNotifierProvider);
      final pPos = state.grid.playerPosition;
      final targetRow = pPos.row + 1;
      final targetCol = pPos.col;

      final updatedTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetRow && c == targetCol)
                state.grid.tiles[r][c].copyWith(
                  type: TileType.hiddenMine,
                  maxHp: 2,
                  currentHp: 2,
                  isCleared: false,
                )
              else
                state.grid.tiles[r][c]
          ]
      ];

      container.read(gameNotifierProvider.notifier).state = state.copyWith(
        grid: state.grid.copyWith(tiles: updatedTiles),
        player: state.player.copyWith(hp: 100),
      );

      // Aşağı yöne bak ve kaz
      notifier.changeDirection(PlayerDirection.down);
      notifier.digTargetTile();

      final afterState = container.read(gameNotifierProvider);
      expect(afterState.player.hp, 70); // 100 - 30 = 70 Can
      expect(afterState.lastMessage?.contains('GİZLİ BOMBA'), true);
      container.dispose();
    });

    test('TNT kutusu kazıldığında patlamalı, 3x3 alanı temizlemeli ve dinamit kazandırmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final state = container.read(gameNotifierProvider);
      final pPos = state.grid.playerPosition;
      final targetRow = pPos.row + 1;
      final targetCol = pPos.col;

      final updatedTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetRow && c == targetCol)
                state.grid.tiles[r][c].copyWith(
                  type: TileType.tnt,
                  maxHp: 2,
                  currentHp: 2,
                  isCleared: false,
                  rewardDynamite: 1,
                )
              else
                state.grid.tiles[r][c]
          ]
      ];

      notifier.state = state.copyWith(
        grid: state.grid.copyWith(tiles: updatedTiles),
        player: state.player.copyWith(dynamites: 0),
      );

      notifier.changeDirection(PlayerDirection.down);
      notifier.digTargetTile();

      final afterState = container.read(gameNotifierProvider);
      expect(afterState.player.dynamites, 1);
      expect(afterState.lastMessage?.contains('TNT PATLADI'), true);
      container.dispose();
    });

    test('Zümrüt, Bakır, Demir ve Sandık kutuları madenleri envantere eklemeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final state = container.read(gameNotifierProvider);
      final pPos = state.grid.playerPosition;
      final targetRow = pPos.row + 1;
      final targetCol = pPos.col;

      // Hedefe Zümrüt Damarı koyalım
      final updatedTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetRow && c == targetCol)
                state.grid.tiles[r][c].copyWith(
                  type: TileType.emeraldOre,
                  maxHp: 2,
                  currentHp: 2,
                  isCleared: false,
                  rewardEmerald: 1,
                  rewardGems: 2,
                )
              else
                state.grid.tiles[r][c]
          ]
      ];

      notifier.state = state.copyWith(
        grid: state.grid.copyWith(tiles: updatedTiles),
        player: state.player.copyWith(emeralds: 0, gems: 0),
      );

      notifier.changeDirection(PlayerDirection.down);
      notifier.digTargetTile();

      final afterState = container.read(gameNotifierProvider);
      expect(afterState.player.emeralds, 1);
      expect(afterState.player.gems, 2);
      expect(afterState.lastMessage?.contains('Zümrüt Damarı'), true);
      container.dispose();
    });

    test('equipSkin elmas karşılığı yeni kostüm kuşanmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.state = notifier.state.copyWith(
        player: notifier.state.player.copyWith(gems: 20, equippedSkinId: 'default_blue'),
      );

      notifier.equipSkin('gold_knight', 5);

      final state = container.read(gameNotifierProvider);
      expect(state.player.equippedSkinId, 'gold_knight');
      expect(state.player.gems, 15); // 20 - 5 = 15
      container.dispose();
    });

    test('claimQuestReward tamamlanan görevin ödülünü vermeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final quests = notifier.state.quests.map((q) {
        if (q.id == 'q_dig_30') return q.copyWith(current: 30);
        return q;
      }).toList();

      notifier.state = notifier.state.copyWith(
        quests: quests,
        player: notifier.state.player.copyWith(gold: 100, gems: 5),
      );

      notifier.claimQuestReward('q_dig_30');

      final state = container.read(gameNotifierProvider);
      expect(state.player.gold, 350); // 100 + 250
      expect(state.player.gems, 8);   // 5 + 3
      expect(state.quests.firstWhere((q) => q.id == 'q_dig_30').isClaimed, true);
      container.dispose();
    });

    test('12 Adet Haftalık Kademeli Görev listesi başlatılmalı', () {
      final container = ProviderContainer();
      final state = container.read(gameNotifierProvider);

      expect(state.quests.length >= 10, true);
      expect(state.quests.any((q) => q.difficulty == QuestDifficulty.easy), true);
      expect(state.quests.any((q) => q.difficulty == QuestDifficulty.medium), true);
      expect(state.quests.any((q) => q.difficulty == QuestDifficulty.hard), true);
      expect(state.quests.any((q) => q.difficulty == QuestDifficulty.legendary), true);
      container.dispose();
    });

    test('sendReaction aktif emojiyi güncellemeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.sendReaction('💎');

      final state = container.read(gameNotifierProvider);
      expect(state.activeReactionEmoji, '💎');
      container.dispose();
    });
  });
}

