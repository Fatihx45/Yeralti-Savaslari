import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/domain/models/tile_model.dart';

class BossHealthBar extends ConsumerWidget {
  const BossHealthBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final grid = gameState.grid;

    // Haritada kırılmamış bossCore var mı?
    TileModel? bossTile;
    for (final row in grid.tiles) {
      for (final tile in row) {
        if (tile.type == TileType.bossCore && !tile.isCleared) {
          bossTile = tile;
          break;
        }
      }
      if (bossTile != null) break;
    }

    if (bossTile == null) return const SizedBox.shrink();

    final double hpRatio = (bossTile.currentHp / bossTile.maxHp).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0505).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF1744), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF1744).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('👑', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'TİTAN BOSS ÇEKİRDEĞİ',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                '${bossTile.currentHp} / ${bossTile.maxHp} HP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hpRatio,
              minHeight: 8,
              backgroundColor: const Color(0xFF380808),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF1744)),
            ),
          ),
        ],
      ),
    );
  }
}
