import 'remote_player_model.dart';

enum RoomStatus { lobby, active, victory, finished }
enum RoomGameMode { coopCampaign, goldRushRace }

class RoomModel {
  final String roomId;
  final String hostUid;
  final int maxPlayers;
  final RoomStatus status;
  final RoomGameMode mode;
  final int gridSeed;
  final int stage;
  final int depth;
  final int targetDepth;
  final String biomeName;
  final List<RemotePlayerModel> players;
  final bool isVictory;

  const RoomModel({
    required this.roomId,
    required this.hostUid,
    required this.maxPlayers,
    this.status = RoomStatus.lobby,
    this.mode = RoomGameMode.coopCampaign,
    required this.gridSeed,
    this.stage = 1,
    this.depth = 1,
    this.targetDepth = 5,
    this.biomeName = 'Kırmızı Toprak',
    this.players = const [],
    this.isVictory = false,
  });

  RoomModel copyWith({
    String? roomId,
    String? hostUid,
    int? maxPlayers,
    RoomStatus? status,
    RoomGameMode? mode,
    int? gridSeed,
    int? stage,
    int? depth,
    int? targetDepth,
    String? biomeName,
    List<RemotePlayerModel>? players,
    bool? isVictory,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      hostUid: hostUid ?? this.hostUid,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      gridSeed: gridSeed ?? this.gridSeed,
      stage: stage ?? this.stage,
      depth: depth ?? this.depth,
      targetDepth: targetDepth ?? this.targetDepth,
      biomeName: biomeName ?? this.biomeName,
      players: players ?? this.players,
      isVictory: isVictory ?? this.isVictory,
    );
  }
}
