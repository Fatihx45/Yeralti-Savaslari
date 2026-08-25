import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/ai_team/domain/models/ai_miner_model.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tile_model.dart';

class AiTeamState {
  final int teamSize; // 1 - 10
  final List<AiMinerModel> activeMiners;
  final bool isSimulationActive;
  final Map<String, Map<String, int>> tileDamageLog; // tileId -> {minerId: damage}
  final double teamBonusPercentage;
  final String? mvpMinerId;

  const AiTeamState({
    this.teamSize = 4,
    this.activeMiners = const [],
    this.isSimulationActive = false,
    this.tileDamageLog = const {},
    this.teamBonusPercentage = 0.15,
    this.mvpMinerId,
  });

  AiTeamState copyWith({
    int? teamSize,
    List<AiMinerModel>? activeMiners,
    bool? isSimulationActive,
    Map<String, Map<String, int>>? tileDamageLog,
    double? teamBonusPercentage,
    String? mvpMinerId,
  }) {
    return AiTeamState(
      teamSize: teamSize ?? this.teamSize,
      activeMiners: activeMiners ?? this.activeMiners,
      isSimulationActive: isSimulationActive ?? this.isSimulationActive,
      tileDamageLog: tileDamageLog ?? this.tileDamageLog,
      teamBonusPercentage: teamBonusPercentage ?? this.teamBonusPercentage,
      mvpMinerId: mvpMinerId ?? this.mvpMinerId,
    );
  }
}

class AiTeamNotifier extends StateNotifier<AiTeamState> {
  AiTeamNotifier() : super(const AiTeamState()) {
    setTeamSize(4);
  }

  // 1-10 Oyuncu Sayısına Göre Takım Oluştur (PDF Bölüm 3.2 & 3.4)
  void setTeamSize(int size) {
    final clampedSize = size.clamp(1, 10);
    final allPresets = AiMinerModel.getPresetMiners();
    final neededBots = clampedSize - 1; // 1 tanesi oyuncunun kendisi

    final activeBots = allPresets.take(neededBots).map((b) => b.copyWith()).toList();

    // Takım Tamamlama Bonusu: %5 * (aktif oyuncu sayısı - 1), 8+ oyuncuda %35 tavan (PDF Bölüm 3.4)
    double bonus = (clampedSize - 1) * 0.05;
    if (bonus > 0.35) bonus = 0.35;

    state = state.copyWith(
      teamSize: clampedSize,
      activeMiners: activeBots,
      teamBonusPercentage: bonus,
      tileDamageLog: {},
      mvpMinerId: null,
    );
  }

  void startSimulation() {
    state = state.copyWith(isSimulationActive: true);
  }

  void stopSimulation() {
    state = state.copyWith(isSimulationActive: false);
  }

  // Hasar Defterine Kayıt ve Katkı Oranlı Ödül Dağıtımı (PDF Bölüm 3.3)
  void recordDamage(String tileId, String minerId, int damage) {
    final currentLog = Map<String, Map<String, int>>.from(state.tileDamageLog);
    final tileLog = Map<String, int>.from(currentLog[tileId] ?? {});

    tileLog[minerId] = (tileLog[minerId] ?? 0) + damage;
    currentLog[tileId] = tileLog;

    // Bot istatistiğini güncelle
    final updatedMiners = state.activeMiners.map((miner) {
      if (miner.id == minerId) {
        return miner.copyWith(
          totalDamageDealt: miner.totalDamageDealt + damage,
        );
      }
      return miner;
    }).toList();

    state = state.copyWith(
      tileDamageLog: currentLog,
      activeMiners: updatedMiners,
    );
  }

  // Taş Kırıldığında Katkı Paylaşımı (PDF Kural: Katkı Oranlı Ödül Paylaşımı)
  Map<String, int> calculateRewardDistribution(String tileId, int totalRewardGold, int tileMaxHp) {
    final tileLog = state.tileDamageLog[tileId];
    final distribution = <String, int>{};

    if (tileLog == null || tileLog.isEmpty) {
      distribution['player'] = totalRewardGold;
      return distribution;
    }

    tileLog.forEach((minerId, damage) {
      final ratio = (damage / tileMaxHp).clamp(0.0, 1.0);
      final earned = (totalRewardGold * ratio).ceil();
      distribution[minerId] = earned;
    });

    return distribution;
  }

