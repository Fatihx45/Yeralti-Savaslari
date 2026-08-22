import 'tile_model.dart';
import 'package:derin_kazi/features/multiplayer/domain/models/remote_player_model.dart';

enum PlayerDirection { up, down, left, right }

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && runtimeType == other.runtimeType && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  Position copyWith({int? row, int? col}) => Position(row ?? this.row, col ?? this.col);
}

class GridModel {
  final int stage;
  final int depth;
  final String biomeName;
  final int rows;
  final int columns;
  final List<List<TileModel>> tiles;
  final Position playerPosition;
  final PlayerDirection playerFacing;
  final int tilesClearedInStage;
  final int totalTilesInStage;
  final int? gridSeed;
  final List<RemotePlayerModel> otherPlayers;

  const GridModel({
    required this.stage,
    required this.depth,
    required this.biomeName,
    required this.rows,
    required this.columns,
    required this.tiles,
    required this.playerPosition,
    this.playerFacing = PlayerDirection.down,
    required this.tilesClearedInStage,
    required this.totalTilesInStage,
    this.gridSeed,
    this.otherPlayers = const [],
  });

  Position get targetCellPosition {
    int dRow = 0;
    int dCol = 0;
    switch (playerFacing) {
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
    return Position(
      (playerPosition.row + dRow).clamp(0, rows - 1),
      (playerPosition.col + dCol).clamp(0, columns - 1),
    );
  }

  GridModel copyWith({
    int? stage,
    int? depth,
    String? biomeName,
    int? rows,
    int? columns,
    List<List<TileModel>>? tiles,
    Position? playerPosition,
    PlayerDirection? playerFacing,
    int? tilesClearedInStage,
    int? totalTilesInStage,
    int? gridSeed,
    List<RemotePlayerModel>? otherPlayers,
  }) {
    return GridModel(
      stage: stage ?? this.stage,
      depth: depth ?? this.depth,
      biomeName: biomeName ?? this.biomeName,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      tiles: tiles ?? this.tiles,
      playerPosition: playerPosition ?? this.playerPosition,
      playerFacing: playerFacing ?? this.playerFacing,
      tilesClearedInStage: tilesClearedInStage ?? this.tilesClearedInStage,
      totalTilesInStage: totalTilesInStage ?? this.totalTilesInStage,
      gridSeed: gridSeed ?? this.gridSeed,
      otherPlayers: otherPlayers ?? this.otherPlayers,
    );
  }
}

