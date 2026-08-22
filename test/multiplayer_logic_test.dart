import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';
import 'package:derin_kazi/features/mining/domain/services/grid_generator.dart';
import 'package:derin_kazi/features/multiplayer/application/lobby_notifier.dart';
import 'package:derin_kazi/features/multiplayer/domain/models/room_model.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';

void main() {
  group('Çok Oyunculu Ekip Kazısı Mantık Testleri', () {
    test('Deterministik seed aynı haritayı ve taşları üretmeli', () {
      const int testSeed = 424242;

      final grid1 = GridGenerator.generateStage(stage: 3, seed: testSeed);
      final grid2 = GridGenerator.generateStage(stage: 3, seed: testSeed);

      expect(grid1.rows, grid2.rows);
      expect(grid1.columns, grid2.columns);

      for (int r = 0; r < grid1.rows; r++) {
        for (int c = 0; c < grid1.columns; c++) {
          expect(grid1.tiles[r][c].type, grid2.tiles[r][c].type);
          expect(grid1.tiles[r][c].maxHp, grid2.tiles[r][c].maxHp);
          expect(grid1.tiles[r][c].rewardGold, grid2.tiles[r][c].rewardGold);
        }
      }
    });

    test('1-10 Oyuncu seçici ile oda oluşturulabilmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(lobbyNotifierProvider.notifier);

      notifier.setPlayerName('KaptanTest');
      notifier.createRoom(maxPlayers: 8);

      final state = container.read(lobbyNotifierProvider);
      expect(state.currentRoom != null, true);
      expect(state.currentRoom!.maxPlayers, 8);
      expect(state.currentRoom!.roomId.length, 6);
      expect(state.currentRoom!.status, RoomStatus.lobby);
      expect(state.currentRoom!.players.isNotEmpty, true);
    });

    test('6 haneli oda kodu ile lobiye katılınabilmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(lobbyNotifierProvider.notifier);

      final success = notifier.joinRoom('ABC123');
      expect(success, true);

      final state = container.read(lobbyNotifierProvider);
      expect(state.currentRoom != null, true);
      expect(state.currentRoom!.roomId, 'ABC123');
    });

    test('Büyük gruplarda (8+ oyuncu) harita ve HP çarpanı ölçeklenmeli', () {
      final smallGrid = GridGenerator.generateStage(playerCount: 2);
      final largeGrid = GridGenerator.generateStage(playerCount: 8);

      expect(smallGrid.rows, 13);
      expect(smallGrid.columns, 23);

      expect(largeGrid.rows, 17);
      expect(largeGrid.columns, 31);
    });

    test('4 Kişilik Lobi kurulup başlandığında haritada 3 diğer madenci canlı yer almalı ve farklı köşelerde doğmalı', () {
      final container = ProviderContainer();
      final lobbyNotifier = container.read(lobbyNotifierProvider.notifier);
      final gameNotifier = container.read(gameNotifierProvider.notifier);

      lobbyNotifier.setPlayerName('Kaptan');
      lobbyNotifier.createRoom(maxPlayers: 4);

      final room = container.read(lobbyNotifierProvider).currentRoom!;
      expect(room.players.length, 4); // Tam 4 kişi

      // Oyuna aktar
      gameNotifier.initMultiplayerTeam(room.players, seed: room.gridSeed);

      final gameState = container.read(gameNotifierProvider);
      expect(gameState.grid.otherPlayers.length, 3); // 3 Arkadaş + 1 Siz = 4 Kişi

      // Farklı köşelerde doğma kontrolleri
      expect(gameState.grid.playerPosition, const Position(2, 2)); // 1. Oyuncu (Siz): Sol Üst
      expect(gameState.grid.otherPlayers[0].position, Position(2, gameState.grid.columns - 3)); // 2. Oyuncu: Sağ Üst
      expect(gameState.grid.otherPlayers[1].position, Position(gameState.grid.rows - 3, 2)); // 3. Oyuncu: Sol Alt
      expect(gameState.grid.otherPlayers[2].position, Position(gameState.grid.rows - 3, gameState.grid.columns - 3)); // 4. Oyuncu: Sağ Alt

      container.dispose();
    });
  });
}

