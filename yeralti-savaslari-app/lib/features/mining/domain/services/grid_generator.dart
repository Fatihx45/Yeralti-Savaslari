import 'dart:math';
import '../models/grid_model.dart';
import '../models/tile_model.dart';
import '../models/tool_model.dart';
import '../models/stage_config_model.dart';
import 'enemy_spawner.dart';
import 'package:derin_kazi/features/ai_team/domain/models/ai_miner_model.dart';
import 'package:derin_kazi/features/multiplayer/domain/models/remote_player_model.dart';

class GridGenerator {
  static const int defaultRows = 13;
  static const int defaultCols = 23;

  static GridModel generateStage({
    int stage = 1,
    int depth = 1,
    String? biomeName,
    int? seed,
    int playerCount = 1,
    bool? isBossStage,
  }) {
    final StageConfig config = StageConfigService.getConfig(stage);
    final Random random = seed != null ? Random(seed) : Random(stage);
    final List<List<TileModel>> tiles = [];

    // Harita Boyutları (500 Bölüm Seviye Tasarımına Göre)
    int rows = config.rows;
    int cols = config.columns;
    double hpMultiplier = config.hpMultiplier;
    final double rewardMultiplier = config.rewardMultiplier;
    final String activeBiome = biomeName ?? config.biomeName;
    final bool activeBossStage = isBossStage ?? config.isBossStage;

    // Çok Oyunculu Oda Boyut / Can Ölçeklemesi
    if (playerCount >= 8) {
      rows = max(rows, 17);
      cols = max(cols, 31);
      hpMultiplier *= 1.35;
    } else if (playerCount >= 4) {
      hpMultiplier *= 1.15;
    }

    final int playerRow = rows ~/ 2;
    final int playerCol = cols ~/ 2;

    // 4 Farklı Başlangıç Noktası (Köşeler ve Merkez)
    final spawnPoints = [
      const Position(2, 2),                          // 1. Oyuncu: Sol Üst
      Position(2, cols - 3),                   // 2. Oyuncu: Sağ Üst
      Position(rows - 3, 2),                   // 3. Oyuncu: Sol Alt
      Position(rows - 3, cols - 3),            // 4. Oyuncu: Sağ Alt
      Position(playerRow, playerCol),          // Merkez
    ];

    int totalMineableTiles = 0;

    for (int r = 0; r < rows; r++) {
      final List<TileModel> rowTiles = [];
      for (int c = 0; c < cols; c++) {
        final String tileId = 'tile_${r}_$c';

        // Spawn noktalarının etrafındaki 2x2 veya 3x3 temiz alanlar
        bool isNearSpawn = false;
        for (final spawn in spawnPoints) {
          if ((r - spawn.row).abs() <= 1 && (c - spawn.col).abs() <= 1) {
            isNearSpawn = true;
            break;
          }
        }

        if (activeBossStage && r == rows ~/ 2 && c == cols ~/ 2) {
          // 🟣 Titan / Biyom / Mini Boss Çekirdeği (Merkezde)
          totalMineableTiles++;
          final int calculatedBossHp = config.bossHp > 0 ? config.bossHp : (350 * hpMultiplier).round();
          final int rewardGold = ((stage == 500 ? 10000 : 1000) * rewardMultiplier).round();
          final int rewardGems = stage == 500 ? 100 : (config.bossType == BossType.biomeBoss ? 25 : 15);

          rowTiles.add(TileModel(
            id: tileId,
            type: TileType.bossCore,
            maxHp: calculatedBossHp,
            currentHp: calculatedBossHp,
            rewardGold: rewardGold,
            rewardGems: rewardGems,
            rewardEmerald: 5,
            rewardFossil: 2,
            rewardTool: ToolType.diamondPick,
          ));
        } else if (isNearSpawn) {
          rowTiles.add(TileModel(
            id: tileId,
            type: TileType.empty,
            maxHp: 0,
            currentHp: 0,
            isCleared: true,
          ));
        } else {
          final double roll = random.nextDouble();

          if (roll < config.solidGoldProbability) {
            // 🟡 Sabit / Kırılmaz Sarı Blok (Kırılamaz Engel)
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.solidGold,
              maxHp: 999999,
              currentHp: 999999,
            ));
          } else if (roll < (config.solidGoldProbability + config.mineProbability)) {
            // 💣 Gizli Bomba (Dışarıdan Toprak Görünür - Patlayıcı)
            totalMineableTiles++;
            final int baseHp = ((6 + (stage * 0.15)) * hpMultiplier).round();
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.hiddenMine,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: (15 * rewardMultiplier).round(),
            ));
          } else if (roll < 0.40) {
            // 📦 Hazine Sandığı (Büyük Altın, Elmas ve Fosil)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.chest,
              maxHp: ((10 + (stage * 0.2)) * hpMultiplier).round(),
              currentHp: ((10 + (stage * 0.2)) * hpMultiplier).round(),
              rewardGold: ((120 + stage * 10) * rewardMultiplier).round(),
              rewardGems: 2 + (random.nextBool() ? 1 : 0),
              rewardFossil: random.nextDouble() < 0.4 ? 1 : 0,
              rewardHp: 5,
            ));
          } else if (roll < 0.48) {
            // 🧨 TNT Bloğu (3x3 Patlama ve Dinamit Ödülü)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.tnt,
              maxHp: 6,
              currentHp: 6,
              rewardGold: (25 * rewardMultiplier).round(),
              rewardDynamite: 1,
            ));
          } else if (roll < 0.58) {
            // 🟢 Zümrüt & Değerli Kristal Damarı
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.emeraldOre,
              maxHp: ((10 + (stage * 0.2)) * hpMultiplier).round(),
              currentHp: ((10 + (stage * 0.2)) * hpMultiplier).round(),
              rewardGold: ((50 + stage * 5) * rewardMultiplier).round(),
              rewardGems: 1,
              rewardEmerald: 1,
              rewardHp: random.nextDouble() < 0.2 ? 10 : 0,
            ));
          } else if (roll < 0.65) {
            // 🧪 İksir Kapsülü (+35 Enerji)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.potion,
              maxHp: 4,
              currentHp: 4,
              rewardEnergy: stage >= 350 ? 25 : 35, // Buzul Çekirdeğinde kısık enerji
              rewardHp: 5,
            ));
          } else if (roll < 0.70) {
            // 🎯 Özel Eşya (Nadir Taş ve Bol Elmas)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.specialItem,
              maxHp: 6,
              currentHp: 6,
              rewardGems: 2,
              rewardGold: (40 * rewardMultiplier).round(),
              rewardTool: ToolType.values[random.nextInt(ToolType.values.length)],
            ));
          } else if (roll < 0.85) {
            // 🧱 Kaya Bloğu (Bakır ve Demir Madenleri)
            totalMineableTiles++;
            final int baseHp = ((12 + (stage * 0.25)) * hpMultiplier).round();
            final bool getsIron = random.nextDouble() < 0.40;
            final bool getsTool = random.nextDouble() < 0.15;

            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.rock,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: ((8 + stage * 2) * rewardMultiplier).round(),
              rewardCopper: !getsIron ? 1 : 0,
              rewardIron: getsIron ? 1 : 0,
              rewardTool: getsTool ? ToolType.values[random.nextInt(ToolType.values.length)] : null,
              rewardEnergy: random.nextDouble() < 0.25 ? 20 : 0,
            ));
          } else {
            // 🟫 Kazılabilir Toprak (Küçük Altın, Fosil, Can & Enerji)
            totalMineableTiles++;
            final int baseHp = ((5 + (stage * 0.15)) * hpMultiplier).round();
            final bool getsFossil = random.nextDouble() < 0.10;
            final double lootRoll = random.nextDouble();

            ToolType? tool;
            int hp = 0;
            int energy = 0;

            if (lootRoll < 0.12) {
              tool = ToolType.values[random.nextInt(ToolType.values.length)];
            } else if (lootRoll < 0.25) {
              hp = 5;
            } else if (lootRoll < 0.28) {
              hp = 10;
            } else if (lootRoll < 0.45) {
              energy = stage >= 350 ? 18 : 25;
            }

            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.soil,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: ((4 + stage) * rewardMultiplier).round(),
              rewardFossil: getsFossil ? 1 : 0,
              rewardEnergy: energy,
              rewardHp: hp,
              rewardTool: tool,
            ));
          }
        }
      }
      tiles.add(rowTiles);
    }

    final enemies = EnemySpawner.spawnForStage(
      stage: stage,
      rows: rows,
      columns: cols,
      playerPos: const Position(2, 2),
      seed: seed ?? stage,
    );

    // Sistem Tarafından Üretilen Bot Madenciler (otherPlayers)
    final otherPlayers = <RemotePlayerModel>[];
    if (playerCount > 1) {
      final botPresets = AiMinerModel.getPresetMiners();
      for (int i = 0; i < playerCount - 1 && i < botPresets.length; i++) {
        final bot = botPresets[i];
        final spawnPos = spawnPoints[(i + 1) % spawnPoints.length];
        otherPlayers.add(RemotePlayerModel(
          uid: bot.id,
          displayName: bot.name,
          colorIndex: i + 1,
          position: spawnPos,
          hp: 100,
          maxHp: 100,
        ));
      }
    }

    return GridModel(
      stage: stage,
      depth: depth,
      biomeName: activeBiome,
      rows: rows,
      columns: cols,
      tiles: tiles,
      playerPosition: const Position(2, 2),
      tilesClearedInStage: 9,
      totalTilesInStage: totalMineableTiles + 9,
      gridSeed: seed ?? stage,
      otherPlayers: otherPlayers,
      enemies: enemies,
    );
  }
}
