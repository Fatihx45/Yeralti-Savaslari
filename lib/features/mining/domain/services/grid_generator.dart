import 'dart:math';
import '../models/grid_model.dart';
import '../models/tile_model.dart';
import '../models/tool_model.dart';

class GridGenerator {
  static const int defaultRows = 13;
  static const int defaultCols = 23;

  static GridModel generateStage({
    int stage = 8,
    int depth = 8,
    String biomeName = 'Kırmızı Toprak',
    int? seed,
    int playerCount = 1,
    bool isBossStage = false,
  }) {
    final Random random = seed != null ? Random(seed) : Random();
    final List<List<TileModel>> tiles = [];

    int rows = defaultRows;
    int cols = defaultCols;
    double hpMultiplier = 1.0;

    if (playerCount >= 8) {
      rows = 17;
      cols = 31;
      hpMultiplier = 1.75;
    } else if (playerCount >= 6) {
      rows = 17;
      cols = 27;
      hpMultiplier = 1.55;
    } else if (playerCount >= 4) {
      hpMultiplier = 1.35;
    } else if (playerCount >= 2) {
      hpMultiplier = 1.15;
    }

    final int playerRow = rows ~/ 2;
    final int playerCol = cols ~/ 2;

    // 4 Farklı Başlangıç Noktası (Köşeler ve Merkez)
    final spawnPoints = [
      Position(2, 2),                          // 1. Oyuncu: Sol Üst
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

        if (isNearSpawn) {
          rowTiles.add(TileModel(
            id: tileId,
            type: TileType.empty,
            maxHp: 0,
            currentHp: 0,
            isCleared: true,
          ));
        } else if (isBossStage && r == rows - 4 && c == cols - 4) {
          // 🟣 Titan Çekirdeği (Boss Core - Zafer Bloğu)
          totalMineableTiles++;
          rowTiles.add(TileModel(
            id: tileId,
            type: TileType.bossCore,
            maxHp: (350 * hpMultiplier).round(),
            currentHp: (350 * hpMultiplier).round(),
            rewardGold: 1000,
            rewardGems: 15,
            rewardEmerald: 5,
            rewardFossil: 2,
          ));
        } else {
          final double roll = random.nextDouble();

          if (roll < 0.12) {
            // 🟡 Sabit / Kırılmaz Sarı Blok (Kırılamaz Engel)
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.solidGold,
              maxHp: 999999,
              currentHp: 999999,
            ));
          } else if (roll < 0.18) {
            // 💣 Gizli Bomba (Dışarıdan Toprak Görünür - Patlayıcı)
            totalMineableTiles++;
            final int baseHp = ((5 + stage) * hpMultiplier).round();
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.hiddenMine,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: 15,
            ));
          } else if (roll < 0.24) {
            // 📦 Hazine Sandığı (Büyük Altın, Elmas ve Fosil)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.chest,
              maxHp: ((10 + stage) * hpMultiplier).round(),
              currentHp: ((10 + stage) * hpMultiplier).round(),
              rewardGold: 120 + stage * 15,
              rewardGems: 2 + (random.nextBool() ? 1 : 0),
              rewardFossil: random.nextDouble() < 0.4 ? 1 : 0,
              rewardHp: 5,
            ));
          } else if (roll < 0.31) {
            // 🧨 TNT Bloğu (3x3 Patlama ve Dinamit Ödülü)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.tnt,
              maxHp: 6,
              currentHp: 6,
              rewardGold: 25,
              rewardDynamite: 1,
            ));
          } else if (roll < 0.39) {
            // 🟢 Zümrüt & Değerli Kristal Damarı
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.emeraldOre,
              maxHp: ((10 + stage) * hpMultiplier).round(),
              currentHp: ((10 + stage) * hpMultiplier).round(),
              rewardGold: 50 + stage * 10,
              rewardGems: 1,
              rewardEmerald: 1,
              rewardHp: random.nextDouble() < 0.2 ? 10 : 0, // Nadir 10 Can
            ));
          } else if (roll < 0.46) {
            // 🧪 İksir Kapsülü (+35 Enerji)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.potion,
              maxHp: 4,
              currentHp: 4,
              rewardEnergy: 35,
              rewardHp: 5,
            ));
          } else if (roll < 0.51) {
            // 🎯 Özel Eşya (Nadir Taş ve Bol Elmas)
            totalMineableTiles++;
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.specialItem,
              maxHp: 6,
              currentHp: 6,
              rewardGems: 2,
              rewardGold: 40,
              rewardTool: ToolType.values[random.nextInt(ToolType.values.length)],
            ));
          } else if (roll < 0.75) {
            // 🧱 Kaya Bloğu (Bakır ve Demir Madenleri)
            totalMineableTiles++;
            final int baseHp = ((12 + stage) * hpMultiplier).round();
            final bool getsIron = random.nextDouble() < 0.40;
            final bool getsTool = random.nextDouble() < 0.15;

            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.rock,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: 8 + stage * 2,
              rewardCopper: !getsIron ? 1 : 0,
              rewardIron: getsIron ? 1 : 0,
              rewardTool: getsTool ? ToolType.values[random.nextInt(ToolType.values.length)] : null,
              rewardEnergy: random.nextDouble() < 0.25 ? 20 : 0,
            ));
          } else {
            // 🟫 Kazılabilir Toprak (Küçük Altın, Fosil, Can & Enerji)
            totalMineableTiles++;
            final int baseHp = ((5 + stage) * hpMultiplier).round();
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
              hp = 10; // Çok Nadir 10 Can
            } else if (lootRoll < 0.45) {
              energy = 25;
            }

            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.soil,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: 4 + stage,
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

    return GridModel(
      stage: stage,
      depth: depth,
      biomeName: biomeName,
      rows: rows,
      columns: cols,
      tiles: tiles,
      playerPosition: const Position(2, 2), // Sol-Üst Başlangıç Köşesi
      tilesClearedInStage: 9,
      totalTilesInStage: totalMineableTiles + 9,
      gridSeed: seed,
    );
  }
}

