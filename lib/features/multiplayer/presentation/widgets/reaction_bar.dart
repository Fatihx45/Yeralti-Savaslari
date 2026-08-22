import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mining/application/game_notifier.dart';

class ReactionBar extends ConsumerWidget {
  const ReactionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const emojis = ['⛏️', '💎', '❤️', '🔥', '👑', '💣'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F28).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A5E), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: emojis.map((emoji) {
          return InkWell(
            onTap: () {
              ref.read(gameNotifierProvider.notifier).sendReaction(emoji);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
