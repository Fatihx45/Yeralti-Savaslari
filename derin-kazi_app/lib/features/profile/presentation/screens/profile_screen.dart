import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/domain/models/player_state_model.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';

class BadgeItem {
  final String id;
  final String title;
  final String desc;
  final String icon;
  final int rewardGems;
  final String category;
  final int targetValue;
  final int Function(GameState) getCurrentValue;
  final bool Function(GameState) isUnlocked;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.rewardGems,
    required this.category,
    required this.targetValue,
    required this.getCurrentValue,
    required this.isUnlocked,
  });
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedCategory = 'TÜMÜ';

  final List<BadgeItem> _allBadges = [
    // ⛏️ 1. KAZI & MADEN ROZETLERİ
    BadgeItem(
      id: 'ach_first_dig',
      title: 'Acemi Kazıcı',
      desc: 'Yeraltında ilk kutunu kaz',
      icon: '⛏️',
      rewardGems: 5,
      category: 'KAZI',
      targetValue: 1,
      getCurrentValue: (state) => state.player.tilesBrokenTotal.clamp(0, 1),
      isUnlocked: (state) => state.player.tilesBrokenTotal >= 1,
    ),
    BadgeItem(
      id: 'ach_tiles_50',
      title: 'Kaya Parçalayan',
      desc: 'Toplam 50 kutu kır',
      icon: '🧱',
      rewardGems: 15,
      category: 'KAZI',
      targetValue: 50,
      getCurrentValue: (state) => state.player.tilesBrokenTotal.clamp(0, 50),
      isUnlocked: (state) => state.player.tilesBrokenTotal >= 50,
    ),
    BadgeItem(
      id: 'ach_tiles_200',
      title: 'Derin Maden Fatihi',
      desc: 'Toplam 200 kutu kazarak derinliklere in',
      icon: '🌋',
      rewardGems: 30,
      category: 'KAZI',
      targetValue: 200,
      getCurrentValue: (state) => state.player.tilesBrokenTotal.clamp(0, 200),
      isUnlocked: (state) => state.player.tilesBrokenTotal >= 200,
    ),
    BadgeItem(
      id: 'ach_tnt_master',
      title: 'Dinamit & TNT Uzmanı',
      desc: 'En az 3 Boss veya zorlu katmanda patlayıcı kullan',
      icon: '🧨',
      rewardGems: 20,
      category: 'KAZI',
      targetValue: 3,
      getCurrentValue: (state) => state.player.bossesDefeatedTotal.clamp(0, 3),
      isUnlocked: (state) => state.player.bossesDefeatedTotal >= 1 || state.player.dynamites > 0,
    ),

    // 👑 2. BÖLÜM & BOSS ROZETLERİ
    BadgeItem(
      id: 'ach_stage_10',
      title: 'Mini-Boss Fatihi',
      desc: '10. Bölüm seviyesine ulaş',
      icon: '⚔️',
      rewardGems: 10,
      category: 'BOSS',
      targetValue: 10,
      getCurrentValue: (state) => state.player.unlockedStage.clamp(0, 10),
      isUnlocked: (state) => state.player.unlockedStage >= 10,
    ),
    BadgeItem(
      id: 'ach_stage_50',
      title: 'Kızıl Toprak Fatihi',
      desc: '50. Bölüm Kızıl Toprak Vadisi Bossunu yen',
      icon: '🏜️',
      rewardGems: 25,
      category: 'BOSS',
      targetValue: 50,
      getCurrentValue: (state) => state.player.unlockedStage.clamp(0, 50),
      isUnlocked: (state) => state.player.unlockedStage >= 50,
    ),
    BadgeItem(
      id: 'ach_stage_100',
      title: 'Bakır Ustası',
      desc: '100. Bölüm Bakır Yamaçları seviyesine ulaş',
      icon: '🟤',
      rewardGems: 35,
      category: 'BOSS',
      targetValue: 100,
      getCurrentValue: (state) => state.player.unlockedStage.clamp(0, 100),
      isUnlocked: (state) => state.player.unlockedStage >= 100,
    ),
    BadgeItem(
      id: 'ach_stage_250',
      title: 'Zümrüt Kralı',
      desc: '250. Bölüm Zümrüt Mağaraları Bossunu yen',
      icon: '🟢',
      rewardGems: 50,
      category: 'BOSS',
      targetValue: 250,
      getCurrentValue: (state) => state.player.unlockedStage.clamp(0, 250),
      isUnlocked: (state) => state.player.unlockedStage >= 250,
    ),
    BadgeItem(
      id: 'ach_stage_500',
      title: 'BÜYÜK TİTAN FATİHİ',
      desc: '500. Bölüme ulaş ve efsanevi Titan Çekirdeğini yok et',
      icon: '👑',
      rewardGems: 100,
      category: 'BOSS',
      targetValue: 500,
      getCurrentValue: (state) => state.player.unlockedStage.clamp(0, 500),
      isUnlocked: (state) => state.player.unlockedStage >= 500,
    ),

    // 💎 3. SERVET & PRESTİJ ROZETLERİ
    BadgeItem(
      id: 'ach_gold_1000',
      title: 'Altın Avcısı',
      desc: 'Yaşam boyu en az 1.000 altın topla',
      icon: '🟡',
      rewardGems: 10,
      category: 'SERVET',
      targetValue: 1000,
      getCurrentValue: (state) => state.player.lifetimeEarnings.clamp(0, 1000),
      isUnlocked: (state) => state.player.lifetimeEarnings >= 1000,
    ),
    BadgeItem(
      id: 'ach_gold_10000',
      title: 'Milyoner Madenci',
      desc: 'Yaşam boyu 10.000 altın kazanca ulaş',
      icon: '💰',
      rewardGems: 30,
      category: 'SERVET',
      targetValue: 10000,
      getCurrentValue: (state) => state.player.lifetimeEarnings.clamp(0, 10000),
      isUnlocked: (state) => state.player.lifetimeEarnings >= 10000,
    ),
    BadgeItem(
      id: 'ach_gems_50',
      title: 'Elmas Koleksiyoneri',
      desc: 'Kasanda en az 25 elmas biriktir',
      icon: '💎',
      rewardGems: 20,
      category: 'SERVET',
      targetValue: 25,
      getCurrentValue: (state) => state.player.gems.clamp(0, 25),
      isUnlocked: (state) => state.player.gems >= 25,
    ),
    BadgeItem(
      id: 'ach_prestige_1',
      title: 'Kusursuz Prestij',
      desc: 'Rütbeni sıfırlayarak Prestij seviyesi kazan',
      icon: '⚡',
      rewardGems: 40,
      category: 'SERVET',
      targetValue: 2,
      getCurrentValue: (state) => state.player.rank.clamp(0, 2),
      isUnlocked: (state) => state.player.rank >= 2,
    ),

    // ⚔️ 4. SAVAŞ & EKİP ROZETLERİ
    BadgeItem(
      id: 'ach_br_warrior',
      title: 'Arena Savaşçısı',
      desc: 'Battle Royale veya Ekip Kazısı mücadelesine katıl',
      icon: '🛡️',
      rewardGems: 25,
      category: 'EKİP',
      targetValue: 1,
      getCurrentValue: (state) => 1,
      isUnlocked: (state) => true,
    ),
    BadgeItem(
      id: 'ach_friend_1',
      title: 'Sadık Takım Kaptanı',
      desc: 'Favori takımına en az 1 arkadaş ekle',
      icon: '👥',
      rewardGems: 15,
      category: 'EKİP',
      targetValue: 1,
      getCurrentValue: (state) => state.player.favoriteFriends.length.clamp(0, 1),
      isUnlocked: (state) => state.player.favoriteFriends.isNotEmpty,
    ),
  ];

  String _getRankTitle(int rank) {
    if (rank >= 5) return '👑 Efsanevi Titan Fatihi';
    if (rank >= 4) return '⚡ Usta Kazıcı';
    if (rank >= 3) return '⛏️ Kıdemli Madenci';
    if (rank >= 2) return '🛠️ Çırak Madenci';
    return '🌱 Acemi Madenci';
  }

  String _getSkinEmoji(String skinId) {
    switch (skinId) {
      case 'gold_knight':
        return '🛡️';
      case 'lava_miner':
        return '🔥';
      case 'emerald_guardian':
        return '🟢';
      case 'crystal_lord':
        return '💎';
      default:
        return '👷';
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16163C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.goldText, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.badge, color: AppColors.goldText, size: 22),
            SizedBox(width: 8),
            Text(
              'Madenci Adını Değiştir',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeni kullanıcı adınız tüm oyunda ve ekip odalarında görünecektir:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Örn: EfsaneMadenci',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.person, color: AppColors.goldText, size: 20),
                filled: true,
                fillColor: const Color(0xFF0C0C22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2C2C64)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.check, size: 18, color: Colors.black),
            label: const Text('KAYDET', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(gameNotifierProvider.notifier).setPlayerName(newName);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;
    final showcaseIds = player.showcaseBadgeIds;

    final filteredBadges = _selectedCategory == 'TÜMÜ'
        ? _allBadges
        : _allBadges.where((b) => b.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. ÜST BAŞLIK & BAKİYE ÇUBUĞU
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                border: Border(bottom: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/image/logo.jpg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MADENCİ PROFİLİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),

                  // Altın & Elmas Bakiyesi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panelBox,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4A2518)),
                    ),
                    child: Row(
                      children: [
                        Text('💎 ${player.gems}', style: const TextStyle(color: AppColors.cyanText, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('🟡 ${player.gold}', style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. ANA İÇERİK (KAYDIRILABİLİR)
            // ==========================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // MADENCİ KİMLİK KARTI & VİTRİN
                  _buildMinerIdCard(context, player, showcaseIds),
                  const SizedBox(height: 12),

                  // KARİYER İSTATİSTİKLERİ ŞERİDİ
                  _buildCareerStatsBar(player, gameState),
                  const SizedBox(height: 14),

                  // KATEGORİ SEÇİCİ FİLTRELERİ
                  _buildCategoryFilter(),
                  const SizedBox(height: 10),

                  // ROZETLER IZGARASI / LİSTESİ
                  ...filteredBadges.map((badge) => _buildBadgeCard(badge, gameState, showcaseIds)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🪪 MADENCİ KİMLİK KARTI & VİTRİN BİLEŞENİ
  // ==========================================
  Widget _buildMinerIdCard(BuildContext context, PlayerStateModel player, List<String> showcaseIds) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF161642), Color(0xFF0F0F2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldText.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CosmeticsScreen()));
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C22),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonGreen, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(_getSkinEmoji(player.equippedSkinId), style: const TextStyle(fontSize: 30)),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // İsim, Düzenle Butonu ve Rütbe
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // İSİM DÜZENLEME BUTONU
                        InkWell(
                          onTap: () => _showEditNameDialog(context, player.playerName),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.goldText.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.goldText, width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: AppColors.goldText, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'DÜZENLE',
                                  style: TextStyle(
                                    color: AppColors.goldText,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getRankTitle(player.rank),
                          style: const TextStyle(color: AppColors.goldText, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        // #TAG ve Kopyala Çipi
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: player.playerTag));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Oyuncu etiketiniz panoya kopyalandı!')),
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.panelBox,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  player.playerTag,
                                  style: const TextStyle(color: AppColors.goldText, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.copy, size: 11, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF28285C), height: 1),
          const SizedBox(height: 10),

          // 🎖️ 3'LÜ VİTRİN ROZETLERİ (SHOWCASE SLOTS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.stars, color: AppColors.goldText, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'VİTRİN ROZETLERİ (MAX 3):',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${showcaseIds.length} / 3 Kuşanıldı',
                style: const TextStyle(color: AppColors.goldText, fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3 Yuva
          Row(
            children: List.generate(3, (index) {
              final String? badgeId = index < showcaseIds.length ? showcaseIds[index] : null;
              final BadgeItem? badge = badgeId != null ? _allBadges.firstWhere((b) => b.id == badgeId, orElse: () => _allBadges.first) : null;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: badge != null ? const Color(0xFF1E1E4E) : const Color(0xFF0D0D24),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: badge != null ? AppColors.goldText : const Color(0xFF282858),
                      width: badge != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: badge != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(badge.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            '+ Boş Yuva',
                            style: TextStyle(color: Colors.white30, fontSize: 10, fontStyle: FontStyle.italic),
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

  // ==========================================
  // 📊 KARİYER İSTATİSTİKLERİ ŞERİDİ
  // ==========================================
  Widget _buildCareerStatsBar(PlayerStateModel player, GameState state) {
    int totalClaimed = 0;
    for (final b in _allBadges) {
      if (player.achievementIds.contains(b.id)) totalClaimed++;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121236),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252558)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat('KAZILAN KUTU', '${player.tilesBrokenTotal}', Icons.grid_view, const Color(0xFF4FC3F7)),
          _buildStatDivider(),
          _buildMiniStat('BÖLÜM', '${player.unlockedStage}/500', Icons.terrain, AppColors.neonGreen),
          _buildStatDivider(),
          _buildMiniStat('BOSS ZAFERİ', '${player.bossesDefeatedTotal}', Icons.military_tech, const Color(0xFFFF5252)),
          _buildStatDivider(),
          _buildMiniStat('ROZETLER', '$totalClaimed/${_allBadges.length}', Icons.emoji_events, AppColors.goldText),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 24, color: const Color(0xFF252558));
  }

  // ==========================================
  // 🏷️ KATEGORİ SEÇİCİ
  // ==========================================
  Widget _buildCategoryFilter() {
    final categories = ['TÜMÜ', 'KAZI', 'BOSS', 'SERVET', 'EKİP'];

    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.goldText : const Color(0xFF141438),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.goldText : const Color(0xFF2C2C64),
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 🏅 ROZET KARTI BİLEŞENİ
  // ==========================================
  Widget _buildBadgeCard(BadgeItem badge, GameState gameState, List<String> showcaseIds) {
    final bool isClaimed = gameState.player.achievementIds.contains(badge.id);
    final bool isReadyToClaim = !isClaimed && badge.isUnlocked(gameState);
    final bool isInShowcase = showcaseIds.contains(badge.id);

    final int currentVal = badge.getCurrentValue(gameState);
    final double progress = (currentVal / badge.targetValue).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131336),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClaimed
              ? (isInShowcase ? AppColors.goldText : const Color(0xFF2E2E66))
              : (isReadyToClaim ? AppColors.neonGreen : const Color(0xFF1E1E46)),
          width: isReadyToClaim || isInShowcase ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rozet İkonu & Çerçevesi
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isClaimed || isReadyToClaim ? AppColors.goldText : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(fontSize: 22, color: isClaimed || isReadyToClaim ? null : Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Başlık, Açıklama ve İlerleme Barı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      badge.title,
                      style: TextStyle(
                        color: isClaimed || isReadyToClaim ? Colors.white : Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${badge.rewardGems} 💎',
                      style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  badge.desc,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                const SizedBox(height: 6),

                // İlerleme Barı
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF0A0A1C),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isClaimed ? AppColors.neonGreen : (isReadyToClaim ? AppColors.neonGreen : AppColors.goldText),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$currentVal / ${badge.targetValue}',
                    style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Aksiyon Butonları
          if (isReadyToClaim)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ref.read(gameNotifierProvider.notifier).claimAchievement(badge.id, badge.rewardGems);
              },
              child: const Text('💎 AL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            )
          else if (isClaimed)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: isInShowcase ? AppColors.goldText : Colors.white70,
                side: BorderSide(color: isInShowcase ? AppColors.goldText : const Color(0xFF383870)),
                backgroundColor: isInShowcase ? AppColors.goldText.withValues(alpha: 0.15) : null,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ref.read(gameNotifierProvider.notifier).toggleShowcaseBadge(badge.id);
              },
              child: Text(
                isInShowcase ? '⭐ VİTRİNDE' : '+ VİTRİNE TAK',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E26),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 11, color: Colors.white30),
                  SizedBox(width: 4),
                  Text('KİLİTLİ', style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
