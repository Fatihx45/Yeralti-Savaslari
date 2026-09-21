import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/grid_model.dart';
import '../../application/game_notifier.dart';

/// Mobil dokunmatik ekranlar için tasarlanmış modern Sanal Joystick (Virtual Joystick)
class DirectionalPad extends ConsumerStatefulWidget {
  const DirectionalPad({super.key});

  @override
  ConsumerState<DirectionalPad> createState() => _DirectionalPadState();
}

class _DirectionalPadState extends ConsumerState<DirectionalPad>
    with SingleTickerProviderStateMixin {
  // Joystick Boyutları
  static const double _baseSize = 128.0;
  static const double _knobSize = 48.0;
  static const double _maxDistance = 38.0;
  static const double _deadZone = 8.0;
  static const Offset _center = Offset(_baseSize / 2, _baseSize / 2);

  // Durum değişkenleri
  Offset _knobOffset = Offset.zero;
  PlayerDirection? _currentDirection;
  Timer? _initialDelayTimer;
  Timer? _rapidRepeatTimer;

  // Parmak bırakıldığında merkeze yaylanma animasyonu
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..addListener(() {
        setState(() {
          _knobOffset = _springAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _stopTimers();
    _springController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    _springController.stop();
    _processDelta(event.localPosition - _center);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _processDelta(event.localPosition - _center);
  }

  void _onPointerUp(PointerUpEvent event) {
    _resetKnob();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _resetKnob();
  }

  void _processDelta(Offset delta) {
    final distance = delta.distance;

    Offset clampedOffset;
    if (distance > _maxDistance) {
      clampedOffset = (delta / distance) * _maxDistance;
    } else {
      clampedOffset = delta;
    }

    setState(() {
      _knobOffset = clampedOffset;
    });

    if (clampedOffset.distance >= _deadZone) {
      final direction = _calculateDirection(clampedOffset);
      if (direction != _currentDirection) {
        _currentDirection = direction;
        _startMoving(direction);
      }
    } else {
      if (_currentDirection != null) {
        _currentDirection = null;
        _stopTimers();
      }
    }
  }

  PlayerDirection _calculateDirection(Offset offset) {
    final angle = math.atan2(offset.dy, offset.dx); // -pi to +pi
    // 4 Yönlü hesaplama:
    // Sağ: [-pi/4, pi/4]
    // Aşağı: (pi/4, 3pi/4)
    // Sol: [3pi/4, pi] veya [-pi, -3pi/4]
    // Yukarı: (-3pi/4, -pi/4)
    if (angle >= -math.pi / 4 && angle <= math.pi / 4) {
      return PlayerDirection.right;
    } else if (angle > math.pi / 4 && angle < 3 * math.pi / 4) {
      return PlayerDirection.down;
    } else if (angle < -math.pi / 4 && angle > -3 * math.pi / 4) {
      return PlayerDirection.up;
    } else {
      return PlayerDirection.left;
    }
  }

  void _startMoving(PlayerDirection direction) {
    _stopTimers();

    // İlk adım anında atılır
    ref.read(gameNotifierProvider.notifier).changeDirection(direction);

    // 110ms sonra seri akıcı hareket başlar (her 80ms'de bir adım)
    _initialDelayTimer = Timer(const Duration(milliseconds: 110), () {
      _rapidRepeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        if (_currentDirection != null) {
          ref.read(gameNotifierProvider.notifier).changeDirection(_currentDirection!);
        }
      });
    });
  }

  void _stopTimers() {
    _initialDelayTimer?.cancel();
    _initialDelayTimer = null;
    _rapidRepeatTimer?.cancel();
    _rapidRepeatTimer = null;
  }

  void _resetKnob() {
    _stopTimers();
    _currentDirection = null;

    _springAnimation = Tween<Offset>(
      begin: _knobOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic));

    _springController.reset();
    _springController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _baseSize,
      height: _baseSize,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. JOYSTICK TABANI (BASE)
            Container(
              width: _baseSize,
              height: _baseSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x770A0F1E),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.5),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // 2. İÇ YARDIMCI ÇEMBER & EKSEN REHBERLERİ
            Container(
              width: _baseSize - 36,
              height: _baseSize - 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
                  width: 1.0,
                ),
              ),
            ),

            // Yön İpuçları (Hafif Fütüristik Ok / Noktalar)
            _buildDirectionIndicator(
              top: 8,
              icon: Icons.keyboard_arrow_up,
              isActive: _currentDirection == PlayerDirection.up,
            ),
            _buildDirectionIndicator(
              bottom: 8,
              icon: Icons.keyboard_arrow_down,
              isActive: _currentDirection == PlayerDirection.down,
            ),
            _buildDirectionIndicator(
              left: 8,
              icon: Icons.keyboard_arrow_left,
              isActive: _currentDirection == PlayerDirection.left,
            ),
            _buildDirectionIndicator(
              right: 8,
              icon: Icons.keyboard_arrow_right,
              isActive: _currentDirection == PlayerDirection.right,
            ),

            // 3. MERKEZ HAREKETLİ TOPUZ (KNOB)
            Transform.translate(
              offset: _knobOffset,
              child: Container(
                width: _knobSize,
                height: _knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF225B34),
                      Color(0xFF102819),
                      Color(0xFF07140B),
                    ],
                    stops: [0.2, 0.7, 1.0],
                  ),
                  border: Border.all(
                    color: _currentDirection != null
                        ? AppColors.neonGreen
                        : AppColors.neonGreen.withValues(alpha: 0.7),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(
                        alpha: _currentDirection != null ? 0.45 : 0.2,
                      ),
                      blurRadius: _currentDirection != null ? 10 : 5,
                      spreadRadius: _currentDirection != null ? 2 : 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentDirection != null
                          ? AppColors.neonGreen
                          : AppColors.neonGreen.withValues(alpha: 0.4),
                      boxShadow: [
                        if (_currentDirection != null)
                          BoxShadow(
                            color: AppColors.neonGreen.withValues(alpha: 0.8),
                            blurRadius: 6,
                          ),
                      ],
                    ),
                    child: Icon(
                      Icons.radar,
                      size: 14,
                      color: _currentDirection != null
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionIndicator({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required bool isActive,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        icon,
        size: 16,
        color: isActive
            ? AppColors.neonGreen
            : AppColors.neonGreen.withValues(alpha: 0.25),
      ),
    );
  }
}
