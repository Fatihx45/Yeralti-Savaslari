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

              final int clickedCol = (localPos.dx / cellWidth).floor();
              final int clickedRow = (localPos.dy / cellHeight).floor();

              final pPos = grid.playerPosition;
              final int dRow = clickedRow - pPos.row;
              final int dCol = clickedCol - pPos.col;

              // Yalnızca 4 yönlü komşu ise hareket/kazı yap
              if ((dRow.abs() == 1 && dCol == 0) || (dRow == 0 && dCol.abs() == 1)) {
                ref.read(gameNotifierProvider.notifier).moveOrDig(dRow, dCol);
              }
            },
            child: CustomPaint(
              painter: TileGridPainter(
                grid: grid,
                lastDamagedTile: gameState.lastDamagedTile,
              ),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}
