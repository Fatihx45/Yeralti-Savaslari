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
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // D-Pad Arka Plan Halkası
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x6608081A),
              border: Border.all(color: const Color(0x334DFF88), width: 1.5),
            ),
          ),

          // Merkez Kazı / Hedefe Vurma Butonu
          InkWell(
            onTap: () => ref.read(gameNotifierProvider.notifier).digTargetTile(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xCC0F2B18),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.hardware, color: AppColors.neonGreen, size: 18),
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xB3164424),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.neonGreen.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.25),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.neonGreen,
            size: 24,
          ),
        ),
      ),
    );
  }
}

