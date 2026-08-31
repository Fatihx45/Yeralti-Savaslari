import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/game_notifier.dart';
import '../../domain/models/weapon_model.dart';
import '../../domain/models/tool_model.dart';

class ForgeScreen extends ConsumerStatefulWidget {
  const ForgeScreen({super.key});

  @override
  ConsumerState<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends ConsumerState<ForgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.hudPanel,
        elevation: 0,
        toolbarHeight: 44,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Text('⚡', style: TextStyle(fontSize: 18)),
            SizedBox(width: 6),
            Text(
              'MADENCİ ATÖLYESİ & GÜÇLENDİRME',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.lavaOrange,
          indicatorWeight: 2.5,
          labelColor: AppColors.lavaOrange,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
          tabs: const [
            Tab(height: 38, icon: Text('🔫', style: TextStyle(fontSize: 13)), text: 'SİLAH GÜÇLENDİRME'),
            Tab(height: 38, icon: Text('⛏️', style: TextStyle(fontSize: 13)), text: 'ALET DÖVME'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Üst Maden Stoğu Paneli
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: AppColors.hudPanel,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildOreChip('🟡', '${player.gold}', 'Altın', Colors.amber),
                  const SizedBox(width: 5),
                  _buildOreChip('💎', '${player.gems}', 'Elmas', Colors.cyanAccent),
                  const SizedBox(width: 5),
                  _buildOreChip('🟤', '${player.copper}', 'Bakır', Colors.orangeAccent),
                  const SizedBox(width: 5),
                  _buildOreChip('⚪', '${player.iron}', 'Demir', Colors.blueGrey.shade100),
                  const SizedBox(width: 5),
                  _buildOreChip('🟢', '${player.emeralds}', 'Zümrüt', Colors.greenAccent),
                  const SizedBox(width: 5),
                  _buildOreChip('🦴', '${player.fossils}', 'Fosil', Colors.purpleAccent),
                ],
              ),
            ),
          ),

          // Son mesaj / bildirim
          if (gameState.lastMessage != null && gameState.lastMessage!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: AppColors.goldText.withValues(alpha: 0.15),
              child: Text(
                gameState.lastMessage!,
                style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),

          // Sekmeler
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWeaponForgeTab(player),
                _buildToolForgeTab(player),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOreChip(String emoji, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1738),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            '$count $label',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // 1. SİLAH GÜÇLENDİRME SEKMESİ
  Widget _buildWeaponForgeTab(dynamic player) {
    final weapons = WeaponType.values;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: weapons.length,
      itemBuilder: (context, index) {
        final weapon = weapons[index];
        final bool isOwned = player.ownedWeapons.contains(weapon);
        final int currentLvl = player.getWeaponLevel(weapon);
        final bool isMax = currentLvl >= 5;

        final curDmg = player.getWeaponDamage(weapon);
        final nextDmg = curDmg + 12;
        final curTileDmg = player.getWeaponTileDamage(weapon);
        final nextTileDmg = curTileDmg + 6;
        final curAmmo = player.getWeaponMaxAmmo(weapon);
        final nextAmmo = curAmmo + 3;

        // Gereksinimler
        int reqGold = 300;
        int reqCopper = 0;
        int reqIron = 0;
        int reqEmerald = 0;
        int reqFossil = 0;
        int reqGem = 0;

        switch (currentLvl) {
          case 1:
            reqGold = 300;
            reqCopper = 3;
            break;
          case 2:
            reqGold = 700;
            reqCopper = 5;
            reqIron = 3;
            break;
          case 3:
            reqGold = 1500;
            reqIron = 5;
            reqEmerald = 2;
            reqGem = 2;
            break;
          case 4:
            reqGold = 3200;
            reqEmerald = 4;
            reqFossil = 1;
            reqGem = 6;
            break;
        }

        final bool canAfford = !isMax &&
            player.gold >= reqGold &&
            player.copper >= reqCopper &&
            player.iron >= reqIron &&
            player.emeralds >= reqEmerald &&
            player.fossils >= reqFossil &&
            player.gems >= reqGem;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF181432),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMax
                  ? AppColors.goldText
                  : (isOwned ? const Color(0xFF3E3668) : Colors.white12),
              width: isMax ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık Satırı: İkon, İsim, Seviye Yıldızları
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF261F48),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(weapon.iconEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              weapon.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isMax ? AppColors.goldText : const Color(0xFF2E2458),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                isMax ? '⭐ LV.5' : 'SEVİYE $currentLvl/5',
                                style: TextStyle(
                                  color: isMax ? Colors.black : AppColors.goldText,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        // Yıldız göstergesi
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 11,
                              color: i < currentLvl ? AppColors.goldText : Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Stat Karşılaştırma Paneli
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF100D24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatUpgrade(
                      'Hasar',
                      '$curDmg',
                      isMax ? null : '$nextDmg',
                      Colors.redAccent,
                    ),
                    _buildStatUpgrade(
                      'Blok Delme',
                      '$curTileDmg',
                      isMax ? null : '$nextTileDmg',
                      Colors.amberAccent,
                    ),
                    _buildStatUpgrade(
                      'Şarjör',
                      '$curAmmo',
                      isMax ? null : '$nextAmmo',
                      Colors.lightBlueAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Gereken Madenler & Güçlendir Butonu
              if (!isMax) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: [
                    _buildReqBadge('🟡', '$reqGold', player.gold >= reqGold),
                    if (reqCopper > 0)
                      _buildReqBadge('🟤 $reqCopper Bakır', '', player.copper >= reqCopper),
                    if (reqIron > 0)
                      _buildReqBadge('⚪ $reqIron Demir', '', player.iron >= reqIron),
                    if (reqEmerald > 0)
                      _buildReqBadge('🟢 $reqEmerald Zümrüt', '', player.emeralds >= reqEmerald),
                    if (reqFossil > 0)
                      _buildReqBadge('🦴 $reqFossil Fosil', '', player.fossils >= reqFossil),
                    if (reqGem > 0)
                      _buildReqBadge('💎 $reqGem Elmas', '', player.gems >= reqGem),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // Eylem Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!isOwned || isMax || !canAfford)
                      ? null
                      : () {
                          ref.read(gameNotifierProvider.notifier).upgradeWeapon(weapon);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMax
                        ? Colors.grey.shade800
                        : (canAfford ? const Color(0xFFFF9100) : Colors.grey.shade800),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(double.infinity, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    !isOwned
                        ? 'ÖNCE MAĞAZADAN SATIN ALIN'
                        : (isMax
                            ? 'MAKSİMUM GÜÇTE ⭐'
                            : (canAfford ? '🔨 GÜÇLENDİR (SEVİYE ${currentLvl + 1})' : 'YETERSİZ MADEN')),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                      color: (!isOwned || isMax || !canAfford) ? Colors.white54 : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. ALET DÖVME SEKMESİ
  Widget _buildToolForgeTab(dynamic player) {
    final tools = [
      ToolType.shovel,
      ToolType.pickaxe,
      ToolType.axe,
      ToolType.baseballBat,
      ToolType.diamondPick,
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        final bool isOwned = player.inventoryTools.contains(tool);
        final int currentLvl = player.getToolLevel(tool);
        final bool isMax = currentLvl >= 5;

        final curDmg = player.getToolTileDamage(tool);
        final nextDmg = curDmg + 4;
        final curPvp = player.getToolPvpDamage(tool);
        final nextPvp = curPvp + 6;

        // Gereksinimler
        int reqGold = 250;
        int reqCopper = 0;
        int reqIron = 0;
        int reqEmerald = 0;
        int reqGem = 0;

        switch (currentLvl) {
          case 1:
            reqGold = 250;
            reqCopper = 2;
            break;
          case 2:
            reqGold = 550;
            reqCopper = 4;
            reqIron = 2;
            break;
          case 3:
            reqGold = 1100;
            reqIron = 4;
            reqEmerald = 2;
            reqGem = 1;
            break;
          case 4:
            reqGold = 2400;
            reqEmerald = 3;
            reqGem = 4;
            break;
        }

        final bool canAfford = !isMax &&
            player.gold >= reqGold &&
            player.copper >= reqCopper &&
            player.iron >= reqIron &&
            player.emeralds >= reqEmerald &&
            player.gems >= reqGem;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF181432),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMax
                  ? AppColors.neonGreen
                  : (isOwned ? const Color(0xFF3E3668) : Colors.white12),
              width: isMax ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF261F48),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(tool.iconEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tool.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isMax ? AppColors.neonGreen : const Color(0xFF2E2458),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                isMax ? '⭐ LV.5' : 'SEVİYE $currentLvl/5',
                                style: TextStyle(
                                  color: isMax ? Colors.black : AppColors.neonGreen,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 11,
                              color: i < currentLvl ? AppColors.neonGreen : Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Statlar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF100D24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatUpgrade(
                      'Kazma Gücü',
                      '+$curDmg',
                      isMax ? null : '+$nextDmg',
                      Colors.orangeAccent,
                    ),
                    _buildStatUpgrade(
                      'Saldırı Gücü',
                      '+$curPvp',
                      isMax ? null : '+$nextPvp',
                      Colors.redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Gereksinimler
              if (!isMax) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: [
                    _buildReqBadge('🟡', '$reqGold', player.gold >= reqGold),
                    if (reqCopper > 0)
                      _buildReqBadge('🟤 $reqCopper Bakır', '', player.copper >= reqCopper),
                    if (reqIron > 0)
                      _buildReqBadge('⚪ $reqIron Demir', '', player.iron >= reqIron),
                    if (reqEmerald > 0)
                      _buildReqBadge('🟢 $reqEmerald Zümrüt', '', player.emeralds >= reqEmerald),
                    if (reqGem > 0)
                      _buildReqBadge('💎 $reqGem Elmas', '', player.gems >= reqGem),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // Buton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!isOwned || isMax || !canAfford)
                      ? null
                      : () {
                          ref.read(gameNotifierProvider.notifier).upgradeTool(tool);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMax
                        ? Colors.grey.shade800
                        : (canAfford ? AppColors.neonGreen : Colors.grey.shade800),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(double.infinity, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    !isOwned
                        ? 'ÖNCE MAĞAZADAN ALIN'
                        : (isMax
                            ? 'MAKSİMUM SEVİYE ⭐'
                            : (canAfford ? '🔨 DÖV (SEVİYE ${currentLvl + 1})' : 'YETERSİZ MADEN')),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                      color: (!isOwned || isMax || !canAfford) ? Colors.white54 : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatUpgrade(String label, String current, String? next, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
        const SizedBox(height: 1),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11.5)),
            if (next != null) ...[
              const Icon(Icons.arrow_forward, size: 10, color: Colors.white54),
              Text(next, style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.w900, fontSize: 11.5)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildReqBadge(String iconText, String countText, bool isEnough) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isEnough ? const Color(0xFF132E18) : const Color(0xFF381212),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isEnough ? AppColors.neonGreen.withValues(alpha: 0.6) : Colors.redAccent.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$iconText $countText',
            style: TextStyle(
              color: isEnough ? Colors.white : Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            isEnough ? Icons.check_circle : Icons.cancel,
            size: 9.5,
            color: isEnough ? AppColors.neonGreen : Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
