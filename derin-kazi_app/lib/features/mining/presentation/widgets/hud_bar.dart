import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/player_state_model.dart';
import '../../domain/models/grid_model.dart';
import '../../domain/models/weapon_model.dart';
import '../../application/game_notifier.dart';
import '../screens/weapon_shop_screen.dart';
import '../../../quests/presentation/widgets/quest_dialog.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HudBar extends ConsumerWidget {
  const HudBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;
    final grid = gameState.grid;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xD90A0A20),
        border: const Border(
          bottom: BorderSide(color: Color(0x661F1F55), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol Bölüm: Profil Avatarı, Altın, Elmas, 2x Bonus, Ses
          _buildLeftSection(context, ref, player),

          // Orta Bölüm: Bölüm & Biyom Rozeti / BR Zamanı
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildCenterSection(context, grid, player, gameState),
            ),
          ),

          // Sağ Bölüm: Rütbe, Sıfırla, Görevler, Kostümler, Ayarlar
          _buildRightSection(context, ref, player),
        ],
      ),
    );
  }

  Widget _buildLeftSection(BuildContext context, WidgetRef ref, PlayerStateModel player) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profil / Avatar Hızlı Erişim Butonu
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF141438),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldText, width: 1.2),
            ),
            child: const Icon(Icons.account_circle, color: AppColors.goldText, size: 20),
          ),
        ),
        const SizedBox(width: 6),
        // Altın ve Elmas Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F30),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF2A2A6A), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Altın
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.goldText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${player.gold}',
                    style: const TextStyle(
                      color: AppColors.goldText,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Elmas
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond, color: AppColors.cyanText, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    '${player.gems}',
                    style: const TextStyle(
                      color: AppColors.cyanText,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // 2x Bonus Butonu
        InkWell(
          onTap: () {
            ref.read(gameNotifierProvider.notifier).activateDoubleBonus();
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: player.doubleBonusActive
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFF0F3818),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: player.doubleBonusActive
                    ? AppColors.neonGreen
                    : const Color(0xFF2E7D32),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.doubleBonusActive ? '2x' : '2x (500)',
                  style: TextStyle(
                    color: player.doubleBonusActive
                        ? AppColors.neonGreen
                        : AppColors.goldText,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),

        // Ses Butonu
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          icon: Icon(
            player.soundEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.white70,
            size: 17,
          ),
          onPressed: () {
            ref.read(gameNotifierProvider.notifier).toggleSound();
          },
        ),
      ],
    );
  }

  Widget _buildCenterSection(BuildContext context, GridModel grid, PlayerStateModel player, GameState state) {
    if (state.gameMode == GameMode.solo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.7), width: 1),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.terrain, color: AppColors.neonGreen, size: 13),
              const SizedBox(width: 4),
              Text(
                'BÖLÜM ${grid.stage}/500 • ${grid.biomeName}',
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
              if (grid.enemies.isNotEmpty) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: grid.aliveEnemiesCount > 0 ? const Color(0xFF5C1010) : const Color(0xFF104A10),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: grid.aliveEnemiesCount > 0 ? const Color(0xFFFF5252) : AppColors.neonGreen,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    grid.aliveEnemiesCount > 0 ? '⚔️ ${grid.aliveEnemiesCount}' : '🏆 TEMİZ!',
                    style: TextStyle(
                      color: grid.aliveEnemiesCount > 0 ? const Color(0xFFFF8A80) : AppColors.neonGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              // 🔫 Mermi ve Aktif Silah Rozeti
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const WeaponShopScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: player.currentAmmo > 0 ? const Color(0xFF1E1038) : const Color(0xFF4A1010),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: player.currentAmmo > 0 ? const Color(0xFFE040FB) : Colors.redAccent,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${player.equippedWeapon.iconEmoji} ${player.currentAmmo}',
                    style: TextStyle(
                      color: player.currentAmmo > 0 ? const Color(0xFFEA80FC) : Colors.redAccent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final phase = state.battlePhase;
    final String phaseTitle = phase.isDeathmatch
        ? '⚔️ SERBEST DÖVÜŞ'
        : (phase.isCountdown ? '⏳ BAŞLIYOR' : '📦 HAZİNE AVI');
    final Color phaseColor = phase.isDeathmatch ? const Color(0xFFFF5252) : AppColors.goldText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F28),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: phaseColor.withValues(alpha: 0.7), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: phaseColor, size: 13),
          const SizedBox(width: 4),
          Text(
            '$phaseTitle (${phase.formattedTime})',
            style: TextStyle(
              color: phaseColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection(BuildContext context, WidgetRef ref, PlayerStateModel player) {
    final String earningsDisplay = player.lifetimeEarnings >= 1000
        ? '${(player.lifetimeEarnings / 1000).toStringAsFixed(1)}K'
        : '${player.lifetimeEarnings}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rütbe & Toplam
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rütbe ${player.rank}',
              style: const TextStyle(
                color: AppColors.goldText,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            Text(
              earningsDisplay,
              style: const TextStyle(
                color: Color(0xFFB0B0D0),
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),

        // Prestij Sıfırlama Butonu
        InkWell(
          onTap: () => _showResetDialog(context, ref, player),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.resetRed.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'SIFIRLA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),

        // 🛒 Mağaza Hızlı Erişim Butonu
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          icon: const Icon(Icons.shopping_cart, color: AppColors.goldText, size: 19),
          tooltip: 'Silah & Ekipman Mağazası',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const WeaponShopScreen()),
            );
          },
        ),
        const SizedBox(width: 2),

        // Günlük Görevler Butonu
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          icon: const Icon(Icons.assignment, color: AppColors.goldText, size: 19),
          tooltip: 'Günlük Görevler',
          onPressed: () => QuestDialog.showQuestDialog(context),
        ),

        // Kostümler Butonu
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          icon: const Icon(Icons.palette, color: Color(0xFFE040FB), size: 19),
          tooltip: 'Kostümler & Skinler',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const CosmeticsScreen()),
            );
          },
        ),
        const SizedBox(width: 2),

        // Ayarlar Butonu
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          icon: const Icon(Icons.settings, color: Colors.white70, size: 19),
          tooltip: 'Ayarlar',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, PlayerStateModel player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.hudPanel,
        title: const Text('Rütbe Sıfırlama (Prestij)'),
        content: Text(
          'Mevcut derinlik ve altınınız sıfırlanacak.\n'
          'Rütbeniz ${player.rank + 1} olacak ve kalıcı kazı bonusu kazanacaksınız.\n\n'
          'Devam etmek istiyor musunuz?',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.resetRed),
            onPressed: () {
              ref.read(gameNotifierProvider.notifier).prestigeReset();
              Navigator.pop(ctx);
            },
            child: const Text('SIFIRLA'),
          ),
        ],
      ),
    );
  }
}

