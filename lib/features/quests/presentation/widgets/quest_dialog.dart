import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/presentation/screens/mining_screen.dart';
import '../../domain/models/daily_quest_model.dart';
import '../../../multiplayer/presentation/screens/lobby_screen.dart';
import '../../../multiplayer/application/lobby_notifier.dart';

class QuestDialog extends ConsumerStatefulWidget {
  const QuestDialog({super.key});

  static void showQuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const QuestDialog(),
    );
  }

  @override
  ConsumerState<QuestDialog> createState() => _QuestDialogState();
}

class _QuestDialogState extends ConsumerState<QuestDialog> {
  QuestDifficulty? _selectedDifficulty; // null = Tümü

  String _formatRemainingTime(int lastResetTimestamp) {
    if (lastResetTimestamp <= 0) return '7 gün';
    const int sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
    final int nextReset = lastResetTimestamp + sevenDaysMs;
    final int diffMs = nextReset - DateTime.now().millisecondsSinceEpoch;

    if (diffMs <= 0) return 'Yenileniyor...';

    final duration = Duration(milliseconds: diffMs);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days gün $hours saat';
    } else {
      return '$hours saat $minutes dakika';
    }
  }

  Color _getDifficultyColor(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return const Color(0xFF00E676);
      case QuestDifficulty.medium:
        return const Color(0xFFFFD54F);
      case QuestDifficulty.hard:
        return const Color(0xFFFF5252);
      case QuestDifficulty.legendary:
        return const Color(0xFFE040FB);
    }
  }

  String _getDifficultyLabel(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'KOLAY';
      case QuestDifficulty.medium:
        return 'ORTA';
      case QuestDifficulty.hard:
        return 'ZOR';
      case QuestDifficulty.legendary:
        return 'EFSANEVİ';
    }
  }

  void _handleDoQuest(BuildContext context, DailyQuestModel quest) {
    Navigator.pop(context); // Diyalogu kapat

    if (quest.actionType == QuestActionType.pvp) {
      // Multiplayer / Battle Royale Odası Kur & Yönlendir
      ref.read(lobbyNotifierProvider.notifier).createRoom(maxPlayers: 4);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => const LobbyScreen()),
      );
    } else {
      // Solo Madencilik Başlat & Yönlendir
      ref.read(gameNotifierProvider.notifier).startSoloGame();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => const MiningScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final allQuests = gameState.quests;
    final filteredQuests = _selectedDifficulty == null
        ? allQuests
        : allQuests.where((q) => q.difficulty == _selectedDifficulty).toList();

    final completedCount = allQuests.where((q) => q.isCompleted).length;
    final totalCount = allQuests.length;
    final String remainingTimeStr = _formatRemainingTime(gameState.lastQuestResetTimestamp);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D26),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldText.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Üst Başlık & Kalan Süre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment, color: AppColors.goldText, size: 24),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HAFTALIK GÖREVLER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Color(0xFF4FC3F7), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Yenilenmeye Kalan: $remainingTimeStr',
                              style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. Toplam Tamamlanma Durumu Rozeti
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF141438),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF26265A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tamamlanan: $completedCount / $totalCount Görev',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text('💎 ', style: TextStyle(fontSize: 12)),
                      Text(
                        '${gameState.player.gems} Elmas',
                        style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. Zorluk Filtreleme Sekmeleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('TÜMÜ (${allQuests.length})', null),
                  _buildFilterChip('🟢 KOLAY', QuestDifficulty.easy),
                  _buildFilterChip('🟡 ORTA', QuestDifficulty.medium),
                  _buildFilterChip('🔴 ZOR', QuestDifficulty.hard),
                  _buildFilterChip('🟣 EFSANEVİ', QuestDifficulty.legendary),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Görev Listesi
            Expanded(
              child: ListView.builder(
                itemCount: filteredQuests.length,
                itemBuilder: (context, index) {
                  final quest = filteredQuests[index];
                  final diffColor = _getDifficultyColor(quest.difficulty);
                  final diffLabel = _getDifficultyLabel(quest.difficulty);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151538),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: quest.isCompleted
                            ? (quest.isClaimed ? Colors.white24 : AppColors.neonGreen)
                            : diffColor.withValues(alpha: 0.5),
                        width: quest.isCompleted && !quest.isClaimed ? 1.8 : 1.2,
                      ),
                      boxShadow: quest.isCompleted && !quest.isClaimed
                          ? [
                              BoxShadow(
                                color: AppColors.neonGreen.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Üst Satır: İkon, Başlık, Zorluk ve GÖREVİ YAP Butonu
                        Row(
                          children: [
                            // İkon
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0D26),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: diffColor.withValues(alpha: 0.6)),
                              ),
                              child: Center(
                                child: Text(quest.iconEmoji, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Başlık & Açıklama
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        quest.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: diffColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: diffColor, width: 0.8),
                                        ),
                                        child: Text(
                                          diffLabel,
                                          style: TextStyle(
                                            color: diffColor,
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    quest.description,
                                    style: const TextStyle(color: Color(0xFF9E9EBE), fontSize: 10),
                                  ),
                                ],
                              ),
                            ),

                            // Sağ Taraf: GÖREVİ YAP Butonu (Tamamlanmadıysa)
                            if (!quest.isCompleted)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A5F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _handleDoQuest(context, quest),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('GÖREVİ YAP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 2),
                                    Icon(Icons.arrow_forward_ios, size: 9),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Orta Satır: İlerleme Çubuğu & Ödül Değerleri
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: quest.progress,
                                  minHeight: 7,
                                  backgroundColor: const Color(0xFF0A0A1C),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    quest.isCompleted ? AppColors.neonGreen : const Color(0xFF29B6F6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${quest.current}/${quest.target}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Ödül Rozeti
                            Row(
                              children: [
                                Text('+${quest.rewardGems} 💎', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('+${quest.rewardGold} 🟡', style: const TextStyle(color: AppColors.goldText, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),

                        // Alt Satır: ÖDÜLÜ AL Butonu (Tamamlandıysa Parlayan Yeşil Buton)
                        if (quest.isCompleted) ...[
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: quest.isClaimed ? const Color(0xFF222244) : AppColors.neonGreen,
                              foregroundColor: quest.isClaimed ? Colors.white38 : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: quest.isClaimed ? 0 : 4,
                            ),
                            onPressed: quest.isClaimed
                                ? null
                                : () {
                                    ref.read(gameNotifierProvider.notifier).claimQuestReward(quest.id);
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  quest.isClaimed ? Icons.check_circle : Icons.card_giftcard,
                                  size: 14,
                                  color: quest.isClaimed ? Colors.white38 : Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  quest.isClaimed
                                      ? 'ÖDÜL ALINDI'
                                      : '🎁 ÖDÜLÜ AL (+${quest.rewardGems} 💎 +${quest.rewardGold} 🟡)',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, QuestDifficulty? difficulty) {
    final bool isSelected = _selectedDifficulty == difficulty;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.goldText,
        backgroundColor: const Color(0xFF16163A),
        side: BorderSide(color: isSelected ? AppColors.goldText : const Color(0xFF2E2E68)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        onSelected: (_) {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
      ),
    );
  }
}
