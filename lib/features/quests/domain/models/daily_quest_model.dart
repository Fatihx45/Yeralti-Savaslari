enum QuestDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

enum QuestActionType {
  dig,
  gold,
  potion,
  tool,
  combo,
  emerald,
  tnt,
  chest,
  pvp,
  boss,
  depth,
  prestige,
}

class DailyQuestModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int target;
  final int current;
  final int rewardGold;
  final int rewardGems;
  final QuestDifficulty difficulty;
  final QuestActionType actionType;
  final bool isClaimed;

  const DailyQuestModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.iconEmoji,
    required this.target,
    this.current = 0,
    required this.rewardGold,
    required this.rewardGems,
    this.difficulty = QuestDifficulty.easy,
    this.actionType = QuestActionType.dig,
    this.isClaimed = false,
  });

  bool get isCompleted => current >= target;
  double get progress => (current / target).clamp(0.0, 1.0);

  DailyQuestModel copyWith({
    int? current,
    bool? isClaimed,
  }) {
    return DailyQuestModel(
      id: id,
      title: title,
      description: description,
      iconEmoji: iconEmoji,
      target: target,
      current: current ?? this.current,
      rewardGold: rewardGold,
      rewardGems: rewardGems,
      difficulty: difficulty,
      actionType: actionType,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconEmoji': iconEmoji,
      'target': target,
      'current': current,
      'rewardGold': rewardGold,
      'rewardGems': rewardGems,
      'difficulty': difficulty.name,
      'actionType': actionType.name,
      'isClaimed': isClaimed,
    };
  }

  factory DailyQuestModel.fromJson(Map<String, dynamic> json) {
    QuestDifficulty diff = QuestDifficulty.easy;
    try {
      diff = QuestDifficulty.values.firstWhere((d) => d.name == json['difficulty']);
    } catch (_) {}

    QuestActionType act = QuestActionType.dig;
    try {
      act = QuestActionType.values.firstWhere((a) => a.name == json['actionType']);
    } catch (_) {}

    return DailyQuestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      iconEmoji: json['iconEmoji'] as String? ?? '⛏️',
      target: json['target'] as int? ?? 10,
      current: json['current'] as int? ?? 0,
      rewardGold: json['rewardGold'] as int? ?? 100,
      rewardGems: json['rewardGems'] as int? ?? 2,
      difficulty: diff,
      actionType: act,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}
