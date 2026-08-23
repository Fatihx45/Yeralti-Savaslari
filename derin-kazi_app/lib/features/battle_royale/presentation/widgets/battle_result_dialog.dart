import 'package:flutter/material.dart';

class BattleResultDialog extends StatelessWidget {
  final String? winnerName;
  final bool isDraw;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const BattleResultDialog({
    super.key,
    this.winnerName,
    this.isDraw = false,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasWinner = !isDraw && winnerName != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasWinner ? const Color(0xFFFFD700) : const Color(0xFF4A4A8A),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasWinner ? const Color(0xFFFFD700) : Colors.cyan).withValues(alpha: 0.3),
              blurRadius: 25,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasWinner ? Icons.emoji_events : Icons.handshake,
              size: 56,
              color: hasWinner ? const Color(0xFFFFD700) : Colors.white70,
            ),
            const SizedBox(height: 12),
            Text(
              hasWinner ? '🏆 ŞAMPİYON BELLİ OLDU!' : '🤝 OYUN BERABERE BİTTİ!',
              style: TextStyle(
                color: hasWinner ? const Color(0xFFFFD700) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF16163A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E2E68)),
              ),
              child: Text(
                hasWinner
                    ? '$winnerName\nHayatta Kalan Tek Madenci Oldu!'
                    : '3+1 Dakika Süre Doldu!\nBirden Fazla Madenci Hayatta Kaldı.',
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF4A4A8A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onMainMenu,
                    child: const Text('ANA MENÜ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onPlayAgain,
                    child: const Text('YENİ MAÇ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

