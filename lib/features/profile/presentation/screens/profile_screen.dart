import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../mining/domain/models/player_state_model.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';
import '../../../multiplayer/presentation/screens/create_room_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 'ach_first_dig',
      'title': 'İlk Kazı',
      'desc': 'Yeraltında ilk kutunu kaz',
      'icon': '⛏️',
      'reward': 5,
      'check': (GameState state) => state.player.tilesBrokenTotal >= 1,
    },
    {
      'id': 'ach_stage_10',
      'title': 'Mini-Boss Fatihi',
      'desc': '10. Bölüm Mini-Boss seviyesine ulaş',
      'icon': '⚔️',
      'reward': 10,
      'check': (GameState state) => state.player.unlockedStage >= 10,
    },
    {
      'id': 'ach_stage_50',
      'title': 'Kızıl Toprak Fatihi',
      'desc': '50. Bölüm Kızıl Toprak Vadisi Bossunu yen',
      'icon': '🏆',
      'reward': 25,
      'check': (GameState state) => state.player.unlockedStage >= 50,
    },
    {
      'id': 'ach_stage_100',
      'title': 'Bakır Ustası',
      'desc': '100. Bölüm seviyesine ulaş',
      'icon': '🟤',
      'reward': 30,
      'check': (GameState state) => state.player.unlockedStage >= 100,
    },
    {
      'id': 'ach_stage_250',
      'title': 'Zümrüt Kralı',
      'desc': '250. Bölüm Zümrüt Mağaraları Bossunu yen',
      'icon': '🟢',
      'reward': 50,
      'check': (GameState state) => state.player.unlockedStage >= 250,
    },
    {
      'id': 'ach_stage_500',
      'title': 'BÜYÜK TİTAN FATİHİ',
      'desc': '500. Bölüme ulaş ve efsanevi Titan Çekirdeğini yok et',
      'icon': '👑',
      'reward': 100,
      'check': (GameState state) => state.player.unlockedStage >= 500,
    },
    {
      'id': 'ach_tiles_100',
      'title': 'Çalışkan Madenci',
      'desc': 'Toplam 100 kutu kır',
      'icon': '🧱',
      'reward': 15,
      'check': (GameState state) => state.player.tilesBrokenTotal >= 100,
    },
    {
      'id': 'ach_boss_3',
      'title': 'Boss Avcısı',
      'desc': 'Toplam 3 Boss çekirdeği yok et',
      'icon': '👹',
      'reward': 35,
      'check': (GameState state) => state.player.bossesDefeatedTotal >= 3,
    },
    {
      'id': 'ach_friend_1',
      'title': 'Ekip Madencisi',
      'desc': 'Favorilerine en az 1 arkadaş ekle',
      'icon': '👥',
      'reward': 10,
      'check': (GameState state) => state.player.favoriteFriends.isNotEmpty,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getRankTitle(int rank) {
    if (rank >= 5) return '👑 Efsanevi Titan Fatihi';
    if (rank >= 4) return '⚡ Usta Kazıcı';
    if (rank >= 3) return '⛏️ Kıdemli Madenci';
    if (rank >= 2) return '🛠️ Çırak Madenci';
    return '🌱 Acemi Madenci';
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141438),
        title: const Text('Madenci Adını Düzenle', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Yeni adınızı girin',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0A0A1C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(gameNotifierProvider.notifier).setPlayerName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141438),
        title: const Text('Favori Arkadaş Ekle', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Arkadaşının madenci adı',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0A0A1C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldText, foregroundColor: Colors.black),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(gameNotifierProvider.notifier).addFavoriteFriend(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;

    return Scaffold(
      backgroundColor: const Color(0xFF090918),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Profil Kartı (Header)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF121232),
                border: Border(bottom: BorderSide(color: AppColors.goldText.withValues(alpha: 0.4), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),

                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E48),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonGreen, width: 2),
                    ),
                    child: const Center(
                      child: Text('⛏️', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // İsim & Rütbe
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              player.playerName,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.goldText, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showEditNameDialog(context, player.playerName),
                            ),
                          ],
                        ),
                        Text(
                          _getRankTitle(player.rank),
                          style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Bakiye Rozetleri
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A1C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2E2E68)),
                    ),
                    child: Row(
                      children: [
                        Text('💎 ${player.gems}', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('🟡 ${player.gold}', style: const TextStyle(color: AppColors.goldText, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Sekme Başlıkları (TabBar)
            Container(
              color: const Color(0xFF0F0F28),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.goldText,
                indicatorWeight: 3,
                labelColor: AppColors.goldText,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                tabs: const [
                  Tab(icon: Icon(Icons.analytics, size: 16), text: 'İSTATİSTİK'),
                  Tab(icon: Icon(Icons.emoji_events, size: 16), text: 'BAŞARIMLAR'),
                  Tab(icon: Icon(Icons.palette, size: 16), text: 'VİTRİN'),
                  Tab(icon: Icon(Icons.people, size: 16), text: 'ARKADAŞLAR'),
                ],
              ),
            ),

            // 3. Sekme İçerikleri
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatisticsTab(player),
                  _buildAchievementsTab(gameState),
                  _buildShowcaseTab(context, player),
                  _buildFriendsTab(context, player),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. İstatistikler Sekmesi
  Widget _buildStatisticsTab(PlayerStateModel player) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('En Yüksek Bölüm', 'Bölüm ${player.unlockedStage} / 500', Icons.terrain, AppColors.neonGreen),
        _buildStatCard('Toplam Yaşam Boyu Kazanç', '${player.lifetimeEarnings} 🟡 Altın', Icons.monetization_on, AppColors.goldText),
        _buildStatCard('Toplam Kazılan Kutu', '${player.tilesBrokenTotal} Kutu', Icons.grid_view, const Color(0xFF4FC3F7)),
        _buildStatCard('Yenilen Boss Sayısı', '${player.bossesDefeatedTotal} Boss', Icons.military_tech, const Color(0xFFFF5252)),
        _buildStatCard('Maden Rütbesi', 'Seviye ${player.rank}', Icons.workspace_premium, const Color(0xFFE040FB)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141436),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 2. Başarımlar Sekmesi
  Widget _buildAchievementsTab(GameState gameState) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final ach = _achievements[index];
        final String id = ach['id'] as String;
        final bool isClaimed = gameState.player.achievementIds.contains(id);
        final bool canClaim = !isClaimed && (ach['check'] as bool Function(GameState))(gameState);
        final int reward = ach['reward'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141436),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isClaimed
                  ? Colors.white24
                  : (canClaim ? AppColors.neonGreen : const Color(0xFF2C2C64)),
              width: canClaim ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Text(ach['icon'] as String, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ach['title'] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach['desc'] as String,
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (isClaimed)
                const Chip(
                  label: Text('KAZANILDI', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                  backgroundColor: Color(0xFF1E1E44),
                )
              else if (canClaim)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {
                    ref.read(gameNotifierProvider.notifier).claimAchievement(id, reward);
                  },
                  child: Text('AL (+$reward 💎)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text('+$reward 💎', style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }

  // 3. Kozmetik Vitrini Sekmesi
  Widget _buildShowcaseTab(BuildContext context, PlayerStateModel player) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141436),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE040FB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFFE040FB), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kuşanılan Kostüm', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text(player.equippedSkinId.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE040FB), foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CosmeticsScreen()));
                  },
                  child: const Text('MAĞAZAYA GİT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Alet Koleksiyonu', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildToolBadge('Tahta Kazma', '⛏️', true),
                _buildToolBadge('Demir Kazma', '🔨', true),
                _buildToolBadge('Altın Kazma', '⛏️', player.rank >= 2),
                _buildToolBadge('Elmas Kazma', '💎', player.rank >= 3),
                _buildToolBadge('Titan Balyozu', '⚡', player.rank >= 4),
                _buildToolBadge('Kaos Kazması', '👑', player.unlockedStage >= 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBadge(String name, String icon, bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF171740) : const Color(0xFF0C0C20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: unlocked ? AppColors.goldText : Colors.white12),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 16, color: unlocked ? null : Colors.white24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white30,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!unlocked) const Icon(Icons.lock, size: 12, color: Colors.white24),
        ],
      ),
    );
  }

  // 4. Sosyal / Arkadaşlar Sekmesi
  Widget _buildFriendsTab(BuildContext context, PlayerStateModel player) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Favori Arkadaşlar (${player.favoriteFriends.length})', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldText, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size.zero),
                icon: const Icon(Icons.person_add, size: 14, color: Colors.black),
                label: const Text('ARKADAŞ EKLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                onPressed: () => _showAddFriendDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: player.favoriteFriends.isEmpty
                ? const Center(
                    child: Text('Henüz favori arkadaş eklemediniz.\n"ARKADAŞ EKLE" butonundan ekleyebilirsiniz!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
                  )
                : ListView.builder(
                    itemCount: player.favoriteFriends.length,
                    itemBuilder: (context, index) {
                      final friend = player.favoriteFriends[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141436),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2C2C64)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle, color: AppColors.goldText, size: 24),
                            const SizedBox(width: 10),
                            Expanded(child: Text(friend, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                            IconButton(
                              icon: const Icon(Icons.group_add, color: AppColors.neonGreen, size: 18),
                              tooltip: 'Odaya Davet Et',
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CreateRoomScreen()));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
                              onPressed: () {
                                ref.read(gameNotifierProvider.notifier).removeFavoriteFriend(friend);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
