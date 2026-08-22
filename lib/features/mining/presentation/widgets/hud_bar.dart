import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_state_model.dart';
import '../../domain/models/grid_model.dart';
import '../../application/game_notifier.dart';

class HudBar extends ConsumerWidget {
  const HudBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;
    final grid = gameState.grid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.hudPanel,
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F1F55), width: 1.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;

          if (isNarrow) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLeftSection(context, ref, player),
                    _buildRightSection(context, ref, player),
                  ],
                ),
                const SizedBox(height: 4),
                _buildCenterSection(grid, player, gameState),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLeftSection(context, ref, player),
              _buildCenterSection(grid, player, gameState),
              _buildRightSection(context, ref, player),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftSection(BuildContext context, WidgetRef ref, PlayerStateModel player) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Altın ve Elmas Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F30),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF2A2A6A), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.goldText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${player.gold}',
                    style: const TextStyle(
                      color: AppColors.goldText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond, color: AppColors.cyanText, size: 11),
                  const SizedBox(width: 4),
                  Text(
                    '${player.gems}',
                    style: const TextStyle(
                      color: AppColors.cyanText,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Biyom ve Derinlik Rozeti
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.badgeRed,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Kırmızı Toprak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hardware, color: Color(0xFF9E9E9E), size: 10),
                const SizedBox(width: 2),
                Text(
                  '${player.highestDepth} derinlik',
                  style: const TextStyle(
                    color: Color(0xFFB0B0D0),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 8),

        // Ses Butonu
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          icon: Icon(
            player.soundEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.white70,
            size: 16,
          ),
          onPressed: () {
            ref.read(gameNotifierProvider.notifier).toggleSound();
          },
        ),
        const SizedBox(width: 4),

        // 2x Bonus Butonu
        InkWell(
          onTap: () {
            ref.read(gameNotifierProvider.notifier).activateDoubleBonus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: player.doubleBonusActive
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFF0F3818),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: player.doubleBonusActive
                    ? AppColors.neonGreen
                    : const Color(0xFF2E7D32),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.doubleBonusActive ? '2x AKTİF' : 'x2 Bonus',
                  style: TextStyle(
                    color: player.doubleBonusActive
                        ? AppColors.neonGreen
                        : const Color(0xFF81C784),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!player.doubleBonusActive)
                  const Text(
                    '500',
                    style: TextStyle(
                      color: AppColors.goldText,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterSection(GridModel grid, PlayerStateModel player, GameState state) {
    if (state.gameMode == GameMode.solo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.terrain, color: AppColors.neonGreen, size: 14),
            const SizedBox(width: 5),
            Text(
              'AŞAMA ${grid.stage} • ${grid.biomeName} (${grid.tilesClearedInStage}/${grid.totalTilesInStage})',
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    final phase = state.battlePhase;
    final String phaseTitle = phase.isDeathmatch
        ? '⚔️ SERBEST DÖVÜŞ'
        : (phase.isCountdown ? '⏳ BAŞLIYOR' : '📦 HAZİNE AVI');
    final Color phaseColor = phase.isDeathmatch ? const Color(0xFFFF5252) : AppColors.goldText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F28),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: phaseColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: phaseColor, size: 14),
          const SizedBox(width: 4),
          Text(
            '$phaseTitle (${phase.formattedTime})',
            style: TextStyle(
              color: phaseColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection(BuildContext context, WidgetRef ref, PlayerStateModel player) {
    final String earningsDisplay = player.lifetimeEarnings >= 1000
        ? '${(player.lifetimeEarnings / 1000).toStringAsFixed(2)}K'
        : '${player.lifetimeEarnings}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rütbe ${player.rank}',
              style: const TextStyle(
                color: AppColors.goldText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              'Toplam $earningsDisplay',
              style: const TextStyle(
                color: Color(0xFFB0B0D0),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.resetRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            _showResetDialog(context, ref, player);
          },
          child: const Text(
            'SIFIRLA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, PlayerStateModel player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.hudPanel,
        title: const Text('Rütbe Sıfırlama (Prestij)'),
        content: Text(
          'Mevcut derinlik ve altınınız sıfırlanacak.\n'
          'Rütbeniz ${player.rank + 1} olacak ve kalıcı kazı bonusu kazanacaksınız.\n\n'
          'Devam etmek istiyor musunuz?',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.resetRed),
            onPressed: () {
              ref.read(gameNotifierProvider.notifier).prestigeReset();
              Navigator.pop(ctx);
            },
            child: const Text('SIFIRLA'),
          ),
        ],
      ),
    );
  }
}

