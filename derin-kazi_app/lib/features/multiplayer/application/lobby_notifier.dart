import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/room_model.dart';
import '../domain/models/remote_player_model.dart';
import 'package:derin_kazi/features/mining/domain/models/grid_model.dart';

class LobbyState {
  final RoomModel? currentRoom;
  final String myUid;
  final String myName;
  final int myColorIndex;
  final bool isInMultiplayer;
  final String? errorMessage;

  const LobbyState({
    this.currentRoom,
    this.myUid = 'local_host',
    this.myName = 'Madenci',
    this.myColorIndex = 0,
    this.isInMultiplayer = false,
    this.errorMessage,
  });

  LobbyState copyWith({
    RoomModel? currentRoom,
    String? myUid,
    String? myName,
    int? myColorIndex,
    bool? isInMultiplayer,
    String? errorMessage,
  }) {
    return LobbyState(
      currentRoom: currentRoom ?? this.currentRoom,
      myUid: myUid ?? this.myUid,
      myName: myName ?? this.myName,
      myColorIndex: myColorIndex ?? this.myColorIndex,
      isInMultiplayer: isInMultiplayer ?? this.isInMultiplayer,
      errorMessage: errorMessage,
    );
  }
}

class LobbyNotifier extends StateNotifier<LobbyState> {
  LobbyNotifier() : super(const LobbyState());

  void setPlayerName(String name) {
    state = state.copyWith(myName: name.trim().isEmpty ? 'Madenci' : name.trim());
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return List.generate(6, (index) => chars[rnd.nextInt(chars.length)]).join();
  }

  void createRoom({int maxPlayers = 4}) {
    final roomId = _generateRoomCode();
    final gridSeed = Random().nextInt(999999);
    final myPlayer = RemotePlayerModel(
      uid: state.myUid,
      displayName: state.myName,
      colorIndex: 0,
      position: const Position(6, 11),
      isReady: true,
      isHost: true,
    );

    // Simüle edilen diğer takım arkadaşları (Seçilen oda kapasitesine göre tam sayıda)
    final List<RemotePlayerModel> mockTeammates = [];
    final int initialTeammatesCount = maxPlayers - 1;
    final teammateNames = [
      'KayaKıran',
      'AltınAvcısı',
      'ElmasKralı',
      'DemirYumruk',
      'TitanUsta',
      'KazmaUstası',
      'LavKorsanı',
      'DerinGezgin',
      'Yıldırım',
    ];

    for (int i = 0; i < initialTeammatesCount; i++) {
      mockTeammates.add(RemotePlayerModel(
        uid: 'teammate_${i + 1}',
        displayName: teammateNames[i % teammateNames.length],
        colorIndex: (i + 1) % 10,
        position: const Position(2, 2), // initMultiplayerTeam içinde köşelere yerleştirilecek
        isReady: true,
        isHost: false,
      ));
    }

    final room = RoomModel(
      roomId: roomId,
      hostUid: state.myUid,
      maxPlayers: maxPlayers.clamp(1, 10),
      status: RoomStatus.lobby,
      gridSeed: gridSeed,
      stage: 1,
      depth: 1,
      targetDepth: 5,
      players: [myPlayer, ...mockTeammates],
    );

    state = state.copyWith(
      currentRoom: room,
      isInMultiplayer: true,
      errorMessage: null,
    );
  }

  bool joinRoom(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length != 6) {
      state = state.copyWith(errorMessage: 'Oda kodu 6 haneli olmalıdır!');
      return false;
    }

    final gridSeed = Random().nextInt(999999);
    final myPlayer = RemotePlayerModel(
      uid: state.myUid,
      displayName: state.myName,
      colorIndex: 1,
      position: const Position(6, 11),
      isReady: true,
      isHost: false,
    );

    final hostPlayer = const RemotePlayerModel(
      uid: 'host_captain',
      displayName: 'KaptanMadenci',
      colorIndex: 0,
      position: Position(5, 11),
      isReady: true,
      isHost: true,
    );

    final room = RoomModel(
      roomId: cleanCode,
      hostUid: 'host_captain',
      maxPlayers: 6,
      status: RoomStatus.lobby,
      gridSeed: gridSeed,
      stage: 1,
      depth: 1,
      targetDepth: 5,
      players: [hostPlayer, myPlayer],
    );

    state = state.copyWith(
      currentRoom: room,
      isInMultiplayer: true,
      errorMessage: null,
    );
    return true;
  }

  void toggleReady() {
    if (state.currentRoom == null) return;
    final updatedPlayers = state.currentRoom!.players.map((p) {
      if (p.uid == state.myUid) {
        return p.copyWith(isReady: !p.isReady);
      }
      return p;
    }).toList();

    state = state.copyWith(
      currentRoom: state.currentRoom!.copyWith(players: updatedPlayers),
    );
  }

  void startMission() {
    if (state.currentRoom == null) return;
    state = state.copyWith(
      currentRoom: state.currentRoom!.copyWith(status: RoomStatus.active),
    );
  }

  void leaveRoom() {
    state = state.copyWith(
      currentRoom: null,
      isInMultiplayer: false,
    );
  }
}

final lobbyNotifierProvider = StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  return LobbyNotifier();
});

