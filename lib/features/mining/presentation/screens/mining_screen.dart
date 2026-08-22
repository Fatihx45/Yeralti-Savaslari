import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/game_notifier.dart';
import '../widgets/hud_bar.dart';
import '../widgets/shop_panel.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/mining_grid_view.dart';
import '../widgets/directional_pad.dart';
import '../widgets/bottom_progress_bar.dart';

import 'package:derin_kazi/features/battle_royale/presentation/widgets/player_scoreboard_panel.dart';
import 'package:derin_kazi/features/battle_royale/presentation/widgets/inventory_slot_bar.dart';
import 'package:derin_kazi/features/battle_royale/presentation/widgets/countdown_overlay.dart';
import 'package:derin_kazi/features/battle_royale/presentation/widgets/battle_result_dialog.dart';

class MiningScreen extends ConsumerWidget {
  const MiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<GameState>(gameNotifierProvider, (previous, next) {
      // 1. Toast Mesajları
      if (next.lastMessage != null && next.lastMessage != previous?.lastMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.lastMessage!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.hudPanel,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 2. Battle Royale Oyun Sonu Dialog'u (Sadece BR Modunda)
      if (next.gameMode == GameMode.battleRoyale &&
          next.battlePhase.isFinished &&
          previous?.battlePhase.isFinished != true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => BattleResultDialog(
            winnerName: next.battlePhase.winnerName,
            isDraw: next.battlePhase.isDraw,
            onPlayAgain: () {
              Navigator.pop(ctx);
              ref.read(gameNotifierProvider.notifier).startBattleRoyaleMatch();
            },
            onMainMenu: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        );
      }
    });

    final gameState = ref.watch(gameNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Üst Mobil HUD Şeridi
                const HudBar(),

                // 2. Ana Kazı Alanı (Grid + Scoreboard)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Stack(
                      children: [
                        const Center(
                          child: MiningGridView(),
                        ),
                        // Sol Üst Köşe: Canlı Skorkart
                        if (gameState.grid.otherPlayers.isNotEmpty || gameState.gameMode == GameMode.battleRoyale)
                          const Positioned(
                            top: 4,
                            left: 4,
                            child: PlayerScoreboardPanel(),
                          ),
                      ],
                    ),
                  ),
                ),

                // 3. Mobil Ergonomik Kontrol Alanı (Gamepad Düzeni)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C0C22),
                    border: Border(
                      top: BorderSide(color: Color(0xFF1E1E48), width: 1.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Üst: 1-5 Alet Yuvaları
                      const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: InventorySlotBar(),
                      ),
                      const SizedBox(height: 6),

                      // Alt: Çift Başparmak Kontrolleri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Sol Başparmak: 4 Yönlü D-Pad
                          const DirectionalPad(),

                          // Sağ Başparmak: Büyük KAZ / VUR + ÇANTA & MAĞAZA
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Çanta & Mağaza Kolonu
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Çanta Butonu
                                  InkWell(
                                    onTap: () => InventoryDialog.showInventoryDialog(context),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 58,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF261245),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE040FB), width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE040FB).withValues(alpha: 0.25),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.backpack, size: 18, color: Color(0xFFE040FB)),
                                          SizedBox(height: 2),
                                          Text(
                                            'ÇANTA',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE040FB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Mağaza Butonu
                                  InkWell(
                                    onTap: () => ShopPanel.showShopDialog(context),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 58,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF142445),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.neonGreen, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.neonGreen.withValues(alpha: 0.25),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.storefront, size: 18, color: AppColors.neonGreen),
                                          SizedBox(height: 2),
                                          Text(
                                            'MAĞAZA',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.neonGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),

                              // Büyük KAZ / VUR Butonu (Sağ Başparmak Odaklı)
                              InkWell(
                                onTap: () => ref.read(gameNotifierProvider.notifier).digTargetTile(),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 96,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF4A2508), Color(0xFF261102)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.goldText, width: 2.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.goldText.withValues(alpha: 0.45),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.hardware, size: 30, color: AppColors.goldText),
                                      SizedBox(height: 4),
                                      Text(
                                        '⛏ KAZ / VUR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: AppColors.goldText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 4. Alt Can & Enerji Çubuğu
                const BottomProgressBar(),
              ],
            ),

            // 5. 3 Saniyelik Geri Sayım Overlay (Sadece BR Modunda)
            if (gameState.gameMode == GameMode.battleRoyale)
              const CountdownOverlay(),
          ],
        ),
      ),
    );
  }
}
