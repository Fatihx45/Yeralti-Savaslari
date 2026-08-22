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
        } else {
          final double roll = random.nextDouble();

          if (roll < 0.15) {
            // Sabit / Kırılmaz Sarı Blok (Kırılamaz Engel)
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.solidGold,
              maxHp: 999999,
              currentHp: 999999,
            ));
          } else if (roll < 0.22) {
            // 💣 Gizli Bomba (Dışarıdan Toprak Görünür - Kimse Görmez!)
            totalMineableTiles++;
            final int baseHp = ((5 + stage) * hpMultiplier).round();
            rowTiles.add(TileModel(
              id: tileId,
              type: TileType.hiddenMine,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: 15,
            ));
          } else {
            // Standart Kapalı Kırılabilir Maden / Kaya / Toprak Kutusu
            totalMineableTiles++;
            final int baseHp = ((5 + stage) * hpMultiplier).round();

            // Rastgele Ödül Belirleme:
            final double lootRoll = random.nextDouble();
            ToolType? foundTool;
            int rewardHp = 0;
            int rewardEnergy = 0;
            int rewardGold = 10 + random.nextInt(35);
            int rewardGems = 0;

            if (lootRoll < 0.14) {
              // 🛠️ Envanter Aleti / Silahı (Tornavida, Kazma, Kürek, Balta, Beyzbol Sopası vb.)
              foundTool = ToolType.values[random.nextInt(ToolType.values.length)];
            } else if (lootRoll < 0.28) {
              // ❤️ Can İksiri (5 Can - Sık Bulunur)
              rewardHp = 5;
            } else if (lootRoll < 0.32) {
              // 💛 Büyük Can İksiri (10 Can - Çok Nadir!)
              rewardHp = 10;
            } else if (lootRoll < 0.52) {
              // ⚡ Enerji İçeceği
              rewardEnergy = 25 + random.nextInt(20);
            } else if (lootRoll < 0.65) {
              // 📦 Hazine / Bol Altın & Elmas
              rewardGold = 80 + stage * 15;
              rewardGems = 1 + (random.nextBool() ? 1 : 0);
            }

            rowTiles.add(TileModel(
              id: tileId,
              type: random.nextBool() ? TileType.rock : TileType.soil,
              maxHp: baseHp,
              currentHp: baseHp,
              rewardGold: rewardGold,
              rewardGems: rewardGems,
              rewardEnergy: rewardEnergy,
              rewardHp: rewardHp,
              rewardTool: foundTool,
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
