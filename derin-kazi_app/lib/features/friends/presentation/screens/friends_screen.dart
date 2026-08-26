import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../domain/models/friend_model.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';
import '../../../multiplayer/presentation/screens/create_room_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFriendProfileModal(BuildContext context, FriendModel friend) {
    final skin = availableSkins.firstWhere(
      (s) => s.id == friend.equippedSkinId,
      orElse: () => availableSkins.first,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Avatar ve İsim
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E48),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldText, width: 2),
                  ),
                  child: Center(
                    child: Text(skin.iconEmoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            friend.name,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            friend.playerTag,
                            style: const TextStyle(color: AppColors.goldText, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.status.displayName,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // İstatistik Kartları
            Row(
              children: [
                _buildModalStat('🏆 Kupa', '${friend.trophies}', AppColors.goldText),
                const SizedBox(width: 8),
                _buildModalStat('⛏️ Bölüm', '${friend.stage}', AppColors.neonGreen),
                const SizedBox(width: 8),
                _buildModalStat('👹 Canavar', '${friend.enemiesKilled}', const Color(0xFFFF5252)),
              ],
            ),
            const SizedBox(height: 20),
            // Aksiyon Butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldText,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const CreateRoomScreen()),
                      );
                    },
                    icon: const Icon(Icons.videogame_asset, size: 18),
                    label: const Text('Odaya Çağır / Oyna', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.person_remove, color: Color(0xFFFF5252)),
                  onPressed: () {
                    ref.read(gameNotifierProvider.notifier).removeFriend(friend.uid);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${friend.name} arkadaş listenizden çıkarıldı.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF181840),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final player = gameState.player;
    final notifier = ref.read(gameNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Başlık & Profil Etiketi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                border: Border(bottom: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.people_alt, color: AppColors.lavaOrange, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'SOSYAL & ARKADAŞLAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  // Oyuncu Etiket Çipi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panelBox,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldText.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'ID: ${player.playerTag}',
                          style: const TextStyle(color: AppColors.goldText, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: player.playerTag));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Oyuncu etiketiniz panoya kopyalandı!')),
                            );
                          },
                          child: const Icon(Icons.copy, size: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Sekmeler (Tabs)
            Container(
              color: AppColors.hudPanel,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.lavaOrange,
                indicatorWeight: 3,
                labelColor: AppColors.lavaOrange,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'ARKADAŞLAR (${player.friends.length})'),
                  const Tab(text: '🔍 ARA / EKLE'),
                  Tab(text: 'İSTEKLER (${player.friendRequests.length})'),
                ],
              ),
            ),

            // 3. Sekme İçerikleri
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // SEKME 1: ARKADAŞ LİSTESİ
                  _buildFriendsListTab(player.friends, notifier),

                  // SEKME 2: ARKADAŞ ARA & EKLE
                  _buildAddFriendTab(notifier),

                  // SEKME 3: GELEN İSTEKLER
                  _buildRequestsTab(player.friendRequests, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 👥 SEKME 1: ARKADAŞ LİSTESİ
  // ==========================================
  Widget _buildFriendsListTab(List<FriendModel> friends, GameNotifier notifier) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, color: Colors.white24, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Henüz arkadaşınız yok.',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Diğer madencileri ekleyerek birlikte kazı yapın!',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldText, foregroundColor: Colors.black),
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Arkadaş Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final skin = availableSkins.firstWhere(
          (s) => s.id == friend.equippedSkinId,
          orElse: () => availableSkins.first,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131336),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: friend.status == FriendStatus.online
                  ? AppColors.neonGreen.withValues(alpha: 0.6)
                  : const Color(0xFF242456),
              width: friend.status == FriendStatus.online ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              InkWell(
                onTap: () => _showFriendProfileModal(context, friend),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C24),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldText.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(skin.iconEmoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Bilgiler
              Expanded(
                child: InkWell(
                  onTap: () => _showFriendProfileModal(context, friend),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            friend.name,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            friend.playerTag,
                            style: const TextStyle(color: AppColors.goldText, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        friend.status.displayName,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              // Hediye Al Butonu
              if (friend.hasGiftAvailable)
                IconButton(
                  tooltip: 'Hediyeyi Kabul Et (+15 Enerji, +50 Altın)',
                  icon: const Icon(Icons.card_giftcard, color: AppColors.neonGreen, size: 22),
                  onPressed: () {
                    notifier.claimFriendGift(friend.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🎁 ${friend.name}\'ın hediyesi alındı!')),
                    );
                  },
                )
              // Hediye Gönder Butonu
              else if (!friend.giftSentToday)
                IconButton(
                  tooltip: 'Hediye Gönder (⚡ +15 Enerji)',
                  icon: const Icon(Icons.send_rounded, color: AppColors.goldText, size: 20),
                  onPressed: () {
                    notifier.sendFriendGift(friend.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🎁 ${friend.name}\'a hediye gönderildi!')),
                    );
                  },
                ),

              // Odaya Çağır Butonu
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1442),
                  foregroundColor: AppColors.goldText,
                  side: const BorderSide(color: AppColors.goldText, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const CreateRoomScreen()),
                  );
                },
                child: const Text('DAVET ET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 🔍 SEKME 2: ARKADAŞ ARA & EKLE
  // ==========================================
  Widget _buildAddFriendTab(GameNotifier notifier) {
    final suggestedPlayers = [
      {'name': 'LavKorsanı', 'tag': '#3312', 'trophies': 740, 'skin': '🌋'},
      {'name': 'ZümrütGözlü', 'tag': '#4490', 'trophies': 1200, 'skin': '🟢'},
      {'name': 'TitanSavaşçısı', 'tag': '#9981', 'trophies': 2100, 'skin': '👑'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Arama Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF141436),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E2E68)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.goldText, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Oyuncu Adı veya #Etiket yazın...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldText,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final text = _searchController.text.trim();
                  if (text.isNotEmpty) {
                    final success = notifier.sendFriendRequest(text);
                    if (success) {
                      _searchController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('📨 $text oyuncusuna istek gönderildi!')),
                      );
                    }
                  }
                },
                child: const Text('EKLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Önerilen Madenciler Başlığı
        const Text(
          '🔥 ÖNERİLEN POPÜLER MADENCİLER',
          style: TextStyle(color: AppColors.goldText, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        const SizedBox(height: 12),

        for (final p in suggestedPlayers)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF131336),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF242456)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(p['skin'] as String, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text(p['tag'] as String, style: const TextStyle(color: AppColors.goldText, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('🏆 ${p['trophies']} Kupa', style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    notifier.sendFriendRequest('${p['name']} ${p['tag']}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('📨 ${p['name']} oyuncusuna istek gönderildi!')),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 14),
                  label: const Text('İSTEK AT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==========================================
  // 📬 SEKME 3: GELEN İSTEKLER
  // ==========================================
  Widget _buildRequestsTab(List<String> requests, GameNotifier notifier) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_email_read_outlined, color: Colors.white24, size: 56),
            SizedBox(height: 12),
            Text(
              'Bekleyen arkadaşlık isteği yok.',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131336),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldText.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF1E1E46),
                child: Text('⛏️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Sana arkadaşlık isteği gönderdi!', style: TextStyle(color: Colors.white54, fontSize: 10.5)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 26),
                onPressed: () {
                  notifier.acceptFriendRequest(req);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🤝 $req arkadaş olarak eklendi!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Color(0xFFFF5252), size: 26),
                onPressed: () {
                  notifier.rejectFriendRequest(req);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
