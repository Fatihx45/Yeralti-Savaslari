import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../domain/models/weapon_model.dart';
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
import 'package:derin_kazi/features/ai_team/application/ai_team_engine.dart';

class MiningScreen extends ConsumerStatefulWidget {
  const MiningScreen({super.key});

  @override
  ConsumerState<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends ConsumerState<MiningScreen> {
  Timer? _botLoopTimer;

  @override
  void initState() {
    super.initState();
    // Sistem Madenci Botları Kazı Döngüsü (Canlı Yapay Zeka Adımları)
    _botLoopTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (!mounted) return;
      final grid = ref.read(gameNotifierProvider).grid;
      if (grid.otherPlayers.isNotEmpty) {
        ref.read(aiTeamNotifierProvider.notifier).performAiTurn(grid, (pos, damage, minerId) {
          ref.read(gameNotifierProvider.notifier).botDigTile(pos, damage, minerId);
        });
      }
    });
  }

  @override
  void dispose() {
    _botLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Positioned(
              top: 48,
              right: 10,
              child: const ReactionBar(),
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
            // KATMAN 6: SAĞ BAŞPARMAK - KAZ/VUR & ATEŞ & ÇANTA & MAĞAZA
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
                          width: 46,
                          height: 40,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.backpack, size: 15, color: Color(0xFFE040FB)),
                              Text(
                                AppStrings.tr('bag', lang: gameState.player.languageCode),
                                style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE040FB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Mağaza Butonu
                      InkWell(
                        onTap: () => ShopPanel.showShopDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 46,
                          height: 40,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.storefront, size: 15, color: AppColors.neonGreen),
                              Text(
                                AppStrings.tr('shop', lang: gameState.player.languageCode),
                                style: const TextStyle(
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
                  const SizedBox(width: 6),

                  // 🔫 ATEŞ ET Butonu
                  const _TurboShootButton(),
                  const SizedBox(width: 6),

                  // Büyük ⛏ KAZ / VUR Eylem Butonu (Basılı Tutunca Seri Kazı)
                  const _TurboDigButton(),
                ],
              ),
            ),

            // ==========================================
            // KATMAN 7: GERİ SAYIM OVERLAY (BR MODU)
            // ==========================================
            if (gameState.gameMode == GameMode.battleRoyale)
              const CountdownOverlay(),

            // ==========================================
            // KATMAN 8: BÖLÜM TAMAMLANDI GEÇİŞ DİYALOĞU
            // ==========================================
            if (gameState.showStageCompleteDialog)
              _buildStageCompleteOverlay(context, ref, gameState),

            // ==========================================
            // KATMAN 9: KUTUDAN EŞYA/LOOT BULUNDU DİYALOĞU
            // ==========================================
            if (gameState.pendingLootMessage != null)
              _buildLootFoundOverlay(context, ref, gameState),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStageCompleteOverlay(BuildContext context, WidgetRef ref, GameState state) {
    final lang = state.player.languageCode;
    final isEn = lang == 'en';

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141432),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neonGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                AppStrings.tr('stage_completed', lang: lang),
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'All monsters defeated!\nProceed to Stage ${state.grid.stage + 1}?'
                    : 'Tüm düşmanlar ve canavarlar alt edildi!\nBölüm ${state.grid.stage + 1}\'e geçmek istiyor musunuz?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ref.read(gameNotifierProvider.notifier).declineStageAdvance();
                      },
                      child: Text(isEn ? 'STAY HERE' : 'BURADA KAL', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ref.read(gameNotifierProvider.notifier).advanceStageConfirmed();
                      },
                      child: Text(isEn ? 'PROCEED 🚀' : 'DEVAM ET 🚀', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLootFoundOverlay(BuildContext context, WidgetRef ref, GameState state) {
    final lang = state.player.languageCode;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1435),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE040FB), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE040FB).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              Text(
                state.pendingLootName ?? AppStrings.tr('item_found', lang: lang),
                style: const TextStyle(
                  color: Color(0xFFE040FB),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.pendingLootMessage ?? AppStrings.tr('item_found_sub', lang: lang),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ref.read(gameNotifierProvider.notifier).declineLoot();
                      },
                      child: Text(AppStrings.tr('leave', lang: lang), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE040FB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ref.read(gameNotifierProvider.notifier).acceptLoot();
                      },
                      child: Text(AppStrings.tr('take_it', lang: lang), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TurboDigButton extends ConsumerStatefulWidget {
  const _TurboDigButton();

  @override
  ConsumerState<_TurboDigButton> createState() => _TurboDigButtonState();
}

class _TurboDigButtonState extends ConsumerState<_TurboDigButton> {
  Timer? _initialDelayTimer;
  Timer? _rapidRepeatTimer;

  @override
  void dispose() {
    _stopAction();
    super.dispose();
  }

  void _startAction() {
    _stopAction();
    // İlk basışta anında kaz/vur
    ref.read(gameNotifierProvider.notifier).digTargetTile();

    // 140ms sonra seri tekrar (her 80ms'de bir)
    _initialDelayTimer = Timer(const Duration(milliseconds: 140), () {
      _rapidRepeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        ref.read(gameNotifierProvider.notifier).digTargetTile();
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
    return Listener(
      onPointerDown: (_) => _startAction(),
      onPointerUp: (_) => _stopAction(),
      onPointerCancel: (_) => _stopAction(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hardware, size: 30, color: AppColors.goldText),
            const SizedBox(height: 2),
            Text(
              AppStrings.tr('dig_hit', lang: ref.watch(gameNotifierProvider.select((s) => s.player.languageCode))),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppColors.goldText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurboShootButton extends ConsumerStatefulWidget {
  const _TurboShootButton();

  @override
  ConsumerState<_TurboShootButton> createState() => _TurboShootButtonState();
}

class _TurboShootButtonState extends ConsumerState<_TurboShootButton> {
  Timer? _initialDelayTimer;
  Timer? _rapidRepeatTimer;

  @override
  void dispose() {
    _stopAction();
    super.dispose();
  }

  void _startAction() {
    _stopAction();
    // İlk basışta anında ateş et
    ref.read(gameNotifierProvider.notifier).fireWeapon();

    // 160ms sonra seri tekrar
    _initialDelayTimer = Timer(const Duration(milliseconds: 160), () {
      _rapidRepeatTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        ref.read(gameNotifierProvider.notifier).fireWeapon();
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
    final player = ref.watch(gameNotifierProvider.select((s) => s.player));
    final hasAmmo = player.currentAmmo > 0;
    final lang = player.languageCode;

    return Listener(
      onPointerDown: (_) => _startAction(),
      onPointerUp: (_) => _stopAction(),
      onPointerCancel: (_) => _stopAction(),
      child: Container(
        width: 76,
        height: 82,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasAmmo
                ? [const Color(0xFF6B1220), const Color(0xFF33050C)]
                : [const Color(0xFF333333), const Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasAmmo ? const Color(0xFFFF5252) : Colors.white24,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: hasAmmo
                  ? const Color(0xFFFF5252).withValues(alpha: 0.35)
                  : Colors.transparent,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              player.equippedWeapon.iconEmoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 1),
            Text(
              AppStrings.tr('fire', lang: lang),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${player.currentAmmo} 🔫',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: hasAmmo ? Colors.amberAccent : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
