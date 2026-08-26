enum FriendStatus {
  online,
  inMining,
  inBattleRoyale,
  offline,
}

extension FriendStatusExtension on FriendStatus {
  String get displayName {
    switch (this) {
      case FriendStatus.online:
        return '🟢 Çevrimiçi / Lobide';
      case FriendStatus.inMining:
        return '⛏️ Kazıda';
      case FriendStatus.inBattleRoyale:
        return '⚔️ Battle Royale\'de';
      case FriendStatus.offline:
        return '⚪ Çevrimdışı';
    }
  }
}

class FriendModel {
  final String uid;
  final String name;
  final String playerTag;
  final int stage;
  final int trophies;
  final String equippedSkinId;
  final FriendStatus status;
  final bool hasGiftAvailable;
  final bool giftSentToday;
  final int enemiesKilled;

  const FriendModel({
    required this.uid,
    required this.name,
    required this.playerTag,
    this.stage = 1,
    this.trophies = 100,
    this.equippedSkinId = 'skin_miner_default',
    this.status = FriendStatus.online,
    this.hasGiftAvailable = false,
    this.giftSentToday = false,
    this.enemiesKilled = 0,
  });

  FriendModel copyWith({
    String? uid,
    String? name,
    String? playerTag,
    int? stage,
    int? trophies,
    String? equippedSkinId,
    FriendStatus? status,
    bool? hasGiftAvailable,
    bool? giftSentToday,
    int? enemiesKilled,
  }) {
    return FriendModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      playerTag: playerTag ?? this.playerTag,
      stage: stage ?? this.stage,
      trophies: trophies ?? this.trophies,
      equippedSkinId: equippedSkinId ?? this.equippedSkinId,
      status: status ?? this.status,
      hasGiftAvailable: hasGiftAvailable ?? this.hasGiftAvailable,
      giftSentToday: giftSentToday ?? this.giftSentToday,
      enemiesKilled: enemiesKilled ?? this.enemiesKilled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'playerTag': playerTag,
      'stage': stage,
      'trophies': trophies,
      'equippedSkinId': equippedSkinId,
      'status': status.name,
      'hasGiftAvailable': hasGiftAvailable,
      'giftSentToday': giftSentToday,
      'enemiesKilled': enemiesKilled,
    };
  }

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      uid: json['uid'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Madenci',
      playerTag: json['playerTag'] as String? ?? '#0001',
      stage: json['stage'] as int? ?? 1,
      trophies: json['trophies'] as int? ?? 100,
      equippedSkinId: json['equippedSkinId'] as String? ?? 'skin_miner_default',
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.offline,
      ),
      hasGiftAvailable: json['hasGiftAvailable'] as bool? ?? false,
      giftSentToday: json['giftSentToday'] as bool? ?? false,
      enemiesKilled: json['enemiesKilled'] as int? ?? 0,
    );
  }
}
