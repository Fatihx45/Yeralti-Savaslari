import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_contribution_model.dart';

class VictoryPodiumDialog extends StatelessWidget {
  final List<PlayerContributionModel> contributions;
  final int teamTotalGold;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const VictoryPodiumDialog({
    super.key,
    required this.contributions,
    required this.teamTotalGold,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  static void showVictoryPodium(
    BuildContext context, {
    required List<PlayerContributionModel> contributions,
    required int teamTotalGold,
    required VoidCallback onPlayAgain,
    required VoidCallback onMainMenu,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VictoryPodiumDialog(
        contributions: contributions,
        teamTotalGold: teamTotalGold,
        onPlayAgain: onPlayAgain,
        onMainMenu: onMainMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1., 2. ve 3. oyuncuları ayıkla
    final PlayerContributionModel? first = contributions.isNotEmpty ? contributions[0] : null;
    final PlayerContributionModel? second = contributions.length > 1 ? contributions[1] : null;
    final PlayerContributionModel? third = contributions.length > 2 ? contributions[2] : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              blurRadius: 25,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zafer Başlığı
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B6B00), Color(0xFFD4AF37), Color(0xFF8B6B00)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 26),
                    SizedBox(width: 8),
                    Text(
                      '🏆 EKİP ZAFERİ: SEFER TAMAMLANDI!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1))],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 1. PODYUM BÖLÜMÜ (3 Basamak)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141438),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2E2E68)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 2. Sıra (Gümüş)
                          if (second != null)
                            _buildPodiumStep(
                              player: second,
                              rank: 2,
                              podiumHeight: 80,
                              podiumColor: const Color(0xFFB0BEC5),
                              medalIcon: Icons.military_tech,
                              medalColor: const Color(0xFFCFD8DC),
                            )
                          else
                            const SizedBox(width: 80),

                          // 1. Sıra (Altın & MVP Tacı)
                          if (first != null)
                            _buildPodiumStep(
                              player: first,
                              rank: 1,
                              podiumHeight: 115,
                              podiumColor: const Color(0xFFFFD700),
                              medalIcon: Icons.emoji_events,
                              medalColor: const Color(0xFFFFD700),
                              isMvp: true,
                            ),

                          // 3. Sıra (Bronz)
                          if (third != null)
                            _buildPodiumStep(
                              player: third,
                              rank: 3,
                              podiumHeight: 60,
                              podiumColor: const Color(0xFFCD7F32),
                              medalIcon: Icons.military_tech,
                              medalColor: const Color(0xFFD7CCC8),
                            )
                          else
                            const SizedBox(width: 80),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. TÜM MADENCİLER LİSTESİ VE ÖDÜLLERİ
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Katkı Sıralaması ve Ganimet Dağılımı:',
                        style: TextStyle(
                          color: Color(0xFFB0B0D0),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    for (int i = 0; i < contributions.length; i++)
                      _buildPlayerRow(contributions[i], i + 1),
                  ],
                ),
              ),
            ),

            // Alt Butonlar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF121232),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border(top: BorderSide(color: Color(0xFF2E2E68), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF4A4A8A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onMainMenu,
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('ANA MENÜ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onPlayAgain,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('YENİ SEFER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumStep({
    required PlayerContributionModel player,
    required int rank,
    required double podiumHeight,
    required Color podiumColor,
    required IconData medalIcon,
    required Color medalColor,
    bool isMvp = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMvp) ...[
          const Text('👑 MVP', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
        ],
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E48),
            shape: BoxShape.circle,
            border: Border.all(color: medalColor, width: 2),
          ),
          child: Center(
            child: Icon(medalIcon, color: medalColor, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          player.displayName,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '+${player.totalGold} 🟡',
          style: const TextStyle(color: AppColors.goldText, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            border: Border.all(color: podiumColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(color: podiumColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(PlayerContributionModel player, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: player.isMvp ? const Color(0xFF2A2210) : const Color(0xFF16163A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: player.isMvp ? const Color(0xFFFFD700) : const Color(0xFF2A2A5E),
          width: player.isMvp ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: TextStyle(
              color: player.isMvp ? const Color(0xFFFFD700) : const Color(0xFF8E8EAE),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    if (player.isMvp) ...[
                      const SizedBox(width: 4),
                      const Text('👑', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                Text(
                  'Hasar: ${player.damageDealt} • Kazı: ${player.tilesCleared}',
                  style: const TextStyle(color: Color(0xFF8E8EAE), fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${player.totalGold} 🟡',
                style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              if (player.gemsEarned > 0)
                Text(
                  '+${player.gemsEarned} 💎',
                  style: const TextStyle(color: AppColors.cyanText, fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

