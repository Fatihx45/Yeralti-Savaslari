import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/daily_quest_model.dart';
import '../../mining/application/game_notifier.dart';

class QuestState {
  final List<DailyQuestModel> weeklyQuests;
  final int completedQuestsCount;

  const QuestState({
    this.weeklyQuests = const [],
    this.completedQuestsCount = 0,
  });

  QuestState copyWith({
    List<DailyQuestModel>? weeklyQuests,
    int? completedQuestsCount,
  }) {
    return QuestState(
      weeklyQuests: weeklyQuests ?? this.weeklyQuests,
      completedQuestsCount: completedQuestsCount ?? this.completedQuestsCount,
    );
  }
}

class QuestNotifier extends StateNotifier<QuestState> {
  final Ref _ref;

  QuestNotifier(this._ref) : super(const QuestState()) {
    _initFromGameState();
  }

  void _initFromGameState() {
    final quests = _ref.read(gameNotifierProvider).quests;
    final completed = quests.where((q) => q.isCompleted).length;
    state = QuestState(
      weeklyQuests: quests,
      completedQuestsCount: completed,
    );
  }

  void claimReward(String questId) {
    _ref.read(gameNotifierProvider.notifier).claimQuestReward(questId);
    _initFromGameState();
  }
}

final questNotifierProvider = StateNotifierProvider<QuestNotifier, QuestState>((ref) {
  return QuestNotifier(ref);
});
