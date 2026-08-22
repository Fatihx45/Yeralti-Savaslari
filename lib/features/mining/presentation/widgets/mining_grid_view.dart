import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game_notifier.dart';
import '../painters/tile_grid_painter.dart';

class MiningGridView extends ConsumerWidget {
  const MiningGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final grid = gameState.grid;

    return AspectRatio(
      aspectRatio: grid.columns / grid.rows,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF381010),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: GestureDetector(
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPos = details.localPosition;
              final double cellWidth = box.size.width / grid.columns;
              final double cellHeight = box.size.height / grid.rows;

              final int clickedCol = (localPos.dx / cellWidth).floor().clamp(0, grid.columns - 1);
              final int clickedRow = (localPos.dy / cellHeight).floor().clamp(0, grid.rows - 1);

              ref.read(gameNotifierProvider.notifier).tapTile(clickedRow, clickedCol);
            },
            child: CustomPaint(
              painter: TileGridPainter(
                grid: grid,
                lastDamagedTile: gameState.lastDamagedTile,
                equippedSkinId: gameState.player.equippedSkinId,
                activeReactionEmoji: gameState.activeReactionEmoji,
              ),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}

