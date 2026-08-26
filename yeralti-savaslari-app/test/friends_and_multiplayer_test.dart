import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';
import 'package:derin_kazi/core/audio/audio_service.dart';
import 'package:derin_kazi/features/friends/domain/models/friend_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioService.isTestMode = true;

  group('Arkadaş Ekleme ve Sosyal Merkez Mantık Testleri', () {
    test('Başlangıçta oyuncunun arkadaş listesi ve istekleri yüklenmeli', () {
      final container = ProviderContainer();
      final state = container.read(gameNotifierProvider);

      expect(state.player.friends.isNotEmpty, true);
      expect(state.player.friendRequests.isNotEmpty, true);
      expect(state.player.playerTag.startsWith('#'), true);
      expect(state.player.trophies >= 0, true);
      container.dispose();
    });

    test('sendFriendRequest kendine istek atmayı engellemeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final selfTag = notifier.state.player.playerTag;
      final result = notifier.sendFriendRequest(selfTag);

      expect(result, false);
      expect(notifier.state.lastMessage?.contains('Kendinize') ?? false, true);
      container.dispose();
    });

    test('acceptFriendRequest isteği onaylayıp arkadaş listesine eklemeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final initialFriendCount = notifier.state.player.friends.length;
      notifier.acceptFriendRequest('MadenAvcısı #9901');

      final state = container.read(gameNotifierProvider);
      expect(state.player.friends.length, initialFriendCount + 1);
      expect(state.player.friends.any((f) => f.name == 'MadenAvcısı'), true);
      expect(state.player.friendRequests.contains('MadenAvcısı #9901'), false);
      container.dispose();
    });

    test('rejectFriendRequest isteği listeden çıkarmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.rejectFriendRequest('MadenAvcısı #9901');
      expect(notifier.state.player.friendRequests.contains('MadenAvcısı #9901'), false);
      container.dispose();
    });

    test('removeFriend arkadaşı listeden silmeli', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final firstFriend = notifier.state.player.friends.first;
      notifier.removeFriend(firstFriend.uid);

      expect(notifier.state.player.friends.any((f) => f.uid == firstFriend.uid), false);
      container.dispose();
    });

    test('sendFriendGift ve claimFriendGift enerji ve altın kazandırmalı', () {
      final container = ProviderContainer();
      final notifier = container.read(gameNotifierProvider.notifier);

      final FriendModel friendWithGift = notifier.state.player.friends.firstWhere((f) => f.hasGiftAvailable);
      final initialEnergy = notifier.state.player.energy;
      final initialGold = notifier.state.player.gold;

      // Hediyeyi kabul et
      notifier.claimFriendGift(friendWithGift.uid);

      final state = container.read(gameNotifierProvider);
      expect(state.player.gold, initialGold + 50);
      expect(state.player.energy >= initialEnergy, true);

      // Hediye gönder
      final sendResult = notifier.sendFriendGift(friendWithGift.uid);
      expect(sendResult, true);

      // Aynı gün 2. kez gönderilemez
      final sendResult2 = notifier.sendFriendGift(friendWithGift.uid);
      expect(sendResult2, false);

      container.dispose();
    });
  });
}

