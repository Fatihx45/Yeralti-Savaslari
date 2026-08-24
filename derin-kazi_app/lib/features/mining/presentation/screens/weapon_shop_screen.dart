import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/game_notifier.dart';
import '../../domain/models/weapon_model.dart';
import '../../domain/models/tool_model.dart';
import 'forge_screen.dart';

class WeaponShopScreen extends ConsumerStatefulWidget {
  const WeaponShopScreen({super.key});

  @override
  ConsumerState<WeaponShopScreen> createState() => _WeaponShopScreenState();
}

class _WeaponShopScreenState extends ConsumerState<WeaponShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14142B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Text('🛒', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'MERKEZ CEPHANELİK & MAĞAZA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Text('⚡', style: TextStyle(fontSize: 16)),
            label: const Text(
              'GÜÇLENDİR',
              style: TextStyle(
                color: Color(0xFFE040FB),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const ForgeScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonGreen,
          indicatorWeight: 3,
          labelColor: AppColors.neonGreen,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Text('🔫'), text: 'SİLAHLAR'),
            Tab(icon: Text('⛏️'), text: 'ALETLER'),
            Tab(icon: Text('🎒'), text: 'CEPHANE & YÜKSELTME'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Üst Bakiye Bilgi Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F0F24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceChip('🟡', '${player.gold}', 'Altın', Colors.amber),
                _buildBalanceChip('💎', '${player.gems}', 'Elmas', Colors.cyanAccent),
                _buildBalanceChip('🔫', '${player.currentAmmo}', 'Mermi', Colors.orangeAccent),
                _buildBalanceChip('❤️', '${player.hp}/${player.maxHp}', 'Can', Colors.redAccent),
              ],
            ),
          ),

          // Son mesaj / bildirim
          if (gameState.lastMessage != null && gameState.lastMessage!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.neonGreen.withValues(alpha: 0.15),
              child: Text(
                gameState.lastMessage!,
                style: const TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),

          // Sekme İçerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWeaponsTab(player),
                _buildToolsTab(player),
                _buildUpgradesTab(player),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChip(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. SİLAHLAR SEKMESİ
  Widget _buildWeaponsTab(dynamic player) {
    final weapons = WeaponType.values;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: weapons.length,
      itemBuilder: (context, index) {
        final weapon = weapons[index];
        final bool isOwned = player.ownedWeapons.contains(weapon);
        final bool isEquipped = player.equippedWeapon == weapon;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16162E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEquipped
                  ? AppColors.neonGreen
                  : (isOwned ? Colors.blueGrey : const Color(0xFF2E2E54)),
              width: isEquipped ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Silah İkonu
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF222244),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEquipped ? AppColors.neonGreen : Colors.white24,
                  ),
                ),
                child: Center(
                  child: Text(weapon.iconEmoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),

              // Bilgiler
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
                            fontSize: 15,
                          ),
                        ),
                        if (isEquipped) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'KUŞANILDI',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weapon.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatBadge('⚔️ Hasar: ${weapon.damage}', Colors.redAccent),
                        const SizedBox(width: 6),
                        _buildStatBadge('📦 Blok Delme: ${weapon.tileDamage}', Colors.amberAccent),
                        const SizedBox(width: 6),
                        _buildStatBadge('🔫 Şarjör: ${weapon.maxAmmo}', Colors.lightBlueAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Satın Al / Kuşan Butonu
              ElevatedButton(
                onPressed: () {
                  if (isOwned) {
                    ref.read(gameNotifierProvider.notifier).equipWeapon(weapon);
                  } else {
                    ref.read(gameNotifierProvider.notifier).buyWeapon(weapon);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEquipped
                      ? Colors.grey.shade800
                      : (isOwned ? Colors.blue.shade700 : AppColors.neonGreen),
                  foregroundColor: (isOwned || isEquipped) ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isEquipped
                    ? const Text('KULLANILIYOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                    : (isOwned
                        ? const Text('KUŞAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('SATIN AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                              if (weapon.goldPrice > 0)
                                Text('${weapon.goldPrice} 🟡', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              if (weapon.gemPrice > 0)
                                Text('${weapon.gemPrice} 💎', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          )),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. MADEN ALETLERİ SEKMESİ
  Widget _buildToolsTab(dynamic player) {
    final tools = [
      (tool: ToolType.shovel, price: 300, desc: 'Toprak ve yumuşak zeminleri hızla kazar.'),
      (tool: ToolType.pickaxe, price: 600, desc: 'Sert kaya ve taş blokları kolayca kırar.'),
      (tool: ToolType.axe, price: 850, desc: 'Kökleri ve ahşap destekleri parçalar.'),
      (tool: ToolType.baseballBat, price: 1100, desc: 'Ağır darbe vurur ve düşmanları sarsar.'),
      (tool: ToolType.diamondPick, price: 2000, desc: 'En sert obsidyen ve elmas blokları deler.'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final item = tools[index];
        final tool = item.tool;
        final bool isOwned = player.inventoryTools.contains(tool);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16162E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOwned ? AppColors.neonGreen.withValues(alpha: 0.5) : const Color(0xFF2E2E54),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF222244),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(tool.iconEmoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(item.desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatBadge('⛏️ Kazma Gücü: +${tool.tileDamage}', Colors.orangeAccent),
                        const SizedBox(width: 6),
                        _buildStatBadge('⚔️ Saldırı: +${tool.pvpDamage}', Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isOwned
                    ? null
                    : () {
                        ref.read(gameNotifierProvider.notifier).buyTool(tool, item.price);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwned ? Colors.grey.shade800 : AppColors.neonGreen,
                  foregroundColor: isOwned ? Colors.white60 : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isOwned
                    ? const Text('ENVANTERDE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('SATIN AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${item.price} 🟡', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. CEPHANE & YÜKSELTME SEKMESİ
  Widget _buildUpgradesTab(dynamic player) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 1. Tabanca Mermisi Paketi
        _buildUpgradeCard(
          emoji: '🔫',
          title: 'Tabanca Mermisi Paketi',
          desc: 'Standart 9mm tabanca mermisi (+15 Mermi ekler).',
          costText: '120 🟡',
          onBuy: () {
            ref.read(gameNotifierProvider.notifier).buyAmmopack(15, 120);
          },
        ),

        // 2. Tüfek Mermisi Kasası
        _buildUpgradeCard(
          emoji: '⚡🔫',
          title: 'Tüfek Yüksek Kalibre Mermisi',
          desc: 'Yüksek delici güce sahip tüfek mermisi şarjörü (+30 Mermi ekler).',
          costText: '220 🟡',
          onBuy: () {
            ref.read(gameNotifierProvider.notifier).buyAmmopack(30, 220);
          },
        ),

        // 3. Pompalı Saçma Fişeği
        _buildUpgradeCard(
          emoji: '💥',
          title: 'Pompalı Saçma Fişekleri',
          desc: 'Geniş saçılımlı ağır av fişeği paketi (+20 Mermi ekler).',
          costText: '280 🟡',
          onBuy: () {
            ref.read(gameNotifierProvider.notifier).buyAmmopack(20, 280);
          },
        ),

        // 4. Ağır Roket & Lazer Hücresi
        _buildUpgradeCard(
          emoji: '🚀',
          title: 'Roket & Lazer Enerji Paketi',
          desc: 'Yıkıcı patlayıcı roketler ve lazer hücreleri (+10 Mermi ekler).',
          costText: '380 🟡',
          onBuy: () {
            ref.read(gameNotifierProvider.notifier).buyAmmopack(10, 380);
          },
        ),

        // 5. Envanter Genişletme
        _buildUpgradeCard(
          emoji: '🎒',
          title: 'Envanter Çantası Genişletme',
          desc: 'Envanter yuva kapasitesini +2 Slot artırır (Mevcut: ${player.maxInventorySlots}/12 Slot).',
          costText: '750 🟡',
          isMax: player.maxInventorySlots >= 12,
          onBuy: () {
            ref.read(gameNotifierProvider.notifier).buyInventorySlotExpansion();
          },
        ),

        // 6. Çelik Zırh
        _buildUpgradeCard(
          emoji: '🛡️',
          title: 'Titanyum Madenci Zırhı',
          desc: 'Maksimum Can kapasitenizi kalıcı olarak +30 Can artırır.',
          costText: '600 🟡',
          onBuy: () {
            ref.read(gameNotifierProvider.notifier).buyShieldUpgrade();
          },
        ),
      ],
    );
  }

  Widget _buildUpgradeCard({
    required String emoji,
    required String title,
    required String desc,
    required String costText,
    required VoidCallback onBuy,
    bool isMax = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16162E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E54)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF222244),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isMax ? null : onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: isMax ? Colors.grey.shade800 : AppColors.neonGreen,
              foregroundColor: isMax ? Colors.white60 : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: isMax
                ? const Text('MAKSİMUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(costText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
