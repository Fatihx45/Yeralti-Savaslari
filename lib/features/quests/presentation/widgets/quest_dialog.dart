import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';

class QuestDialog extends ConsumerWidget {
  const QuestDialog({super.key});

  static void showQuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const QuestDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final quests = gameState.quests;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldText.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment, color: AppColors.goldText, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'GÜNLÜK GÖREVLER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Her gün yenilenen görevleri tamamla, altın ve elmas kazan!',
              style: TextStyle(color: Color(0xFF8E8EAE), fontSize: 11),
            ),
            const SizedBox(height: 16),

            // Görev Listesi
            ...quests.map((quest) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16163A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: quest.isCompleted
                        ? (quest.isClaimed ? Colors.white24 : AppColors.neonGreen)
                        : const Color(0xFF2A2A5E),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(quest.iconEmoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              quest.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        // Ödül Rozeti
                        Row(
                          children: [
                            Text('+${quest.rewardGold} 🟡', style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('+${quest.rewardGems} 💎', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // İlerleme Çubuğu ve Buton
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: quest.progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFF0F0F28),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                quest.isCompleted ? AppColors.neonGreen : const Color(0xFF29B6F6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${quest.current}/${quest.target}',
                          style: const TextStyle(color: Color(0xFF8E8EAE), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: quest.isCompleted && !quest.isClaimed
                                ? AppColors.neonGreen
                                : const Color(0xFF2E2E55),
                            foregroundColor: quest.isCompleted && !quest.isClaimed
                                ? Colors.black
                                : Colors.white54,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: quest.isCompleted && !quest.isClaimed
                              ? () {
                                  ref.read(gameNotifierProvider.notifier).claimQuestReward(quest.id);
                                }
                              : null,
                          child: Text(
                            quest.isClaimed ? 'ALINDI' : (quest.isCompleted ? 'ÖDÜLÜ AL' : 'DEVAM'),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
