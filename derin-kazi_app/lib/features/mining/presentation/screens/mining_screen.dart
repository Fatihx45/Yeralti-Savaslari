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
import '../widgets/boss_health_bar.dart';
import '../widgets/mining_toast_badge.dart';

import 'package:derin_kazi/features/battle_royale/presentation/widgets/player_scoreboard_panel.dart';
import 'package:derin_kazi/features/battle_royale/presentation/widgets/inventory_slot_bar.dart';
import 'package:derin_kazi/features/battle_royale/presentation/widgets/countdown_overlay.dart';
import 'package:derin_kazi/features/battle_royale/presentation/widgets/battle_result_dialog.dart';
import 'package:derin_kazi/features/multiplayer/presentation/widgets/reaction_bar.dart';

class MiningScreen extends ConsumerWidget {
  const MiningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<GameState>(gameNotifierProvider, (previous, next) {
      // 1. Battle Royale Oyun Sonu Dialog'u (Sadece BR Modunda)
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
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
            // ==========================================
            // KATMAN 1: ANA OYUN IZGARASI (TAM EKRAN)
            // ==========================================
            Positioned.fill(
              top: 44,
              bottom: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: const MiningGridView(),
                ),
              ),
            ),

            // ==========================================
            // KATMAN 2: ÜST HUD & BOSS BARI
            // ==========================================
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HudBar(),
            ),

            // Boss Can Barı (Varsa HUD altında belirir)
            const Positioned(
              top: 44,
              left: 40,
              right: 40,
              child: BossHealthBar(),
            ),

            // ==========================================
            // KATMAN 3: ÇOK OYUNCULU SKORKART & EMOJİLER & BİLDİRİM KARTI
            // ==========================================
            if (gameState.grid.otherPlayers.isNotEmpty || gameState.gameMode == GameMode.battleRoyale)
              const Positioned(
                top: 48,
                left: 10,
                child: PlayerScoreboardPanel(),
              ),

            // Sağ Üst Hızlı Tepki Emojileri
            const Positioned(
              top: 48,
              right: 10,
              child: ReactionBar(),
            ),

            // Sağ Üst İkonların Hemen Altında Kare Bildirim Kartı
            Positioned(
              top: 82,
              right: 10,
              child: MiningToastBadge(
                message: gameState.lastMessage,
              ),
            ),

            // ==========================================
            // KATMAN 4: SOL BAŞPARMAK - D-PAD KONTROLÜ
            // ==========================================
            const Positioned(
              left: 12,
              bottom: 8,
              child: DirectionalPad(),
            ),

            // ==========================================
            // KATMAN 5: ALT ORTA - ALET ÇANTASI & CAN/ENERJİ
            // ==========================================
            Positioned(
              bottom: 6,
              left: 136,
              right: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const InventorySlotBar(),
                  const SizedBox(height: 4),
                  const BottomProgressBar(),
                ],
              ),
            ),

            // ==========================================
            // KATMAN 6: SAĞ BAŞPARMAK - KAZ/VUR & ÇANTA & MAĞAZA
            // ==========================================
            Positioned(
              right: 12,
              bottom: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Çanta & Mağaza İkili Sütunu
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Çanta Butonu
                      InkWell(
                        onTap: () => InventoryDialog.showInventoryDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xCC261245),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE040FB), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE040FB).withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.backpack, size: 16, color: Color(0xFFE040FB)),
                              Text(
                                'ÇANTA',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE040FB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Mağaza Butonu
                      InkWell(
                        onTap: () => ShopPanel.showShopDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xCC142445),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neonGreen, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storefront, size: 16, color: AppColors.neonGreen),
                              Text(
                                'MAĞAZA',
                                style: TextStyle(
                                  fontSize: 7,
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
                  const SizedBox(width: 8),

                  // Büyük ⛏ KAZ / VUR Eylem Butonu
                  InkWell(
                    onTap: () => ref.read(gameNotifierProvider.notifier).digTargetTile(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B360B), Color(0xFF2E1302)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.goldText, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldText.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hardware, size: 30, color: AppColors.goldText),
                          SizedBox(height: 2),
                          Text(
                            'KAZ / VUR',
                            style: TextStyle(
                              fontSize: 9,
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
            ),

            // ==========================================
            // KATMAN 7: GERİ SAYIM OVERLAY (BR MODU)
            // ==========================================
            if (gameState.gameMode == GameMode.battleRoyale)
              const CountdownOverlay(),
          ],
        ),
      ),
    ),
  );
}
}