  // Aşamanın Yıldızı (MVP) Belirleme (PDF Bölüm 3.6)
  AiMinerModel? calculateMvp(int playerTotalDamage) {
    if (state.activeMiners.isEmpty) return null;

    AiMinerModel? bestMiner;
    int maxDamage = -1;

    for (final miner in state.activeMiners) {
      if (miner.totalDamageDealt > maxDamage) {
        maxDamage = miner.totalDamageDealt;
        bestMiner = miner;
      }
    }

    if (bestMiner != null && bestMiner.totalDamageDealt > playerTotalDamage) {
      state = state.copyWith(mvpMinerId: bestMiner.id);
      return bestMiner;
    }

    state = state.copyWith(mvpMinerId: 'player');
    return null; // Oyuncunun kendisi MVP
  }

  // Akıllı Bot Karar Adımı: En uygun maden hücresini seç ve kaz
  void performAiTurn(GridModel grid, Function(Position pos, int damage, String minerId) onTileDamaged) {
    if (!state.isSimulationActive || state.activeMiners.isEmpty) return;

    final random = Random();
    final updatedMiners = <AiMinerModel>[];

    for (final miner in state.activeMiners) {
      // 1. Hedef Bul (Çevredeki kırılmamış madenler)
      final neighbors = _getValidNeighbors(miner.position, grid.rows, grid.columns);
      final targetPositions = neighbors.where((p) {
        final tile = grid.tiles[p.row][p.col];
        return !tile.isCleared && tile.type != TileType.solidGold;
      }).toList();

      if (targetPositions.isNotEmpty) {
        // Öncelik: Boss / Değerli madenler
        targetPositions.sort((a, b) {
          final tileA = grid.tiles[a.row][a.col];
          final tileB = grid.tiles[b.row][b.col];
          final scoreA = _getTilePriorityScore(tileA.type);
          final scoreB = _getTilePriorityScore(tileB.type);
          return scoreB.compareTo(scoreA);
        });

        final chosenPos = targetPositions.first;
        final targetTile = grid.tiles[chosenPos.row][chosenPos.col];

        // Hasar Ver
        final damage = miner.digPower;
        onTileDamaged(chosenPos, damage, miner.id);
        recordDamage(targetTile.id, miner.id, damage);

        // Canlı Emoji ve Tepki Baloncuğu (PDF Bölüm 3.6)
        String? newEmoji = miner.currentEmoji;
        if (random.nextDouble() < 0.18) {
          newEmoji = _getRandomReaction(targetTile.type);
        }

        updatedMiners.add(miner.copyWith(
          position: chosenPos,
          currentEmoji: newEmoji,
          emojiExpiration: DateTime.now().add(const Duration(seconds: 3)),
        ));
      } else {
        // Çevrede kazılacak yer yoksa boş bir hücreye adım at
        final emptyNeighbors = neighbors.where((p) {
          return grid.tiles[p.row][p.col].isCleared;
        }).toList();

        if (emptyNeighbors.isNotEmpty) {
          final nextPos = emptyNeighbors[random.nextInt(emptyNeighbors.length)];
          updatedMiners.add(miner.copyWith(position: nextPos));
        } else {
          updatedMiners.add(miner);
        }
      }
    }

    state = state.copyWith(activeMiners: updatedMiners);
  }

  List<Position> _getValidNeighbors(Position pos, int maxRows, int maxCols) {
    final list = <Position>[];
    final deltas = [
      const Position(-1, 0), // Yukarı
      const Position(1, 0),  // Aşağı
      const Position(0, -1), // Sol
      const Position(0, 1),  // Sağ
    ];

    for (final d in deltas) {
      final nr = pos.row + d.row;
      final nc = pos.col + d.col;
      if (nr >= 0 && nr < maxRows && nc >= 0 && nc < maxCols) {
        list.add(Position(nr, nc));
      }
    }
    return list;
  }

  int _getTilePriorityScore(TileType type) {
    switch (type) {
      case TileType.bossCore:
        return 100;
      case TileType.emeraldOre:
      case TileType.chest:
        return 80;
      case TileType.tnt:
      case TileType.goldOre:
        return 60;
      case TileType.potion:
      case TileType.specialItem:
        return 40;
      case TileType.soil:
      case TileType.rock:
        return 20;
      default:
        return 10;
    }
  }

  String _getRandomReaction(TileType type) {
    switch (type) {
      case TileType.bossCore:
        return '🔥 BOSS\'A VURUN!';
      case TileType.emeraldOre:
      case TileType.chest:
        return '💎 ZÜMRÜT BULUNDU!';
      case TileType.tnt:
        return '💣 DİKKAT TNT!';
      case TileType.goldOre:
        return '🟡 ALTIN DAMARI!';
      default:
        return '⛏️ KAZMAYA DEVAM!';
    }
  }
}

final aiTeamNotifierProvider = StateNotifierProvider<AiTeamNotifier, AiTeamState>((ref) {
  return AiTeamNotifier();
});
