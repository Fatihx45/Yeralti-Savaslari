import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:derin_kazi/features/ai_team/domain/models/ai_miner_model.dart';

class StageMvpDialog extends StatelessWidget {
  final int stageNumber;
  final String biomeName;
  final int playerGoldEarned;
  final int teamBonusGold;
  final double teamBonusPercentage;
  final List<AiMinerModel> miners;
  final VoidCallback onNextStage;

  const StageMvpDialog({
    super.key,
    required this.stageNumber,
    required this.biomeName,
    required this.playerGoldEarned,
    required this.teamBonusGold,
    required this.teamBonusPercentage,
    required this.miners,
    required this.onNextStage,
  });

  static void show(
    BuildContext context, {
    required int stageNumber,
    required String biomeName,
    required int playerGoldEarned,
    required int teamBonusGold,
    required double teamBonusPercentage,
    required List<AiMinerModel> miners,
    required VoidCallback onNextStage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StageMvpDialog(
        stageNumber: stageNumber,
        biomeName: biomeName,
        playerGoldEarned: playerGoldEarned,
        teamBonusGold: teamBonusGold,
        teamBonusPercentage: teamBonusPercentage,
        miners: miners,
        onNextStage: onNextStage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MVP Belirle
    AiMinerModel? topMiner;
    int maxDamage = 0;
    for (final m in miners) {
      if (m.totalDamageDealt > maxDamage) {
        maxDamage = m.totalDamageDealt;
        topMiner = m;
      }
    }

    final int bonusPercentDisplay = (teamBonusPercentage * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F28),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD600), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD600).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Taç ve Başlık
            const Icon(Icons.military_tech, size: 52, color: Color(0xFFFFD600)),
            const SizedBox(height: 6),
            const Text(
              'AŞAMA TAMAMLANDI!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Bölüm $stageNumber • $biomeName',
              style: const TextStyle(color: Color(0xFF8E8EAE), fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Takım Bonusu Kartı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1A08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldText, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.groups, color: AppColors.goldText, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAKIM TAMAMLAMA BONUSU (+$bonusPercentDisplay%)',
                          style: const TextStyle(
                            color: AppColors.goldText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '+$teamBonusGold Altın Takım Bonusu Eklendi!',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${playerGoldEarned + teamBonusGold} 🟡',
                    style: const TextStyle(
                      color: AppColors.goldText,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Aşamanın Yıldızı (MVP) Rozeti
            if (topMiner != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141438),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE040FB), width: 1),
                ),
                child: Row(
                  children: [
                    Text(topMiner.avatarEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🌟 BU AŞAMANIN YILDIZI (MVP)',
                            style: TextStyle(
                              color: Color(0xFFE040FB),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            topMiner.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${topMiner.totalDamageDealt} Hasar',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Devam Et Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.arrow_forward, size: 20),
                label: const Text(
                  'SONRAKİ BÖLÜME GEÇ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onNextStage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
