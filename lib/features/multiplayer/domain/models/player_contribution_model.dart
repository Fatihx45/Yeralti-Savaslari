class PlayerContributionModel {
  final String uid;
  final String displayName;
  final int colorIndex;
  final int damageDealt;
  final int tilesCleared;
  final int goldEarned;
  final int gemsEarned;
  final int bonusGold;
  final int totalGold;
  final int rankPosition;
  final bool isMvp;
  final List<String> badges;

  const PlayerContributionModel({
    required this.uid,
    required this.displayName,
    required this.colorIndex,
    required this.damageDealt,
    required this.tilesCleared,
    required this.goldEarned,
    this.gemsEarned = 0,
    this.bonusGold = 0,
    required this.totalGold,
    required this.rankPosition,
    this.isMvp = false,
    this.badges = const [],
  });
}

