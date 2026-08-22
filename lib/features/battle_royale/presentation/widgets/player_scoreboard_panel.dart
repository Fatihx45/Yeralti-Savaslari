import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';

class PlayerScoreboardPanel extends ConsumerWidget {
  const PlayerScoreboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final myPlayer = gameState.player;
    final otherPlayers = gameState.grid.otherPlayers;

    const List<Color> playerColors = [
      Color(0xFF00E5FF),
      Color(0xFFFF4081),
      Color(0xFF76FF03),
      Color(0xFFFF9100),
      Color(0xFFE040FB),
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D26).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E2E68), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.military_tech, color: AppColors.goldText, size: 12),
              SizedBox(width: 4),
              Text(
                'MADENCİLER',
                style: TextStyle(
                  color: AppColors.goldText,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 1. Kendi Karakterimiz
          _buildPlayerRow(
            name: 'Sen (Madenci)',
            hp: myPlayer.hp,
            maxHp: myPlayer.maxHp,
            color: const Color(0xFF00E5FF),
            isMe: true,
          ),

          // 2. Diğer Oyuncular
          for (int i = 0; i < otherPlayers.length; i++) ...[
            const SizedBox(height: 3),
            _buildPlayerRow(
              name: otherPlayers[i].displayName,
              hp: otherPlayers[i].hp,
              maxHp: otherPlayers[i].maxHp,
              color: playerColors[(otherPlayers[i].colorIndex) % playerColors.length],
              isMe: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required String name,
    required int hp,
    required int maxHp,
    required Color color,
    required bool isMe,
  }) {
    final bool isAlive = hp > 0;
    final double ratio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isAlive ? color : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isAlive ? Colors.white : Colors.white38,
                        fontSize: 8,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        decoration: isAlive ? null : TextDecoration.lineThrough,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isAlive ? '$hp' : '💀',
              style: TextStyle(
                color: isAlive ? const Color(0xFFFF5252) : Colors.grey,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E38),
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAlive ? (isMe ? AppColors.neonGreen : color) : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

