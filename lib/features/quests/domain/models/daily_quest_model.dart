class DailyQuestModel {
  final String id;
  final String title;
  final String iconEmoji;
  final int target;
  final int current;
  final int rewardGold;
  final int rewardGems;
  final bool isClaimed;

  const DailyQuestModel({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.target,
    this.current = 0,
    this.rewardGold = 100,
    this.rewardGems = 2,
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
      iconEmoji: iconEmoji,
      target: target,
      current: current ?? this.current,
      rewardGold: rewardGold,
      rewardGems: rewardGems,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
