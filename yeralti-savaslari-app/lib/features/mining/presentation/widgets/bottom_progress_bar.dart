import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/game_notifier.dart';

class BottomProgressBar extends ConsumerWidget {
  const BottomProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final energy = gameState.player.energy;
    final maxEnergy = gameState.player.maxEnergy;
    final double energyRatio = maxEnergy > 0 ? (energy / maxEnergy).clamp(0.0, 1.0) : 0.0;

    final hp = gameState.player.hp;
    final maxHp = gameState.player.maxHp;
    final double hpRatio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 1. CAN (HP) BARI
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFFFF5252), size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Can: $hp / $maxHp',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFFF5252),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F28),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: hpRatio,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 2. ENERJİ BARI
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: AppColors.neonGreen, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Enerji: $energy / $maxEnergy',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '25s / +1 ⚡',
                      style: TextStyle(
                        color: Color(0xFF7FDBFF),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F28),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: energyRatio,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressFill),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

