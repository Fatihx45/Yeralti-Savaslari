import 'package:flutter_application_1/features/mining/domain/models/grid_model.dart';
import 'package:flutter_application_1/features/mining/domain/models/tool_model.dart';

class RemotePlayerModel {
  final String uid;
  final String displayName;
  final int colorIndex;
  final Position position;
  final int hp;
  final int maxHp;
  final ToolType? activeTool;
  final bool isReady;
  final bool isHost;
  final int damageDealt;
  final int tilesCleared;
  final int goldEarned;
  final int dynamitesUsed;
  final int energyGiven;

  const RemotePlayerModel({
    required this.uid,
    required this.displayName,
    required this.colorIndex,
    required this.position,
    this.hp = 100,
    this.maxHp = 100,
    this.activeTool,
    this.isReady = false,
    this.isHost = false,
    this.damageDealt = 0,
    this.tilesCleared = 0,
    this.goldEarned = 0,
    this.dynamitesUsed = 0,
    this.energyGiven = 0,
  });

  bool get isAlive => hp > 0;

  RemotePlayerModel copyWith({
    String? uid,
    String? displayName,
    int? colorIndex,
    Position? position,
    int? hp,
    int? maxHp,
    ToolType? activeTool,
    bool? isReady,
    bool? isHost,
    int? damageDealt,
    int? tilesCleared,
    int? goldEarned,
    int? dynamitesUsed,
    int? energyGiven,
  }) {
    return RemotePlayerModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      colorIndex: colorIndex ?? this.colorIndex,
      position: position ?? this.position,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      activeTool: activeTool ?? this.activeTool,
      isReady: isReady ?? this.isReady,
      isHost: isHost ?? this.isHost,
      damageDealt: damageDealt ?? this.damageDealt,
      tilesCleared: tilesCleared ?? this.tilesCleared,
      goldEarned: goldEarned ?? this.goldEarned,
      dynamitesUsed: dynamitesUsed ?? this.dynamitesUsed,
      energyGiven: energyGiven ?? this.energyGiven,
    );
  }
}
