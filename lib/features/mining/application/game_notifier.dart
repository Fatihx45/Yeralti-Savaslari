import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/grid_model.dart';
import '../domain/models/player_state_model.dart';
import '../domain/models/tile_model.dart';
import '../domain/models/upgrade_model.dart';
import '../domain/services/grid_generator.dart';
import 'package:derin_kazi/features/multiplayer/domain/models/remote_player_model.dart';

import 'package:derin_kazi/features/battle_royale/domain/models/battle_phase_model.dart';
import '../domain/models/tool_model.dart';

import 'package:derin_kazi/features/quests/domain/models/daily_quest_model.dart';
import 'package:derin_kazi/core/persistence/save_service.dart';

enum GameMode {
  solo,
  battleRoyale,
}

List<DailyQuestModel> defaultWeeklyQuests() => [
  const DailyQuestModel(
    id: 'q_dig_30',
    title: 'Acemi Madenci',
    description: 'Yeraltında 30 kutu kaz',
    iconEmoji: '⛏️',
    target: 30,
    rewardGold: 250,
    rewardGems: 3,
    difficulty: QuestDifficulty.easy,
    actionType: QuestActionType.dig,
  ),
  const DailyQuestModel(
    id: 'q_gold_500',
    title: 'Altın Avcısı',
    description: 'Kazılardan 500 altın topla',
    iconEmoji: '🟡',
    target: 500,
    rewardGold: 300,
    rewardGems: 4,
    difficulty: QuestDifficulty.easy,
    actionType: QuestActionType.gold,
  ),
  const DailyQuestModel(
    id: 'q_potion_2',
    title: 'Hayatta Kalma',
    description: '2 adet Can/Enerji iksiri bul',
    iconEmoji: '🧪',
    target: 2,
    rewardGold: 350,
    rewardGems: 5,
    difficulty: QuestDifficulty.easy,
    actionType: QuestActionType.potion,
  ),
  const DailyQuestModel(
    id: 'q_tool_3',
    title: 'Alet Koleksiyoneri',
    description: 'Kutulardan 3 farklı alet çıkar',
    iconEmoji: '🛠️',
    target: 3,
    rewardGold: 600,
    rewardGems: 8,
    difficulty: QuestDifficulty.medium,
    actionType: QuestActionType.tool,
  ),
  const DailyQuestModel(
    id: 'q_combo_5',
    title: 'Seri Kazıcı',
    description: 'Kazıda 5x kombo serisine ulaş',
    iconEmoji: '🔥',
    target: 5,
    rewardGold: 750,
    rewardGems: 10,
    difficulty: QuestDifficulty.medium,
    actionType: QuestActionType.combo,
  ),
  const DailyQuestModel(
    id: 'q_emerald_3',
    title: 'Zümrüt Madencisi',
    description: '3 adet yeşil zümrüt damarı kır',
    iconEmoji: '🟢',
    target: 3,
    rewardGold: 900,
    rewardGems: 12,
    difficulty: QuestDifficulty.medium,
    actionType: QuestActionType.emerald,
  ),
  const DailyQuestModel(
    id: 'q_tnt_3',
    title: 'Patlama Uzmanı',
    description: '3 adet TNT kutusu veya dinamit patlat',
    iconEmoji: '💣',
    target: 3,
    rewardGold: 1500,
    rewardGems: 18,
    difficulty: QuestDifficulty.hard,
    actionType: QuestActionType.tnt,
  ),
  const DailyQuestModel(
    id: 'q_chest_2',
    title: 'Hazine Avcısı',
    description: '2 adet gizli hazine sandığı aç',
    iconEmoji: '🏛️',
    target: 2,
    rewardGold: 1800,
    rewardGems: 20,
    difficulty: QuestDifficulty.hard,
    actionType: QuestActionType.chest,
  ),
  const DailyQuestModel(
    id: 'q_pvp_1',
    title: 'Arena Savaşçısı',
    description: 'Multiplayer veya BR maçında rakip vur',
    iconEmoji: '⚔️',
    target: 1,
    rewardGold: 2200,
    rewardGems: 25,
    difficulty: QuestDifficulty.hard,
    actionType: QuestActionType.pvp,
  ),
  const DailyQuestModel(
    id: 'q_boss_1',
    title: 'Titan Avcısı',
    description: '1 adet 500 HP Titan Boss Çekirdeğini yok et',
    iconEmoji: '👑',
    target: 1,
    rewardGold: 3500,
    rewardGems: 35,
    difficulty: QuestDifficulty.legendary,
    actionType: QuestActionType.boss,
  ),
  const DailyQuestModel(
    id: 'q_depth_5',
    title: 'Derin Maden Fatihi',
    description: '5. Derinlik / Katman seviyesine ulaş',
    iconEmoji: '🚀',
    target: 5,
    rewardGold: 4000,
    rewardGems: 40,
    difficulty: QuestDifficulty.legendary,
    actionType: QuestActionType.depth,
  ),
  const DailyQuestModel(
    id: 'q_prestige_1',
    title: 'Kusursuz Madenci',
    description: 'Prestij yapıp rütbeni 1 seviye yükselt',
    iconEmoji: '⚡',
    target: 1,
    rewardGold: 5000,
    rewardGems: 50,
    difficulty: QuestDifficulty.legendary,
    actionType: QuestActionType.prestige,
  ),
];

class GameState {
  final PlayerStateModel player;
  final GridModel grid;
  final String? lastMessage;
  final Position? lastDamagedTile;
  final BattlePhaseState battlePhase;
  final GameMode gameMode;
  final int comboCount;
  final int lastDigTimestamp;
  final String? activeReactionEmoji;
  final int lastQuestResetTimestamp;
  final List<DailyQuestModel> quests;

