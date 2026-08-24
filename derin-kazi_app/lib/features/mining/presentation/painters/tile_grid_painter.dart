import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/grid_model.dart';
import '../../domain/models/tile_model.dart';
import '../../domain/models/enemy_model.dart';
import 'package:derin_kazi/features/multiplayer/domain/models/remote_player_model.dart';

class TileGridPainter extends CustomPainter {
  final GridModel grid;
  final Position? lastDamagedTile;
  final String equippedSkinId;
  final String? activeReactionEmoji;

  TileGridPainter({
    required this.grid,
    this.lastDamagedTile,
    this.equippedSkinId = 'default_blue',
    this.activeReactionEmoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int rows = grid.rows;
    final int cols = grid.columns;

    final double cellWidth = size.width / cols;
    final double cellHeight = size.height / rows;

    // 1. 10 Biyoma Özel Zemin Dokusu & Renk Paleti
    final Color groundColor = _getBiomeGroundColor(grid.biomeName);
    final Paint soilPaint = Paint()..color = groundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), soilPaint);

    final Paint dotPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;

    for (double x = 4; x < size.width; x += 12) {
      for (double y = 4; y < size.height; y += 12) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    // 2. Hücreleri Çiz
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final TileModel tile = grid.tiles[r][c];
        final Rect cellRect = Rect.fromLTWH(
          c * cellWidth,
          r * cellHeight,
          cellWidth,
          cellHeight,
        );

        _drawTile(canvas, tile, cellRect, r, c);
      }
    }

    // 3. Düşmanları / Canavarları Çiz
    _drawEnemies(canvas, grid.enemies, cellWidth, cellHeight);

    // 4. Hedeflenen Hücre Çerçevesi (Target Reticle)
    _drawTargetReticle(canvas, grid.targetCellPosition, cellWidth, cellHeight);

    // 5. Diğer Çoklu Oyuncuları Çiz (Ekip Kazısı)
    _drawOtherPlayers(canvas, grid.otherPlayers, cellWidth, cellHeight);

    // 6. Oyuncu Karakterini Çiz
    _drawPlayer(canvas, grid.playerPosition, cellWidth, cellHeight);
  }

  void _drawEnemies(Canvas canvas, List<EnemyModel> enemies, double cellWidth, double cellHeight) {
    for (final enemy in enemies) {
      if (!enemy.isAlive) continue;

      final double cx = enemy.position.col * cellWidth + cellWidth / 2;
      final double cy = enemy.position.row * cellHeight + cellHeight / 2;
      final double scale = min(cellWidth, cellHeight) / 24.0;
      final double radius = min(cellWidth, cellHeight) * 0.45;

      // 1. Düşman Tehlike Aurası
      final Paint auraPaint = Paint()
        ..color = enemy.isBoss
            ? const Color(0xFFFFD700).withValues(alpha: 0.45)
            : const Color(0xFFFF1744).withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, enemy.isBoss ? 6 : 3);
      canvas.drawCircle(Offset(cx, cy), radius, auraPaint);

      // Boss Çerçeve Parıltısı
      if (enemy.isBoss) {
        final Paint bossRing = Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset(cx, cy), radius + 2, bossRing);
      }

      // 2. Düşman Emojisi
      final textSpan = TextSpan(
        text: enemy.emoji,
        style: TextStyle(
          fontSize: (enemy.isBoss ? 16 : 13) * scale,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
      );

      // 3. Baş Üstü Mini Can Barı (HP Bar)
      final double barWidth = min(cellWidth * 0.9, 28 * scale);
      final double barHeight = 3.5 * scale;
      final double barLeft = cx - barWidth / 2;
      final double barTop = cy - radius - 5 * scale;

      final double hpRatio = (enemy.currentHp / max(1, enemy.maxHp)).clamp(0.0, 1.0);

      // Can Barı Arka Planı (Koyu Kırmızı/Siyah)
      final Paint bgPaint = Paint()..color = const Color(0xFF2E0808);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(barLeft, barTop, barWidth, barHeight), const Radius.circular(2)),
        bgPaint,
      );

      // Can Barı Doluluk (Yeşil / Sarı / Kırmızı)
      Color hpColor = const Color(0xFF00E676);
      if (hpRatio < 0.3) {
        hpColor = const Color(0xFFFF1744);
      } else if (hpRatio < 0.6) {
        hpColor = const Color(0xFFFFD600);
      }

      final Paint fillPaint = Paint()..color = hpColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(barLeft, barTop, barWidth * hpRatio, barHeight), const Radius.circular(2)),
        fillPaint,
      );

      // Can Barı Çerçevesi
      final Paint borderPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(barLeft, barTop, barWidth, barHeight), const Radius.circular(2)),
        borderPaint,
      );

      // 4. Boss ise Baş Üstü Küçük İsim Etiketi
      if (enemy.isBoss) {
        final nameSpan = TextSpan(
          text: enemy.name.length > 12 ? '${enemy.name.substring(0, 10)}..' : enemy.name,
          style: TextStyle(
            color: const Color(0xFFFFD700),
            fontSize: 7 * scale,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        );
        final namePainter = TextPainter(
          text: nameSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        namePainter.paint(
          canvas,
          Offset(cx - namePainter.width / 2, barTop - 9 * scale),
        );
      }
    }
  }

  void _drawOtherPlayers(Canvas canvas, List<RemotePlayerModel> players, double cellWidth, double cellHeight) {
    const List<Color> playerShirtColors = [
      Color(0xFFE91E63), // Pink
      Color(0xFF00E5FF), // Cyan
      Color(0xFF76FF03), // Lime
      Color(0xFFFF9100), // Orange
      Color(0xFFE040FB), // Purple
      Color(0xFFFF5252), // Red
      Color(0xFF1DE9B6), // Teal
      Color(0xFF448AFF), // Blue
      Color(0xFFFFD600), // Yellow
      Color(0xFFB388FF), // Lavender
    ];

    const List<Color> playerPantsColors = [
      Color(0xFF880E4F), // Dark Pink
      Color(0xFF006064), // Dark Cyan
      Color(0xFF33691E), // Dark Lime
      Color(0xFFE65100), // Dark Orange
      Color(0xFF4A148C), // Dark Purple
      Color(0xFFB71C1C), // Dark Red
      Color(0xFF004D40), // Dark Teal
      Color(0xFF0D47A1), // Dark Blue
      Color(0xFFF57F17), // Dark Yellow
      Color(0xFF311B92), // Dark Lavender
    ];

    for (final p in players) {
      final Color shirtColor = playerShirtColors[p.colorIndex % playerShirtColors.length];
      final Color pantsColor = playerPantsColors[p.colorIndex % playerPantsColors.length];
      final double cx = p.position.col * cellWidth + cellWidth / 2;
      final double cy = p.position.row * cellHeight + cellHeight / 2;
      final double scale = min(cellWidth, cellHeight) / 24.0;

      _drawMinerCharacter(
        canvas,
        Offset(cx, cy),
        scale,
        shirtColor: shirtColor,
        pantsColor: pantsColor,
        helmetColor: Colors.white,
        nameLabel: p.displayName.isNotEmpty ? p.displayName : 'Madenci',
      );
    }
  }

  void _drawTargetReticle(Canvas canvas, Position targetPos, double cellWidth, double cellHeight) {
    final Rect targetRect = Rect.fromLTWH(
      targetPos.col * cellWidth,
      targetPos.row * cellHeight,
      cellWidth,
      cellHeight,
    );

    // Neon Yeşil Hedef Vurgu Çerçevesi
    final Paint reticlePaint = Paint()
      ..color = AppColors.neonGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final RRect rrect = RRect.fromRectAndRadius(targetRect.deflate(1), const Radius.circular(3));
    canvas.drawRRect(rrect, reticlePaint);

    // 4 Köşe Vurgusu
    final double cornerLen = min(cellWidth, cellHeight) * 0.25;
    final Paint cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Sol-Üst
    canvas.drawLine(Offset(targetRect.left + 1, targetRect.top + 1), Offset(targetRect.left + 1 + cornerLen, targetRect.top + 1), cornerPaint);
    canvas.drawLine(Offset(targetRect.left + 1, targetRect.top + 1), Offset(targetRect.left + 1, targetRect.top + 1 + cornerLen), cornerPaint);

    // Sağ-Üst
    canvas.drawLine(Offset(targetRect.right - 1, targetRect.top + 1), Offset(targetRect.right - 1 - cornerLen, targetRect.top + 1), cornerPaint);
    canvas.drawLine(Offset(targetRect.right - 1, targetRect.top + 1), Offset(targetRect.right - 1, targetRect.top + 1 + cornerLen), cornerPaint);

    // Sol-Alt
    canvas.drawLine(Offset(targetRect.left + 1, targetRect.bottom - 1), Offset(targetRect.left + 1 + cornerLen, targetRect.bottom - 1), cornerPaint);
    canvas.drawLine(Offset(targetRect.left + 1, targetRect.bottom - 1), Offset(targetRect.left + 1, targetRect.bottom - 1 - cornerLen), cornerPaint);

    // Sağ-Alt
    canvas.drawLine(Offset(targetRect.right - 1, targetRect.bottom - 1), Offset(targetRect.right - 1 - cornerLen, targetRect.bottom - 1), cornerPaint);
    canvas.drawLine(Offset(targetRect.right - 1, targetRect.bottom - 1), Offset(targetRect.right - 1, targetRect.bottom - 1 - cornerLen), cornerPaint);
  }

  void _drawTile(Canvas canvas, TileModel tile, Rect rect, int row, int col) {
    if (tile.isCleared || tile.type == TileType.empty) {
      // Kazılmış siyah alan
      final Paint emptyPaint = Paint()..color = AppColors.emptyTile;
      canvas.drawRect(rect, emptyPaint);

      // İnce koyu kırmızı parçacıklar
      final Paint speckPaint = Paint()..color = const Color(0xFF3A1010);
      canvas.drawCircle(Offset(rect.center.dx - 4, rect.center.dy - 3), 1, speckPaint);
      canvas.drawCircle(Offset(rect.center.dx + 5, rect.center.dy + 4), 1.2, speckPaint);
      return;
    }

    switch (tile.type) {
      case TileType.solidGold:
        _drawSolidGoldTile(canvas, rect, tile);
        break;
      case TileType.rock:
      case TileType.chest:       // Dışarıdan kapalı kaya kutusu görünür (Gizli)
      case TileType.emeraldOre:  // Dışarıdan kapalı kaya kutusu görünür (Gizli)
      case TileType.goldOre:     // Dışarıdan kapalı kaya kutusu görünür (Gizli)
        _drawRockTile(canvas, rect, tile);
        break;
      case TileType.soil:
      case TileType.hiddenMine:  // Dışarıdan normal toprak gibi görünür (Gizli Mayın)
      case TileType.tnt:         // Dışarıdan normal toprak gibi görünür (Gizli)
      case TileType.potion:      // Dışarıdan normal toprak gibi görünür (Gizli)
      case TileType.specialItem: // Dışarıdan normal toprak gibi görünür (Gizli)
        _drawSoilTile(canvas, rect, tile);
        break;
      case TileType.bossCore:
        _drawBossCoreTile(canvas, rect, tile);
        break;
      case TileType.empty:
        break;
    }

    // Hasar / Çatlak Çizimi (Yalnızca kırılabilir bloklar için)
    if (!tile.isUnbreakable && tile.currentHp < tile.maxHp && tile.maxHp > 0) {
      final double damageRatio = 1.0 - (tile.currentHp / tile.maxHp);
      _drawCracks(canvas, rect, damageRatio);
    }
  }

  void _drawBossCoreTile(Canvas canvas, Rect rect, TileModel tile) {
    // 👑 Titan Kristal Çekirdeği: Devasa Parlayan Mor/Eflatun Kristal
    final Paint outerGlow = Paint()
      ..color = const Color(0xFFE040FB).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(rect.inflate(2), outerGlow);

    final Paint baseFill = Paint()..color = const Color(0xFF4A148C);
    final RRect rrect = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4));
    canvas.drawRRect(rrect, baseFill);

    // İç Kristal Çizgileri
    final Paint crystalLine = Paint()
      ..color = const Color(0xFFEA80FC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = rect.center;
    final Path starPath = Path()
      ..moveTo(center.dx, rect.top + 2)
      ..lineTo(rect.right - 2, center.dy)
      ..lineTo(center.dx, rect.bottom - 2)
      ..lineTo(rect.left + 2, center.dy)
      ..close();
    canvas.drawPath(starPath, crystalLine);

    // Merkez Parlama
    final Paint centerShine = Paint()..color = Colors.white;
    canvas.drawCircle(center, 3, centerShine);

    final Paint borderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawSolidGoldTile(Canvas canvas, Rect rect, TileModel tile) {
    // 1. Canlı Parlak Sarı Ana Dolgu
    final Paint goldFill = Paint()..color = const Color(0xFFF1C40F);
    final RRect rrect = RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(2));
    canvas.drawRRect(rrect, goldFill);

    // 2. Koyu Altın/Kahverengi Dış Çerçeve
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF7A5C00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Sol Üst Köşedeki Kare Beyaz Işıltı / Parlama (Referans görseldeki gibi)
    final Paint shinePaint = Paint()..color = Colors.white;
    final Rect shineRect = Rect.fromLTWH(
      rect.left + 2,
      rect.top + 2,
      rect.width * 0.28,
      rect.height * 0.28,
    );
    canvas.drawRect(shineRect, shinePaint);
  }

  void _drawRockTile(Canvas canvas, Rect rect, TileModel tile) {
    // Koyu kızıl-kahve çerçeveli kapalı kaya kutusu (İçeriği gizli)
    final Paint framePaint = Paint()..color = AppColors.tileFrame;
    final Paint innerPaint = Paint()..color = AppColors.tileRock;
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF381010)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final RRect rrect = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(2));
    canvas.drawRRect(rrect, framePaint);
    canvas.drawRRect(rrect.deflate(2.5), innerPaint);
    canvas.drawRRect(rrect, borderPaint);

    // İç süsleme: Ortada vida/dişli deseni
    final Paint darkDetail = Paint()..color = const Color(0xFF2B0A0A);
    final center = rect.center;
    canvas.drawRect(Rect.fromCenter(center: center, width: rect.width * 0.4, height: rect.height * 0.4), darkDetail);

    final Paint dotPaint = Paint()..color = const Color(0xFFC2571F);
    canvas.drawCircle(center, 2, dotPaint);
  }

  void _drawSoilTile(Canvas canvas, Rect rect, TileModel tile) {
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF9E3E10).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRect(rect.deflate(0.5), borderPaint);
  }

  void _drawCracks(Canvas canvas, Rect rect, double ratio) {
    final Paint crackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final center = rect.center;
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx - rect.width * 0.3 * ratio, center.dy - rect.height * 0.3 * ratio);
    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx + rect.width * 0.35 * ratio, center.dy + rect.height * 0.25 * ratio);

    if (ratio > 0.5) {
      path.moveTo(center.dx, center.dy);
      path.lineTo(center.dx + rect.width * 0.25 * ratio, center.dy - rect.height * 0.35 * ratio);
    }

    canvas.drawPath(path, crackPaint);
  }

  void _drawPlayer(Canvas canvas, Position pos, double cellWidth, double cellHeight) {
    final double left = pos.col * cellWidth;
    final double top = pos.row * cellHeight;
    final Rect pRect = Rect.fromLTWH(left, top, cellWidth, cellHeight);
    final center = pRect.center;
    final double scale = min(cellWidth, cellHeight) / 24.0;

    Color shirt = const Color(0xFF1976D2);
    Color pants = const Color(0xFFD32F2F);
    Color helmet = Colors.white;

    if (equippedSkinId == 'gold_knight') {
      shirt = const Color(0xFFFFD700);
      pants = const Color(0xFFB8860B);
      helmet = const Color(0xFFFFF8DC);
    } else if (equippedSkinId == 'lava_miner') {
      shirt = const Color(0xFFFF3D00);
      pants = const Color(0xFF212121);
      helmet = const Color(0xFFFF6E40);
    } else if (equippedSkinId == 'emerald_guardian') {
      shirt = const Color(0xFF00E676);
      pants = const Color(0xFF1B5E20);
      helmet = const Color(0xFF69F0AE);
    } else if (equippedSkinId == 'crystal_lord') {
      shirt = const Color(0xFF00E5FF);
      pants = const Color(0xFF006064);
      helmet = const Color(0xFFE0F7FA);
    }

    _drawMinerCharacter(
      canvas,
      center,
      scale,
      shirtColor: shirt,
      pantsColor: pants,
      helmetColor: helmet,
    );

    // Kafa Üstü Emoji Baloncuğu
    if (activeReactionEmoji != null) {
      final bubbleCenter = Offset(center.dx, center.dy - 18 * scale);
      final bubblePaint = Paint()..color = const Color(0xFF0F0F28);
      final borderPaint = Paint()
        ..color = AppColors.neonGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: bubbleCenter, width: 22 * scale, height: 16 * scale), const Radius.circular(6)),
        bubblePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: bubbleCenter, width: 22 * scale, height: 16 * scale), const Radius.circular(6)),
        borderPaint,
      );

      final textSpan = TextSpan(
        text: activeReactionEmoji,
        style: TextStyle(fontSize: 10 * scale),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(bubbleCenter.dx - textPainter.width / 2, bubbleCenter.dy - textPainter.height / 2));
    }
  }

  void _drawMinerCharacter(
    Canvas canvas,
    Offset center,
    double scale, {
    required Color shirtColor,
    required Color pantsColor,
    required Color helmetColor,
    String? nameLabel,
  }) {
    // 1. Bacaklar / Pantolon
    final Paint pantsPaint = Paint()..color = pantsColor;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 5 * scale),
        width: 8 * scale,
        height: 6 * scale,
      ),
      pantsPaint,
    );

    // 2. Gövde / Tişört
    final Paint shirtPaint = Paint()..color = shirtColor;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 1 * scale),
        width: 10 * scale,
        height: 7 * scale,
      ),
      shirtPaint,
    );

    // 3. Kafa (Ten rengi)
    final Paint skinPaint = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawCircle(
      Offset(center.dx, center.dy - 5 * scale),
      4 * scale,
      skinPaint,
    );

    // 4. Baret / Kask
    final Paint helmetPaint = Paint()..color = helmetColor;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 6.5 * scale),
        width: 10 * scale,
        height: 7 * scale,
      ),
      pi,
      pi,
      true,
      helmetPaint,
    );

    // Kask Işığı (Sarı spot)
    final Paint lightPaint = Paint()..color = AppColors.goldText;
    canvas.drawCircle(Offset(center.dx, center.dy - 7 * scale), 1.5 * scale, lightPaint);

    // Baş Üstü İsim Rozeti (Diğer takım arkadaşları için)
    if (nameLabel != null) {
      final String initial = nameLabel.isNotEmpty ? nameLabel[0].toUpperCase() : 'M';
      final textSpan = TextSpan(
        text: initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - 14 * scale),
      );
    }
  }

  Color _getBiomeGroundColor(String biomeName) {
    if (biomeName.contains('Kızıl Toprak')) return const Color(0xFF5A2208);
    if (biomeName.contains('Bakır Yamaç')) return const Color(0xFF6E3214);
    if (biomeName.contains('Kömür')) return const Color(0xFF22222E);
    if (biomeName.contains('Demir')) return const Color(0xFF383848);
    if (biomeName.contains('Zümrüt')) return const Color(0xFF0F3A22);
    if (biomeName.contains('Obsidyen')) return const Color(0xFF26123A);
    if (biomeName.contains('Ejder')) return const Color(0xFF5E1414);
    if (biomeName.contains('Buzul')) return const Color(0xFF143854);
    if (biomeName.contains('Volkanik')) return const Color(0xFF6A1A0A);
    if (biomeName.contains("Titan")) return const Color(0xFF2E1245);
    return AppColors.soilGround;
  }

  @override
  bool shouldRepaint(covariant TileGridPainter oldDelegate) {
    return true;
  }
}

