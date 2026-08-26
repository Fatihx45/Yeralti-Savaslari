import 'dart:math';
import 'package:flutter/material.dart';

class LavaParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  Color color;

  LavaParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });

  static LavaParticle random(Random rnd, Size size) {
    final colors = [
      const Color(0xFFFF5722), // Lav Turuncusu
      const Color(0xFFFFAB00), // Akkor Altın
      const Color(0xFFFF3D00), // Kor Kırmızısı
      const Color(0xFFFFD600), // Parlak Sarı
    ];

    return LavaParticle(
      x: rnd.nextDouble() * size.width,
      y: rnd.nextDouble() * size.height,
      size: rnd.nextDouble() * 3.5 + 1.2,
      speed: rnd.nextDouble() * 1.5 + 0.6,
      opacity: rnd.nextDouble() * 0.7 + 0.3,
      color: colors[rnd.nextInt(colors.length)],
    );
  }
}

class LavaParticlesPainter extends CustomPainter {
  final double animationValue;
  final List<LavaParticle> particles;

  LavaParticlesPainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Yukarı doğru süzülme hareketi
      double currentY = p.y - (animationValue * p.speed * 80) % size.height;
      if (currentY < 0) currentY += size.height;

      // Hafif sağa sola salınım
      final double wobble = sin(animationValue * 2 * pi + p.x) * 4.0;
      final double currentX = (p.x + wobble) % size.width;

      paint.color = p.color.withValues(alpha: p.opacity * (1.0 - (size.height - currentY) / size.height * 0.4));

      // Parçacık gölgesi / Akkor ışıma
      canvas.drawCircle(
        Offset(currentX, currentY),
        p.size,
        paint,
      );

      // Parlak çekirdek
      paint.color = Colors.white.withValues(alpha: p.opacity * 0.8);
      canvas.drawCircle(
        Offset(currentX, currentY),
        p.size * 0.4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LavaParticlesPainter oldDelegate) => true;
}
