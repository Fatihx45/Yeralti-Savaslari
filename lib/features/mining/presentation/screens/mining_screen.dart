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

import 'package:flutter_application_1/features/battle_royale/presentation/widgets/player_scoreboard_panel.dart';
import 'package:flutter_application_1/features/battle_royale/presentation/widgets/inventory_slot_bar.dart';
import 'package:flutter_application_1/features/battle_royale/presentation/widgets/countdown_overlay.dart';
import 'package:flutter_application_1/features/battle_royale/presentation/widgets/battle_result_dialog.dart';

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

      // 2. Battle Royale Oyun Sonu Dialog'u
      if (next.battlePhase.isFinished && previous?.battlePhase.isFinished != true) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Üst HUD Şeridi (Süre & Faz Sayacı)
                const HudBar(),

                // 2. Ana Oyun ve Kazı Alanı (Grid + Scoreboard)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        // Kazı Izgarası (Grid) ve Sol Üst Can Skorkartı
                        Expanded(
                          child: Stack(
                            children: [
                              const Center(
                                child: MiningGridView(),
                              ),
                              // Sol Üst Köşe: Madenciler ve Canları
                              const Positioned(
                                top: 6,
                                left: 6,
                                child: PlayerScoreboardPanel(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Alt Bölüm: 5 Yuvalı Alet Çantası + D-Pad + KAZ Butonu + Çanta + Mağaza
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1. Yön Tuşlarının Yanında 5 Yuvalı Envanter Çantası
                              const InventorySlotBar(),
                              const SizedBox(width: 12),

                              // 2. D-Pad (4 Yönlü Hareket)
                              const DirectionalPad(),
                              const SizedBox(width: 14),

                              // 3. Büyük KAZ / VURMA Butonu
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E1A0A),
                                  foregroundColor: AppColors.goldText,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  side: const BorderSide(color: AppColors.goldText, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                  shadowColor: AppColors.goldText.withValues(alpha: 0.5),
                                ),
                                onPressed: () {
                                  ref.read(gameNotifierProvider.notifier).digTargetTile();
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hardware, size: 24, color: AppColors.goldText),
                                    SizedBox(height: 3),
                                    Text(
                                      '⛏ KAZ / ⚔️ VUR',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: AppColors.goldText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // 4. Çanta / Envanter Butonu
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E1038),
                                  foregroundColor: const Color(0xFFE040FB),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  side: const BorderSide(color: Color(0xFFE040FB), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: () {
                                  InventoryDialog.showInventoryDialog(context);
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.backpack, size: 20, color: Color(0xFFE040FB)),
                                    SizedBox(height: 3),
                                    Text(
                                      'ÇANTA',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE040FB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // 5. Mağaza Butonu
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1A4A),
                                  foregroundColor: AppColors.neonGreen,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: () {
                                  ShopPanel.showShopDialog(context);
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.storefront, size: 20, color: AppColors.neonGreen),
                                    SizedBox(height: 3),
                                    Text(
                                      'MAĞAZA',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neonGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Alt Can ve Enerji Çubuğu
                const BottomProgressBar(),
              ],
            ),

            // 4. 3 Saniyelik Geri Sayım Tam Ekran Overlay'i
            const CountdownOverlay(),
          ],
        ),
      ),
    );
  }
}
