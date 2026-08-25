import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tile_model.dart';
import 'package:derin_kazi/features/mining/domain/models/tool_model.dart';
import 'package:derin_kazi/features/multiplayer/domain/models/remote_player_model.dart';
import 'package:derin_kazi/features/battle_royale/domain/models/battle_phase_model.dart';
import 'package:derin_kazi/core/audio/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioService.isTestMode = true;

  group('Battle Royale Mantık Testleri', () {
    test('Oyun 3 saniyelik geri sayım fazı ile başlamalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.startBattleRoyaleMatch();
      final state = container.read(gameNotifierProvider);

      expect(state.battlePhase.phase, BattlePhase.countdown);
      expect(state.battlePhase.countdownSeconds, 3);
      expect(state.gameMode, GameMode.battleRoyale);
      container.dispose();
    });

    test('Kutu kırıldığında envantere alet eklenmeli ve hasar gücü artmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final state = container.read(gameNotifierProvider);
      const playerPos = Position(1, 1);
      const targetPos = Position(2, 1);

      // Hedef tile'a Elmas Kazma ödülü koyalım
      final updatedTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetPos.row && c == targetPos.col)
                state.grid.tiles[r][c].copyWith(
                  maxHp: 2,
                  currentHp: 2,
                  rewardTool: ToolType.diamondPick,
                  isCleared: false,
                  type: TileType.rock,
                )
              else
                state.grid.tiles[r][c]
          ]
      ];

      notifier.state = state.copyWith(
        grid: state.grid.copyWith(
          playerPosition: playerPos,
          playerFacing: PlayerDirection.down,
          tiles: updatedTiles,
        ),
        player: state.player.copyWith(inventoryTools: [], activeToolIndex: 0),
      );

      notifier.digTargetTile();

      final afterState = container.read(gameNotifierProvider);
      expect(afterState.player.inventoryTools.contains(ToolType.diamondPick), true);
      expect(afterState.player.activeTool, ToolType.diamondPick);
      expect(afterState.player.tileDamageBonus, ToolType.diamondPick.tileDamage);
      expect(afterState.player.pvpDamageBonus, ToolType.diamondPick.pvpDamage);
    });

    test('Kutu kırıldığında +5 veya +10 Can iksiri oyuncunun canını artırmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final state = container.read(gameNotifierProvider);
      const playerPos = Position(1, 1);
      const targetPos = Position(2, 1);

      final updatedTiles = [
        for (int r = 0; r < state.grid.rows; r++)
          [
            for (int c = 0; c < state.grid.columns; c++)
              if (r == targetPos.row && c == targetPos.col)
                state.grid.tiles[r][c].copyWith(
                  maxHp: 2,
                  currentHp: 2,
                  rewardHp: 10, // 10 Can
                  isCleared: false,
                  type: TileType.rock,
                )
              else
                state.grid.tiles[r][c]
          ]
      ];

      notifier.state = state.copyWith(
        grid: state.grid.copyWith(
          playerPosition: playerPos,
          playerFacing: PlayerDirection.down,
          tiles: updatedTiles,
        ),
        player: state.player.copyWith(hp: 50, maxHp: 100),
      );

      notifier.digTargetTile();

      final afterState = container.read(gameNotifierProvider);
      expect(afterState.player.hp, 60); // 50 + 10 = 60
    });

    test('Hedeflenen hücrede rakip oyuncu varsa vurulabilmeli ve rakip canı düşmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final state = container.read(gameNotifierProvider);
      const playerPos = Position(1, 1);
      const targetPos = Position(2, 1);

      // Aşağı hücreye bir rakip oyuncu koyalım
      final enemy = RemotePlayerModel(
        uid: 'enemy_1',
        displayName: 'Rakip Madenci',
        colorIndex: 1,
        position: targetPos,
        hp: 100,
        maxHp: 100,
      );

      notifier.state = state.copyWith(
        grid: state.grid.copyWith(
          playerPosition: playerPos,
          playerFacing: PlayerDirection.down,
          otherPlayers: [enemy],
        ),
        player: state.player.copyWith(
          energy: 50,
          inventoryTools: [ToolType.pickaxe],
          activeToolIndex: 0,
        ),
      );

      // Rakibe vur
      notifier.digTargetTile();

      final afterState = container.read(gameNotifierProvider);
      final updatedEnemy = afterState.grid.otherPlayers.first;

      // Kazmanın pvp hasarı = 18
      expect(updatedEnemy.hp, 100 - 18);
      expect(afterState.lastMessage?.contains('Hasar vurdunuz'), true);
    });
  });
}

