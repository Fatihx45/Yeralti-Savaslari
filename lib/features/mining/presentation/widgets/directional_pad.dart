import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/grid_model.dart';
import '../../application/game_notifier.dart';

class DirectionalPad extends ConsumerWidget {
  const DirectionalPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 136,
      height: 136,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Merkez kazı/parlama butonu
          InkWell(
            onTap: () => ref.read(gameNotifierProvider.notifier).digTargetTile(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0F2B18),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.hardware, color: AppColors.neonGreen, size: 20),
              ),
            ),
          ),

          // Yukarı Butonu
          Positioned(
            top: 2,
            child: _buildArrowButton(
              onTap: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.up),
              icon: Icons.keyboard_arrow_up,
            ),
          ),

          // Aşağı Butonu
          Positioned(
            bottom: 2,
            child: _buildArrowButton(
              onTap: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.down),
              icon: Icons.keyboard_arrow_down,
            ),
          ),

          // Sol Butonu
          Positioned(
            left: 2,
            child: _buildArrowButton(
              onTap: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.left),
              icon: Icons.keyboard_arrow_left,
            ),
          ),

          // Sağ Butonu
          Positioned(
            right: 2,
            child: _buildArrowButton(
              onTap: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.right),
              icon: Icons.keyboard_arrow_right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF164424),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.neonGreen,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.neonGreen,
            size: 26,
          ),
        ),
      ),
    );
  }
}

