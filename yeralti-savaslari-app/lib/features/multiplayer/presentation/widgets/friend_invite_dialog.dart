import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../mining/application/game_notifier.dart';
import '../../../friends/domain/models/friend_model.dart';
import '../../../cosmetics/presentation/screens/cosmetics_screen.dart';
import '../../../ai_team/application/ai_team_engine.dart';

class FriendInviteDialog extends ConsumerStatefulWidget {
  const FriendInviteDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const FriendInviteDialog(),
    );
  }

  @override
  ConsumerState<FriendInviteDialog> createState() => _FriendInviteDialogState();
}

class _FriendInviteDialogState extends ConsumerState<FriendInviteDialog> {
  final TextEditingController _idSearchController = TextEditingController();
  FriendModel? _foundFriend;

  @override
  void dispose() {
    _idSearchController.dispose();
    super.dispose();
  }

  void _searchFriendById() {
    final query = _idSearchController.text.trim();
    if (query.isEmpty) return;

    final allFriends = ref.read(gameNotifierProvider).player.friends;
    final found = allFriends.where(
      (f) => f.playerTag.toLowerCase() == query.toLowerCase() ||
             f.name.toLowerCase() == query.toLowerCase() ||
             f.playerTag.toLowerCase() == '#$query'.toLowerCase(),
    ).firstOrNull;

    setState(() {
      if (found != null) {
        _foundFriend = found;
      } else {
        // Yeni bir oyuncu oluşturup davet etme seçeneği
        final cleanTag = query.startsWith('#') ? query : '#$query';
        _foundFriend = FriendModel(
          uid: 'friend_${DateTime.now().millisecondsSinceEpoch}',
          name: query.replaceAll('#', 'Madenci_'),
          playerTag: cleanTag,
          stage: 15,
          trophies: 250,
          equippedSkinId: 'skin_cyber_digger',
          status: FriendStatus.online,
          hasGiftAvailable: true,
        );
      }
    });
  }

  void _inviteToRoom(FriendModel friend) {
    final skin = availableSkins.firstWhere(
      (s) => s.id == friend.equippedSkinId,
      orElse: () => availableSkins.first,
    );

    // AI Ekip Lobisine arkadaşı dahil et
    ref.read(aiTeamNotifierProvider.notifier).inviteFriendToTeam(
      friend.name,
      skin.iconEmoji,
      friend.playerTag,
    );

    // Arkadaş listesine de ekle (eğer yoksa)
    final existing = ref.read(gameNotifierProvider).player.friends.any((f) => f.uid == friend.uid);
    if (!existing) {
      ref.read(gameNotifierProvider.notifier).acceptFriendRequest('${friend.name} ${friend.playerTag}');
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B0B26),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.lavaOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              '🤝 ${friend.name} ${friend.playerTag} odaya katıldı!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(gameNotifierProvider.select((s) => s.player));
    final friends = player.friends;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF140D1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lavaOrange, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.lavaOrange.withValues(alpha: 0.3),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Üst Başlık & Kapat Butonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.hudPanel,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                border: Border(bottom: BorderSide(color: Color(0xFF4A2518), width: 1.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add_alt_1, color: AppColors.lavaOrange, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'ARKADAŞINI ODAYA ÇAĞIR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 2. Kendi ID'ni Paylaşma Şeridi
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.panelBox,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.goldText.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SENİN OYUNCU ID NUMARAN:', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                      Text(
                        player.playerTag,
                        style: const TextStyle(color: AppColors.goldText, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldText,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('KOPYALA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: player.playerTag));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID numaranız panoya kopyalandı! Arkadaşınıza gönderin.')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. ID ile Arkadaş Arama & Ekleme Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.hudPanel,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF4A2518)),
                      ),
                      child: TextField(
                        controller: _idSearchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Arkadaşının ID (#1042) veya İsmini Yaz...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _searchFriendById(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavaOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _searchFriendById,
                    child: const Text('BUL 🔍', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Arama Sonucu Kartı (Varsa)
            if (_foundFriend != null)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF26182B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lavaOrange),
                ),
                child: Row(
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _foundFriend!.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            'ID: ${_foundFriend!.playerTag} • 🏆 ${_foundFriend!.trophies} Kupa',
                            style: const TextStyle(color: AppColors.goldText, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lavaOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _inviteToRoom(_foundFriend!),
                      child: const Text('⚡ ODAYA AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'KAYITLI ARKADAŞLARIN:',
                style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),

            // 4. Mevcut Arkadaşlar Listesi
            Expanded(
              child: friends.isEmpty
                  ? const Center(
                      child: Text('Henüz arkadaşınız yok. Yukarıdan ID ile arayın!', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final skin = availableSkins.firstWhere(
                          (s) => s.id == friend.equippedSkinId,
                          orElse: () => availableSkins.first,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.hudPanel,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF4A2518)),
                          ),
                          child: Row(
                            children: [
                              Text(skin.iconEmoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          friend.playerTag,
                                          style: const TextStyle(color: AppColors.goldText, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          friend.status.displayName,
                                          style: const TextStyle(fontSize: 9.5, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D2838),
                                  foregroundColor: AppColors.cyanText,
                                  side: const BorderSide(color: AppColors.cyanText, width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: () => _inviteToRoom(friend),
                                child: const Text('ÇAĞIR ⚡', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