  const GameState({
    required this.player,
    required this.grid,
    this.lastMessage,
    this.lastDamagedTile,
    this.battlePhase = const BattlePhaseState(),
    this.gameMode = GameMode.solo,
    this.comboCount = 0,
    this.lastDigTimestamp = 0,
    this.activeReactionEmoji,
    this.lastQuestResetTimestamp = 0,
    this.quests = const [],
  });

  GameState copyWith({
    PlayerStateModel? player,
    GridModel? grid,
    String? lastMessage,
    Position? lastDamagedTile,
    BattlePhaseState? battlePhase,
    GameMode? gameMode,
    int? comboCount,
    int? lastDigTimestamp,
    String? activeReactionEmoji,
    int? lastQuestResetTimestamp,
    List<DailyQuestModel>? quests,
  }) {
    return GameState(
      player: player ?? this.player,
      grid: grid ?? this.grid,
      lastMessage: lastMessage ?? this.lastMessage,
      lastDamagedTile: lastDamagedTile ?? this.lastDamagedTile,
      battlePhase: battlePhase ?? this.battlePhase,
      gameMode: gameMode ?? this.gameMode,
      comboCount: comboCount ?? this.comboCount,
      lastDigTimestamp: lastDigTimestamp ?? this.lastDigTimestamp,
      activeReactionEmoji: activeReactionEmoji ?? this.activeReactionEmoji,
      lastQuestResetTimestamp: lastQuestResetTimestamp ?? this.lastQuestResetTimestamp,
      quests: quests ?? this.quests,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _energyTimer;
  Timer? _battleTimer;

  GameNotifier()
      : super(
          GameState(
            player: PlayerStateModel.initial(),
            grid: GridGenerator.generateStage(stage: 1, depth: 1),
            gameMode: GameMode.solo,
            quests: defaultWeeklyQuests(),
            lastQuestResetTimestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ) {
    _startEnergyTimer();
    loadSavedPlayer();
  }

  void _startEnergyTimer() {
    _energyTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      regenerateEnergy(1);
    });
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    _battleTimer?.cancel();
    super.dispose();
  }

  void _triggerHaptic(String type) {
    try {
      if (type == 'heavy') {
        HapticFeedback.heavyImpact();
      } else if (type == 'selection') {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  void regenerateEnergy(int amount) {
    if (state.player.energy < state.player.maxEnergy) {
      final newEnergy = (state.player.energy + amount).clamp(0, state.player.maxEnergy);
      state = state.copyWith(
        player: state.player.copyWith(energy: newEnergy),
      );
    }
  }

  void toggleSound() {
    state = state.copyWith(
      player: state.player.copyWith(soundEnabled: !state.player.soundEnabled),
    );
  }

  void activateDoubleBonus() {
    if (state.player.gold >= 500 && !state.player.doubleBonusActive) {
      state = state.copyWith(
        player: state.player.copyWith(
          gold: state.player.gold - 500,
          doubleBonusActive: true,
        ),
        lastMessage: '2x Bonus Aktif Edildi!',
      );
    }
  }

  void changeDirection(PlayerDirection direction) {
    int dRow = 0;
    int dCol = 0;
    switch (direction) {
      case PlayerDirection.up:
        dRow = -1;
        break;
      case PlayerDirection.down:
        dRow = 1;
        break;
      case PlayerDirection.left:
        dCol = -1;
        break;
      case PlayerDirection.right:
        dCol = 1;
        break;
    }

    final curPos = state.grid.playerPosition;
    final targetRow = curPos.row + dRow;
    final targetCol = curPos.col + dCol;

    // Sınır kontrolü
    if (targetRow < 0 || targetRow >= state.grid.rows ||
        targetCol < 0 || targetCol >= state.grid.columns) {
      state = state.copyWith(
        grid: state.grid.copyWith(playerFacing: direction),
      );
      return;
    }

    final targetTile = state.grid.tiles[targetRow][targetCol];

    // Hedef boş veya kazılmışsa yürü
    if (targetTile.isCleared || targetTile.type == TileType.empty) {
      state = state.copyWith(
        grid: state.grid.copyWith(
          playerPosition: Position(targetRow, targetCol),
          playerFacing: direction,
        ),
      );
    } else {
      // Hedef doluysa o yöne dön ve hedefle
      state = state.copyWith(
        grid: state.grid.copyWith(playerFacing: direction),
      );
    }
  }

  void digTargetTile() {
    final targetPos = state.grid.targetCellPosition;
    final targetRow = targetPos.row;
    final targetCol = targetPos.col;

    // 1. Önce hedeflenen hücrede rakip bir oyuncu var mı kontrol et (PvP Saldırısı)
    RemotePlayerModel? targetPlayer;
    for (final p in state.grid.otherPlayers) {
      if (p.position.row == targetRow && p.position.col == targetCol && p.isAlive) {
        targetPlayer = p;
        break;
      }
    }

    if (targetPlayer != null) {
      // Rakip Oyuncuya Saldırı!
      if (state.player.energy < 4) {
        state = state.copyWith(lastMessage: 'Vurmak için en az 4 Enerji gerekli! ⚡');
        return;
      }

      final int attackDmg = state.battlePhase.isDeathmatch
          ? (state.player.pvpDamageBonus * 1.5).round()
          : state.player.pvpDamageBonus;
      final int newTargetHp = max(0, targetPlayer.hp - attackDmg);
      final bool isTargetDead = newTargetHp <= 0;

      final updatedOthers = state.grid.otherPlayers.map((p) {
        if (p.uid == targetPlayer!.uid) {
          return p.copyWith(
            hp: newTargetHp,
          );
        }
        return p;
      }).toList();

      final newEnergy = max(0, state.player.energy - 4);
      final String attackMsg = isTargetDead
          ? '💀 ${targetPlayer.displayName} ELENDİ! (+$attackDmg Hasar)'
          : '⚔️ ${targetPlayer.displayName}\'e $attackDmg Hasar vurdunuz! (Kalan Canı: $newTargetHp ❤️)';

      state = state.copyWith(
        player: state.player.copyWith(energy: newEnergy),
        grid: state.grid.copyWith(otherPlayers: updatedOthers),
        lastMessage: attackMsg,
      );

      _trackQuestProgress(pvp: 1);
      _saveState();

      _checkBattleRoyaleStatus();
      return;
    }

    final targetTile = state.grid.tiles[targetRow][targetCol];

    // Hedef zaten boşsa ve rakip yoksa işlem yapma
    if (targetTile.isCleared || targetTile.type == TileType.empty) {
      return;
    }

    // Sabit / Kırılmaz Sarı Blok Kontrolü
    if (targetTile.isUnbreakable || targetTile.type == TileType.solidGold) {
      state = state.copyWith(
        lastMessage: 'Bu sarı blok sabittir, kırılamaz!',
      );
      return;
    }

    // 2. Hedeflenen Hücre Taş ise: Kazı İşlemi
    if (state.player.energy <= 0) {
      state = state.copyWith(
        lastMessage: 'Enerji tükendi! Kutu kırarak enerji toplayın. ⚡',
      );
      return;
    }

    // Kazı işlemi - Enerji tüketimi
    final newEnergy = max(0, state.player.energy - 1);

    // Kombo & Kritik Vuruş Hesabı
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    int currentCombo = (nowMs - state.lastDigTimestamp < 2500) ? state.comboCount + 1 : 1;
    double comboMultiplier = 1.0;
    if (currentCombo >= 5) {
      comboMultiplier = 1.5; // %50 Kombo Bonusu
    } else if (currentCombo >= 3) {
      comboMultiplier = 1.25; // %25 Kombo Bonusu
    }

    // Hasar hesabı (Aktif Alet Bonusu + Kombo Çarpanı)
    int damage = (state.player.tileDamageBonus * comboMultiplier).round();
    if (state.battlePhase.isDeathmatch) {
      damage = (damage * 1.5).round();
    }

    final int newHp = targetTile.currentHp - damage;

    if (newHp <= 0) {
      // Tile kırıldı!
      int goldReward = (targetTile.rewardGold * comboMultiplier).round();
      if (state.player.doubleBonusActive) goldReward *= 2;
      int gemReward = targetTile.rewardGems;
      int energyReward = targetTile.rewardEnergy;
      int hpReward = targetTile.rewardHp;
      ToolType? toolReward = targetTile.rewardTool;
      int copperReward = targetTile.rewardCopper;
      int ironReward = targetTile.rewardIron;
      int emeraldReward = targetTile.rewardEmerald;
      int fossilReward = targetTile.rewardFossil;
      int dynamiteReward = targetTile.rewardDynamite;

      final luckUpgrade = state.player.upgrades[UpgradeType.luck]!;
      final bool luckTriggered = (luckUpgrade.currentValue > 0);
      if (luckTriggered && goldReward > 0) {
        goldReward += (goldReward * (luckUpgrade.currentValue / 100.0)).round();
      }

      var newTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [for (int c = 0; c < state.grid.columns; c++) state.grid.tiles[r][c]]
      ];

      newTiles[targetRow][targetCol] = targetTile.copyWith(
        currentHp: 0,
        isCleared: true,
        type: TileType.empty,
      );

      int extraCleared = 1;
      String rewardMsg = '';
      int newHpVal = state.player.hp;
      List<ToolType> currentTools = List<ToolType>.from(state.player.inventoryTools);
      int activeToolIdx = state.player.activeToolIndex;

      // 🛠️ Yeni Alet Bulunduysa Envantere Ekle (Max 5 Yuva)
      if (toolReward != null) {
        if (!currentTools.contains(toolReward)) {
          if (currentTools.length < 5) {
            currentTools.add(toolReward);
            activeToolIdx = currentTools.length - 1;
            rewardMsg = '🛠️ ${toolReward.displayName} Bulundu! (${toolReward.iconEmoji} Güç: +${toolReward.tileDamage})';
          } else {
            // Envanter doluysa aktif olanın yerine koy
            currentTools[activeToolIdx] = toolReward;
            rewardMsg = '🛠️ ${toolReward.displayName} ile değiştirildi!';
          }
        }
      }

      // ❤️ Can İksiri Bulunduysa
      if (hpReward > 0) {
        newHpVal = (newHpVal + hpReward).clamp(0, state.player.maxHp);
        rewardMsg = rewardMsg.isNotEmpty
            ? '$rewardMsg | +$hpReward Can ❤️'
            : (hpReward >= 10 ? '💛 BÜYÜK CAN BULUNDU! +$hpReward Can ❤️' : '❤️ +$hpReward Can Bulundu! (Can: $newHpVal)');
      }

      // Tile Tiplerine Göre Özel Efektler ve Bildirimler
      if (targetTile.type == TileType.tnt) {
        // 🧨 TNT Patlaması: 3x3 Alan Temizleme & Dinamit Ödülü
        rewardMsg = '💥 TNT PATLADI! 3x3 Alan Temizlendi! (+1 Dinamit 💣)';
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = targetRow + dr;
            final nc = targetCol + dc;
            if (nr >= 0 && nr < state.grid.rows && nc >= 0 && nc < state.grid.columns) {
              final neighbor = newTiles[nr][nc];
              if (!neighbor.isCleared && !neighbor.isUnbreakable && neighbor.type != TileType.empty) {
                goldReward += neighbor.rewardGold;
                gemReward += neighbor.rewardGems;
                copperReward += neighbor.rewardCopper;
                ironReward += neighbor.rewardIron;
                emeraldReward += neighbor.rewardEmerald;
                fossilReward += neighbor.rewardFossil;
                energyReward += neighbor.rewardEnergy;

                newTiles[nr][nc] = neighbor.copyWith(
                  currentHp: 0,
                  isCleared: true,
                  type: TileType.empty,
                );
                extraCleared++;
              }
            }
          }
        }
      } else if (targetTile.type == TileType.hiddenMine) {
        // 💣 Gizli Bomba Patlaması: Net -30 Can Hasarı & 3x3 Alan Patlaması
        newHpVal = max(0, state.player.hp - 30);
        if (newHpVal <= 0) {
          newHpVal = 0;
          rewardMsg = '💀 GİZLİ BOMBA! Canınız tükendi ve elendiniz! 💀';
        } else {
          rewardMsg = '💥 GİZLİ BOMBA PATLADI! -30 CAN GİTTİ! (Kalan Can: $newHpVal ❤️)';
        }

        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = targetRow + dr;
            final nc = targetCol + dc;
            if (nr >= 0 && nr < state.grid.rows && nc >= 0 && nc < state.grid.columns) {
              final neighbor = newTiles[nr][nc];
              if (!neighbor.isCleared && !neighbor.isUnbreakable && neighbor.type != TileType.empty) {
                goldReward += neighbor.rewardGold;
                gemReward += neighbor.rewardGems;
                energyReward += neighbor.rewardEnergy;

                newTiles[nr][nc] = neighbor.copyWith(
                  currentHp: 0,
                  isCleared: true,
                  type: TileType.empty,
                );
                extraCleared++;
              }
            }
          }
        }
      } else if (targetTile.type == TileType.chest) {
        rewardMsg = '📦 Hazine Sandığı Bulundu! +$goldReward 🟡 +$gemReward 💎';
      } else if (targetTile.type == TileType.emeraldOre) {
        rewardMsg = '🟢 Zümrüt Damarı Bulundu! +1 Zümrüt +$gemReward 💎';
      } else if (targetTile.type == TileType.bossCore) {
        rewardMsg = '👑 TİTAN ÇEKİRDEĞİ KIRILDI! +$goldReward 🟡 +$gemReward 💎';
      } else if (targetTile.type == TileType.potion) {
        newHpVal = (newHpVal + 30).clamp(0, state.player.maxHp);
        rewardMsg = '🧪 İksir Bulundu! +30 Can ❤️ +$energyReward Enerji ⚡';
      } else if (rewardMsg.isEmpty) {
        if (energyReward > 0) {
          rewardMsg = '⚡ Enerji Bulundu! +$energyReward Enerji';
        } else if (copperReward > 0 || ironReward > 0) {
          rewardMsg = copperReward > 0 ? '🟤 Bakır Madeni (+1 Bakır)' : '⚪ Demir Madeni (+1 Demir)';
        } else if (goldReward > 0) {
          rewardMsg = '🟡 +$goldReward Altın Bulundu!';
        }
      }

      final int newClearedCount = state.grid.tilesClearedInStage + extraCleared;
      final int newGold = state.player.gold + goldReward;
      final int newGems = state.player.gems + gemReward;
      final int newCopper = state.player.copper + copperReward;
      final int newIron = state.player.iron + ironReward;
      final int newEmeralds = state.player.emeralds + emeraldReward;
      final int newFossils = state.player.fossils + fossilReward;
      final int newDynamites = state.player.dynamites + dynamiteReward;
      final int newLifetime = state.player.lifetimeEarnings + goldReward;
      final int finalEnergy = (newEnergy + energyReward).clamp(0, state.player.maxEnergy);

      state = state.copyWith(
        player: state.player.copyWith(
          gold: newGold,
          gems: newGems,
          hp: newHpVal,
          copper: newCopper,
          iron: newIron,
          emeralds: newEmeralds,
          fossils: newFossils,
          dynamites: newDynamites,
          energy: finalEnergy,
          lifetimeEarnings: newLifetime,
          inventoryTools: currentTools,
          activeToolIndex: activeToolIdx,
        ),
        grid: state.grid.copyWith(
          tiles: newTiles,
          playerPosition: Position(targetRow, targetCol),
          tilesClearedInStage: newClearedCount,
        ),
        lastDamagedTile: Position(targetRow, targetCol),
        comboCount: currentCombo,
        lastDigTimestamp: nowMs,
        lastMessage: currentCombo >= 3
            ? '🔥 COMBO x$currentCombo! (+$goldReward 🟡)'
            : (rewardMsg.isNotEmpty ? rewardMsg : state.lastMessage),
      );

      _trackQuestProgress(
        tiles: 1,
        gold: goldReward,
        potions: (targetTile.type == TileType.potion || hpReward > 0) ? 1 : 0,
        tools: toolReward != null ? 1 : 0,
        combo: currentCombo,
        emeralds: (targetTile.type == TileType.emeraldOre || emeraldReward > 0) ? 1 : 0,
        tnt: targetTile.type == TileType.tnt ? 1 : 0,
        chests: targetTile.type == TileType.chest ? 1 : 0,
        boss: targetTile.type == TileType.bossCore ? 1 : 0,
      );
      _saveState();

      if (targetTile.type == TileType.hiddenMine || targetTile.type == TileType.tnt) {
        _triggerHaptic('heavy');
      } else {
        _triggerHaptic('light');
      }

      if (newClearedCount >= state.grid.totalTilesInStage) {
        _advanceStage();
      }
    } else {
      // Hasar aldı ama kırılmadı
      _triggerHaptic('selection');
      final updatedTile = targetTile.copyWith(currentHp: newHp);
      final newTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetRow && c == targetCol) updatedTile else state.grid.tiles[r][c]
          ]
      ];

      state = state.copyWith(
        player: state.player.copyWith(energy: newEnergy),
        grid: state.grid.copyWith(tiles: newTiles),
        lastDamagedTile: Position(targetRow, targetCol),
      );
    }
  }

  void moveOrDig(int dRow, int dCol) {
    PlayerDirection dir = PlayerDirection.down;
    if (dRow < 0) dir = PlayerDirection.up;
    if (dRow > 0) dir = PlayerDirection.down;
    if (dCol < 0) dir = PlayerDirection.left;
    if (dCol > 0) dir = PlayerDirection.right;

    changeDirection(dir);
    digTargetTile();
  }

  void _advanceStage() {
    final nextStage = state.grid.stage + 1;
    final nextDepth = state.grid.depth + 1;
    final newHighest = nextDepth > state.player.highestDepth ? nextDepth : state.player.highestDepth;

    final int newUnlocked = max(state.player.unlockedStage, nextStage);

    state = state.copyWith(
      player: state.player.copyWith(
        highestDepth: newHighest,
        unlockedStage: newUnlocked,
      ),
      grid: GridGenerator.generateStage(
        stage: nextStage,
        depth: nextDepth,
      ),
      lastMessage: 'Bölüm $nextStage Tamamlandı! Yeni bölüme geçildi.',
    );

    _trackQuestProgress(depth: nextDepth);
    _saveState();
  }

  bool purchaseUpgrade(UpgradeType type) {
    final upgrade = state.player.upgrades[type];
    if (upgrade == null || upgrade.isMaxLevel) return false;

    if (state.player.gold < upgrade.cost) {
      state = state.copyWith(lastMessage: 'Yetersiz altın!');
      return false;
    }

    final newGold = state.player.gold - upgrade.cost;
    final newLevel = upgrade.level + 1;

    int newCurVal = upgrade.nextValue;
    int nextVal = newCurVal;
    int newCost = (upgrade.cost * 1.35).round();
    String newDesc = '';

    switch (type) {
      case UpgradeType.pickaxe:
        nextVal = newCurVal + 1;
        newDesc = 'Hasar: $newCurVal → $nextVal';
        break;
      case UpgradeType.hammer:
        nextVal = newCurVal + 3;
        newDesc = 'Hasar: $newCurVal → $nextVal (kaya)';
        break;
      case UpgradeType.luck:
        nextVal = newCurVal + 5;
        newDesc = 'Şans: +%$newCurVal altın bulma';
        break;
      case UpgradeType.energy:
        nextVal = newCurVal + 15;
        newDesc = 'Enerji: $newCurVal → $nextVal';
        break;
    }

    final updatedUpgrade = upgrade.copyWith(
      level: newLevel,
      currentValue: newCurVal,
      nextValue: nextVal,
      cost: newCost,
      description: newDesc,
    );

    final newUpgrades = Map<UpgradeType, UpgradeModel>.from(state.player.upgrades);
    newUpgrades[type] = updatedUpgrade;

    int newMaxEnergy = state.player.maxEnergy;
    int newEnergy = state.player.energy;
    if (type == UpgradeType.energy) {
      newMaxEnergy = newCurVal;
      newEnergy = newEnergy + 15;
    }

    state = state.copyWith(
      player: state.player.copyWith(
        gold: newGold,
        maxEnergy: newMaxEnergy,
        energy: newEnergy,
        upgrades: newUpgrades,
      ),
      lastMessage: '${upgrade.name} Lv $newLevel yükseltildi!',
    );

    return true;
  }

  void sellAllOres() {
    final int copper = state.player.copper;
    final int iron = state.player.iron;
    final int emeralds = state.player.emeralds;

    if (copper == 0 && iron == 0 && emeralds == 0) {
      state = state.copyWith(lastMessage: 'Satılacak maden bulunamadı!');
      return;
    }

    final int earnedGold = (copper * 15) + (iron * 35) + (emeralds * 100);
    final int earnedGems = emeralds; // Zümrüt satılınca her biri +1 elmas da verir!

    final newGold = state.player.gold + earnedGold;
    final newGems = state.player.gems + earnedGems;
    final newLifetime = state.player.lifetimeEarnings + earnedGold;

    state = state.copyWith(
      player: state.player.copyWith(
        gold: newGold,
        gems: newGems,
        copper: 0,
        iron: 0,
        emeralds: 0,
        lifetimeEarnings: newLifetime,
      ),
      lastMessage: earnedGems > 0
          ? 'Tüm madenler satıldı! +$earnedGold 🟡 +$earnedGems 💎'
          : 'Tüm madenler satıldı! +$earnedGold 🟡',
    );
  }

  bool useDynamite() {
    if (state.player.dynamites <= 0) {
      state = state.copyWith(lastMessage: 'Çantanızda Dinamit yok!');
      return false;
    }

    final targetPos = state.grid.targetCellPosition;
    final targetRow = targetPos.row;
    final targetCol = targetPos.col;

    int goldReward = 0;
    int gemReward = 0;
    int copperReward = 0;
    int ironReward = 0;
    int emeraldReward = 0;
    int energyReward = 0;

    var newTiles = [
      for (int r = 0; r < state.grid.rows; r++)
        [
          for (int c = 0; c < state.grid.columns; c++) state.grid.tiles[r][c]
        ]
    ];

    int extraCleared = 0;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        final nr = targetRow + dr;
        final nc = targetCol + dc;
        if (nr >= 0 && nr < state.grid.rows && nc >= 0 && nc < state.grid.columns) {
          final target = newTiles[nr][nc];
          if (!target.isCleared && !target.isUnbreakable && target.type != TileType.empty) {
            goldReward += target.rewardGold;
            gemReward += target.rewardGems;
            copperReward += target.rewardCopper;
            ironReward += target.rewardIron;
            emeraldReward += target.rewardEmerald;
            energyReward += target.rewardEnergy;

            newTiles[nr][nc] = target.copyWith(
              currentHp: 0,
              isCleared: true,
              type: TileType.empty,
            );
            extraCleared++;
          }
        }
      }
    }

    final int newClearedCount = state.grid.tilesClearedInStage + extraCleared;
    final int newGold = state.player.gold + goldReward;
    final int newGems = state.player.gems + gemReward;
    final int newCopper = state.player.copper + copperReward;
    final int newIron = state.player.iron + ironReward;
    final int newEmeralds = state.player.emeralds + emeraldReward;
    final int newDynamites = state.player.dynamites - 1;
    final int newLifetime = state.player.lifetimeEarnings + goldReward;
    final int finalEnergy = (state.player.energy + energyReward).clamp(0, state.player.maxEnergy);

    state = state.copyWith(
      player: state.player.copyWith(
        gold: newGold,
        gems: newGems,
        copper: newCopper,
        iron: newIron,
        emeralds: newEmeralds,
        dynamites: newDynamites,
        energy: finalEnergy,
        lifetimeEarnings: newLifetime,
      ),
      grid: state.grid.copyWith(
        tiles: newTiles,
        tilesClearedInStage: newClearedCount,
      ),
      lastMessage: '💣 DİNAMİT PATLATILDI! +$goldReward 🟡 toplanıldı!',
    );

    _trackQuestProgress(tnt: 1, gold: goldReward);
    _saveState();

    if (newClearedCount >= state.grid.totalTilesInStage) {
      _advanceStage();
    }

    return true;
  }

  void initMultiplayerTeam(List<RemotePlayerModel> allPlayers, {int? seed, int stage = 1}) {
    final int playerCount = allPlayers.isNotEmpty ? allPlayers.length : 1;
    final grid = GridGenerator.generateStage(
      stage: stage,
      depth: stage,
      seed: seed,
      playerCount: playerCount,
    );

    // 1. Oyuncu (Siz) Sol Üst köşede: Position(2, 2)
    final otherPlayers = allPlayers.length > 1 ? allPlayers.sublist(1) : <RemotePlayerModel>[];

    // Diğer Oyuncuların Spawn Noktaları (Sağ-Üst, Sol-Alt, Sağ-Alt, Merkez ve Kenarlar)
    final spawnPoints = [
      Position(2, grid.columns - 3),                   // 2. Oyuncu: Sağ Üst
      Position(grid.rows - 3, 2),                      // 3. Oyuncu: Sol Alt
      Position(grid.rows - 3, grid.columns - 3),       // 4. Oyuncu: Sağ Alt
      Position(grid.rows ~/ 2, grid.columns ~/ 2),     // 5. Oyuncu: Merkez
      Position(2, grid.columns ~/ 2),                  // 6. Oyuncu: Üst Orta
      Position(grid.rows - 3, grid.columns ~/ 2),      // 7. Oyuncu: Alt Orta
      Position(grid.rows ~/ 2, 2),                     // 8. Oyuncu: Sol Orta
      Position(grid.rows ~/ 2, grid.columns - 3),      // 9. Oyuncu: Sağ Orta
    ];

    final List<RemotePlayerModel> placedOthers = [];
    for (int i = 0; i < otherPlayers.length; i++) {
      final spawn = spawnPoints[i % spawnPoints.length];
      placedOthers.add(otherPlayers[i].copyWith(
        position: spawn,
      ));
    }

    state = state.copyWith(
      grid: grid.copyWith(
        playerPosition: const Position(2, 2),
        otherPlayers: placedOthers,
      ),
      lastMessage: '$playerCount Kişilik Battle Royale Başladı! Farklı köşelerde doğdunuz!',
    );

    startBattleRoyaleMatch();
  }

  void simulateTeammatesAction() {
    if (state.grid.otherPlayers.isEmpty) return;

    final updatedOthers = <RemotePlayerModel>[];
    var currentTiles = [
      for (int r = 0; r < state.grid.rows; r++)
        [for (int c = 0; c < state.grid.columns; c++) state.grid.tiles[r][c]]
    ];
    int extraCleared = 0;
    int sharedGold = 0;

    for (final teammate in state.grid.otherPlayers) {
      // Rastgele bir komşu yöne hamle yap
      final directions = [
        const Position(-1, 0),
        const Position(1, 0),
        const Position(0, -1),
        const Position(0, 1),
      ];
      final dir = directions[Random().nextInt(directions.length)];
      final targetRow = (teammate.position.row + dir.row).clamp(0, state.grid.rows - 1);
      final targetCol = (teammate.position.col + dir.col).clamp(0, state.grid.columns - 1);

      final targetTile = currentTiles[targetRow][targetCol];

      if (targetTile.isCleared || targetTile.type == TileType.empty) {
        // Boş alana yürü
        updatedOthers.add(teammate.copyWith(
          position: Position(targetRow, targetCol),
        ));
      } else if (!targetTile.isUnbreakable) {
        // Taşa vur
        final int dmg = 6;
        final int newHp = targetTile.currentHp - dmg;
        if (newHp <= 0) {
          currentTiles[targetRow][targetCol] = targetTile.copyWith(
            currentHp: 0,
            isCleared: true,
            type: TileType.empty,
          );
          extraCleared++;
          sharedGold += (targetTile.rewardGold * 0.5).round();
        } else {
          currentTiles[targetRow][targetCol] = targetTile.copyWith(currentHp: newHp);
        }
        updatedOthers.add(teammate.copyWith(
          damageDealt: teammate.damageDealt + dmg,
          tilesCleared: teammate.tilesCleared + (newHp <= 0 ? 1 : 0),
          goldEarned: teammate.goldEarned + (newHp <= 0 ? targetTile.rewardGold : 0),
        ));
      } else {
        updatedOthers.add(teammate);
      }
    }

    state = state.copyWith(
      grid: state.grid.copyWith(
        tiles: currentTiles,
        otherPlayers: updatedOthers,
        tilesClearedInStage: state.grid.tilesClearedInStage + extraCleared,
      ),
      player: state.player.copyWith(
        gold: state.player.gold + sharedGold,
      ),
    );
  }

  void selectInventoryTool(int index) {
    if (index >= 0 && index < state.player.inventoryTools.length) {
      _triggerHaptic('selection');
      state = state.copyWith(
        player: state.player.copyWith(activeToolIndex: index),
        lastMessage: 'Aktif Silah: ${state.player.inventoryTools[index].displayName} ${state.player.inventoryTools[index].iconEmoji}',
      );
    }
  }

  void tapTile(int targetRow, int targetCol) {
    final pPos = state.grid.playerPosition;
    final int dr = targetRow - pPos.row;
    final int dc = targetCol - pPos.col;

    if (dr == 0 && dc == 0) return;

    // Komşu kutu ise doğrudan yöne dönüp kaz
    if (dr.abs() <= 1 && dc.abs() <= 1 && (dr == 0 || dc == 0)) {
      if (dr == -1) changeDirection(PlayerDirection.up);
      if (dr == 1) changeDirection(PlayerDirection.down);
      if (dc == -1) changeDirection(PlayerDirection.left);
      if (dc == 1) changeDirection(PlayerDirection.right);

      digTargetTile();
    } else {
      // Uzaktaysa o yöne doğru 1 adım yaklaş
      int stepR = 0;
      int stepC = 0;
      if (dc.abs() > 0) {
        stepC = dc > 0 ? 1 : -1;
      } else {
        stepR = dr > 0 ? 1 : -1;
      }
      moveOrDig(stepR, stepC);
    }
  }

  void equipSkin(String skinId, int costGems) {
    if (state.player.equippedSkinId == skinId) return;

    if (costGems > 0 && state.player.gems < costGems) {
      state = state.copyWith(lastMessage: 'Yetersiz Elmas! $costGems 💎 gerekli.');
      return;
    }

    final newGems = costGems > 0 ? state.player.gems - costGems : state.player.gems;
    _triggerHaptic('selection');
    state = state.copyWith(
      player: state.player.copyWith(
        equippedSkinId: skinId,
        gems: newGems,
      ),
      lastMessage: 'Yeni Kostüm Kuşanıldı!',
    );
    _saveState();
  }

  void sendReaction(String emoji) {
    _triggerHaptic('selection');
    state = state.copyWith(
      activeReactionEmoji: emoji,
      lastMessage: 'Tepki Gönderildi: $emoji',
    );

    // 2 saniye sonra emojiyi kaldır
    Timer(const Duration(seconds: 2), () {
      if (mounted && state.activeReactionEmoji == emoji) {
        state = state.copyWith(activeReactionEmoji: null);
      }
    });
  }

  void claimQuestReward(String questId) {
    final questIdx = state.quests.indexWhere((q) => q.id == questId);
    if (questIdx < 0) return;

    final quest = state.quests[questIdx];
    if (!quest.isCompleted || quest.isClaimed) return;

    _triggerHaptic('heavy');
    final updatedQuests = List<DailyQuestModel>.from(state.quests);
    updatedQuests[questIdx] = quest.copyWith(isClaimed: true);

    state = state.copyWith(
      player: state.player.copyWith(
        gold: state.player.gold + quest.rewardGold,
        gems: state.player.gems + quest.rewardGems,
      ),
      quests: updatedQuests,
      lastMessage: '🏆 Görev Tamamlandı! +${quest.rewardGold} 🟡 +${quest.rewardGems} 💎',
    );
    _saveState();
  }

  void _checkAndResetWeeklyQuests() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    const int sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
    if (state.lastQuestResetTimestamp == 0 || (now - state.lastQuestResetTimestamp) >= sevenDaysMs) {
      state = state.copyWith(
        quests: defaultWeeklyQuests(),
        lastQuestResetTimestamp: now,
      );
      _saveState();
    }
  }

  void _trackQuestProgress({
    int tiles = 0,
    int gold = 0,
    int potions = 0,
    int tools = 0,
    int combo = 0,
    int emeralds = 0,
    int tnt = 0,
    int chests = 0,
    int pvp = 0,
    int boss = 0,
    int depth = 0,
    int prestige = 0,
  }) {
    _checkAndResetWeeklyQuests();

    final updatedQuests = state.quests.map((q) {
      if (q.isClaimed) return q;

      int addVal = 0;
      if (q.actionType == QuestActionType.dig && tiles > 0) addVal = tiles;
      if (q.actionType == QuestActionType.gold && gold > 0) addVal = gold;
      if (q.actionType == QuestActionType.potion && potions > 0) addVal = potions;
      if (q.actionType == QuestActionType.tool && tools > 0) addVal = tools;
      if (q.actionType == QuestActionType.combo && combo > 0) {
        if (combo > q.current) return q.copyWith(current: combo);
        return q;
      }
      if (q.actionType == QuestActionType.emerald && emeralds > 0) addVal = emeralds;
      if (q.actionType == QuestActionType.tnt && tnt > 0) addVal = tnt;
      if (q.actionType == QuestActionType.chest && chests > 0) addVal = chests;
      if (q.actionType == QuestActionType.pvp && pvp > 0) addVal = pvp;
      if (q.actionType == QuestActionType.boss && boss > 0) addVal = boss;
      if (q.actionType == QuestActionType.depth && depth > 0) {
        if (depth > q.current) return q.copyWith(current: depth);
        return q;
      }
      if (q.actionType == QuestActionType.prestige && prestige > 0) addVal = prestige;

      if (addVal > 0) {
        return q.copyWith(current: q.current + addVal);
      }
      return q;
    }).toList();

    state = state.copyWith(quests: updatedQuests);
    _saveState();
  }

  void _saveState() {
    SaveService.savePlayer(state.player);
    SaveService.saveQuests(state.quests.map((q) => q.toJson()).toList(), state.lastQuestResetTimestamp);
  }

  Future<void> loadSavedPlayer() async {
    try {
      final saved = await SaveService.loadPlayer();
      final savedQuestsData = await SaveService.loadQuests();

      if (!mounted) return;

      List<DailyQuestModel> loadedQuests = state.quests;
      int lastReset = state.lastQuestResetTimestamp;

      if (savedQuestsData != null) {
        try {
          final List<dynamic> qList = savedQuestsData['quests'] as List<dynamic>;
          loadedQuests = qList.map((j) => DailyQuestModel.fromJson(j as Map<String, dynamic>)).toList();
          lastReset = savedQuestsData['lastReset'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        } catch (_) {}
      }

      if (!mounted) return;

      state = state.copyWith(
        player: saved ?? state.player,
        quests: loadedQuests.isNotEmpty ? loadedQuests : defaultWeeklyQuests(),
        lastQuestResetTimestamp: lastReset,
      );
      _checkAndResetWeeklyQuests();
    } catch (_) {}
  }

  void startStage(int stageNumber) {
    _battleTimer?.cancel();
    final int safeStage = stageNumber.clamp(1, 500);

    state = state.copyWith(
      gameMode: GameMode.solo,
      battlePhase: const BattlePhaseState(phase: BattlePhase.finished),
      grid: GridGenerator.generateStage(
        stage: safeStage,
        depth: safeStage,
        playerCount: 1,
      ),
      lastMessage: 'Bölüm $safeStage Başladı! İyi kazılar!',
    );
  }

  void startSoloGame() {
    startStage(state.player.unlockedStage);
  }

  void startBattleRoyaleMatch() {
    _battleTimer?.cancel();

    // 1. 3 Saniyelik Geri Sayım Fazı
    state = state.copyWith(
      gameMode: GameMode.battleRoyale,
      battlePhase: const BattlePhaseState(
        phase: BattlePhase.countdown,
        countdownSeconds: 3,
        phaseSecondsRemaining: 180,
      ),
      lastMessage: '3 Saniye İçinde Başlıyor!',
    );

    int count = 3;
    _battleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;
      if (count > 0) {
        state = state.copyWith(
          battlePhase: state.battlePhase.copyWith(countdownSeconds: count),
          lastMessage: '$count...',
        );
      } else {
        timer.cancel();
        _startScavengePhase();
      }
    });
  }

  void _startScavengePhase() {
    state = state.copyWith(
      battlePhase: state.battlePhase.copyWith(
        phase: BattlePhase.scavenge,
        phaseSecondsRemaining: 180, // 3 Dakika
      ),
      lastMessage: '⚔️ OYUN BAŞLADI! Kutuları kır, alet ve can topla!',
    );

    int remaining = 180;
    _battleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining > 0) {
        state = state.copyWith(
          battlePhase: state.battlePhase.copyWith(phaseSecondsRemaining: remaining),
        );
        // Her 2 saniyede bir diğer oyuncular hareket etsin/kazsın
        if (remaining % 2 == 0) {
          simulateTeammatesAction();
        }
      } else {
        timer.cancel();
        _triggerDeathmatch();
      }
    });
  }

  void _triggerDeathmatch() {
    // 3 Dakika Bitti: Tüm kutular kalkar, sadece oyuncular kalır!
    final clearedTiles = [
      for (int r = 0; r < state.grid.rows; r++)
        [
          for (int c = 0; c < state.grid.columns; c++)
            state.grid.tiles[r][c].isUnbreakable
                ? state.grid.tiles[r][c]
                : state.grid.tiles[r][c].copyWith(
                    type: TileType.empty,
                    currentHp: 0,
                    isCleared: true,
                  )
        ]
    ];

    state = state.copyWith(
      grid: state.grid.copyWith(tiles: clearedTiles),
      battlePhase: state.battlePhase.copyWith(
        phase: BattlePhase.deathmatch,
        phaseSecondsRemaining: 60, // 1 Dakika Serbest Dövüş
      ),
      lastMessage: '⚔️ 3 DAKİKA DOLDU! Bütün kutular kalktı! SERBEST DÖVÜŞ BAŞLADI! ⚔️',
    );

    int deathmatchRemaining = 60;
    _battleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      deathmatchRemaining--;
      if (deathmatchRemaining > 0) {
        state = state.copyWith(
          battlePhase: state.battlePhase.copyWith(phaseSecondsRemaining: deathmatchRemaining),
        );
        simulateTeammatesAction();
      } else {
        timer.cancel();
        _checkBattleRoyaleStatus(forceEnd: true);
      }
    });
  }

  void _checkBattleRoyaleStatus({bool forceEnd = false}) {
    final List<String> alivePlayerNames = [];
    if (state.player.isAlive) {
      alivePlayerNames.add('Siz (Madenci)');
    }
    for (final p in state.grid.otherPlayers) {
      if (p.isAlive) {
        alivePlayerNames.add(p.displayName);
      }
    }

    if (alivePlayerNames.length == 1) {
      _battleTimer?.cancel();
      final winner = alivePlayerNames.first;
      state = state.copyWith(
        battlePhase: state.battlePhase.copyWith(
          phase: BattlePhase.finished,
          winnerName: winner,
          isDraw: false,
        ),
        lastMessage: '🏆 $winner KAZANDI! TEK HAYATTA KALAN!',
      );
    } else if (alivePlayerNames.isEmpty) {
      _battleTimer?.cancel();
      state = state.copyWith(
        battlePhase: state.battlePhase.copyWith(
          phase: BattlePhase.finished,
          isDraw: true,
        ),
        lastMessage: '🤝 Oyun Berabere Bitti!',
      );
    } else if (forceEnd) {
      _battleTimer?.cancel();
      state = state.copyWith(
        battlePhase: state.battlePhase.copyWith(
          phase: BattlePhase.finished,
          isDraw: true,
        ),
        lastMessage: '🤝 Süre Bitti! Oyun Berabere Kaldı!',
      );
    }
  }

  void prestigeReset() {
    final newRank = state.player.rank + 1;
    final newUpgrades = PlayerStateModel.defaultUpgrades();

    state = state.copyWith(
      player: state.player.copyWith(
        gold: 0,
        rank: newRank,
        energy: 80,
        maxEnergy: 80,
        upgrades: newUpgrades,
        doubleBonusActive: false,
      ),
      grid: GridGenerator.generateStage(stage: 1, depth: 1, biomeName: 'Kırmızı Toprak'),
      lastMessage: 'SIFIRLANDI! Yeni Rütbe: $newRank',
    );

    _trackQuestProgress(prestige: 1);
    _saveState();
  }
}

final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

