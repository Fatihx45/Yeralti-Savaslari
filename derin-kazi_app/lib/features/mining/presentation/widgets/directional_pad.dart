import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/grid_model.dart';
import '../../application/game_notifier.dart';

class DirectionalPad extends ConsumerStatefulWidget {
  const DirectionalPad({super.key});

  @override
  ConsumerState<DirectionalPad> createState() => _DirectionalPadState();
}

class _DirectionalPadState extends ConsumerState<DirectionalPad> {
  Timer? _initialDelayTimer;
  Timer? _rapidRepeatTimer;

  @override
  void dispose() {
    _stopAction();
    super.dispose();
  }

  void _startAction(VoidCallback action) {
    _stopAction();
    // İlk dokunuşta anında 1 adım at
    action();

    // 140 milisaniye sonra hızlı seri tekrar moduna geç (her 80ms'de bir adım)
    _initialDelayTimer = Timer(const Duration(milliseconds: 140), () {
      _rapidRepeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        action();
      });
    });
  }

  void _stopAction() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _rapidRepeatTimer?.cancel();
    _rapidRepeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    const double dpadSize = 126.0;
    const double btnSize = 42.0;

    return SizedBox(
      width: dpadSize,
      height: dpadSize,
      child: Stack(
        children: [
          // D-Pad Arka Plan Halkası
          Center(
            child: Container(
              width: dpadSize - 6,
              height: dpadSize - 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x6608081A),
                border: Border.all(color: const Color(0x334DFF88), width: 1.5),
              ),
            ),
          ),

          // 1. YUKARI BUTONU
          Positioned(
            top: 0,
            left: (dpadSize - btnSize) / 2,
            width: btnSize,
            height: btnSize,
            child: _buildArrowButton(
              onAction: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.up),
              icon: Icons.keyboard_arrow_up,
            ),
          ),

          // 2. AŞAĞI BUTONU
          Positioned(
            bottom: 0,
            left: (dpadSize - btnSize) / 2,
            width: btnSize,
            height: btnSize,
            child: _buildArrowButton(
              onAction: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.down),
              icon: Icons.keyboard_arrow_down,
            ),
          ),

          // 3. SOL BUTONU
          Positioned(
            left: 0,
            top: (dpadSize - btnSize) / 2,
            width: btnSize,
            height: btnSize,
            child: _buildArrowButton(
              onAction: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.left),
              icon: Icons.keyboard_arrow_left,
            ),
          ),

          // 4. SAĞ BUTONU
          Positioned(
            right: 0,
            top: (dpadSize - btnSize) / 2,
            width: btnSize,
            height: btnSize,
            child: _buildArrowButton(
              onAction: () => ref.read(gameNotifierProvider.notifier).changeDirection(PlayerDirection.right),
              icon: Icons.keyboard_arrow_right,
            ),
          ),

          // 5. MERKEZ KAZ / VUR BUTONU
          Positioned(
            left: (dpadSize - btnSize) / 2,
            top: (dpadSize - btnSize) / 2,
            width: btnSize,
            height: btnSize,
            child: _buildCenterButton(
              onAction: () => ref.read(gameNotifierProvider.notifier).digTargetTile(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required VoidCallback onAction,
    required IconData icon,
  }) {
    return Listener(
      onPointerDown: (_) => _startAction(onAction),
      onPointerUp: (_) => _stopAction(),
      onPointerCancel: (_) => _stopAction(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xB3164424),
          borderRadius: BorderRadius.circular(10),
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
        child: Center(
          child: Icon(
            icon,
            color: AppColors.neonGreen,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required VoidCallback onAction,
  }) {
    return Listener(
      onPointerDown: (_) => _startAction(onAction),
      onPointerUp: (_) => _stopAction(),
      onPointerCancel: (_) => _stopAction(),
      child: Container(
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
          child: Icon(Icons.hardware, color: AppColors.neonGreen, size: 20),
        ),
      ),
    );
  }
}


