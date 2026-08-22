import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/domain/models/tool_model.dart';

class InventorySlotBar extends ConsumerWidget {
  const InventorySlotBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final tools = gameState.player.inventoryTools;
    final activeIndex = gameState.player.activeToolIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D26).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E2E68), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.backpack, color: AppColors.goldText, size: 12),
                SizedBox(width: 4),
                Text(
                  'ALET ÇANTASI (1-5)',
                  style: TextStyle(color: AppColors.goldText, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final bool hasTool = index < tools.length;
              final ToolType? tool = hasTool ? tools[index] : null;
              final bool isActive = hasTool && index == activeIndex;

              return GestureDetector(
                onTap: hasTool
                    ? () {
                        ref.read(gameNotifierProvider.notifier).selectInventoryTool(index);
                      }
                    : null,
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1E3A24)
                        : (hasTool ? const Color(0xFF1E1E44) : const Color(0xFF12122A)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive
                          ? AppColors.neonGreen
                          : (hasTool ? const Color(0xFF4A4A8A) : const Color(0xFF222244)),
                      width: isActive ? 2.0 : 1.0,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.neonGreen.withValues(alpha: 0.35),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: hasTool
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tool!.iconEmoji,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                '+${tool.pvpDamage}',
                                style: const TextStyle(
                                  color: AppColors.goldText,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

