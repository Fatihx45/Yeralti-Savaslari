import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/features/friends/domain/models/friend_model.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Arkadaş ve Multiplayer Sistemi Mantık Testleri (v1.1 Hazırlık)', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    test('Başlangıçta oyuncunun geçerli bir 4 haneli playerTag etiketi olmalı', () {
      final tag = notifier.state.player.playerTag;
      expect(tag.startsWith('#'), isTrue);
      expect(tag.length, greaterThanOrEqualTo(4));
    });

    test('Başlangıç arkadaş listesinde 4 adet varsayılan arkadaş bulunmalı ve durumları doğru olmalı', () {
      final friends = notifier.state.player.friends;
      expect(friends.length, greaterThanOrEqualTo(4));

      final onlineFriend = friends.firstWhere((f) => f.status == FriendStatus.online);
      expect(onlineFriend.name, equals('KayaKıran'));
      expect(onlineFriend.playerTag, equals('#1042'));

      final miningFriend = friends.firstWhere((f) => f.status == FriendStatus.inMining);
      expect(miningFriend.name, equals('AltınAvcısı'));

      final brFriend = friends.firstWhere((f) => f.status == FriendStatus.inBattleRoyale);
      expect(brFriend.name, equals('ElmasKralı'));
    });

    test('Arkadaşa günlük hediye gönderme giftSentToday değerini true yapmalı', () {
      final friend = notifier.state.player.friends.first;
      expect(friend.giftSentToday, isFalse);

      final success = notifier.sendFriendGift(friend.uid);
      expect(success, isTrue);

      final updatedFriend = notifier.state.player.friends.firstWhere((f) => f.uid == friend.uid);
      expect(updatedFriend.giftSentToday, isTrue);

      // Aynı gün tekrar hediye gönderilemez
      final secondTry = notifier.sendFriendGift(friend.uid);
      expect(secondTry, isFalse);
    });

    test('Gelen arkadaş hediyesini açma +15 Enerji ve +50 Altın kazandırmalı', () {
      final friendWithGift = notifier.state.player.friends.firstWhere((f) => f.hasGiftAvailable);
      final initialGold = notifier.state.player.gold;
      final initialEnergy = notifier.state.player.energy;

      final success = notifier.claimFriendGift(friendWithGift.uid);
      expect(success, isTrue);

      expect(notifier.state.player.gold, equals(initialGold + 50));
      expect(notifier.state.player.energy, equals((initialEnergy + 15).clamp(0, notifier.state.player.maxEnergy)));

      final updatedFriend = notifier.state.player.friends.firstWhere((f) => f.uid == friendWithGift.uid);
      expect(updatedFriend.hasGiftAvailable, isFalse);
    });

    test('Arkadaşlık isteği onaylandığında yeni arkadaş listeye eklenmeli', () {
      final initialCount = notifier.state.player.friends.length;
      notifier.acceptFriendRequest('YeniMadenci #9999');

      expect(notifier.state.player.friends.length, equals(initialCount + 1));
      expect(notifier.state.player.friends.any((f) => f.name == 'YeniMadenci'), isTrue);
    });

    test('Arkadaşlıktan çıkarma işlemi arkadaşı listeden silmeli', () {
      final target = notifier.state.player.friends.first;
      final initialCount = notifier.state.player.friends.length;

      notifier.removeFriend(target.uid);
      expect(notifier.state.player.friends.length, equals(initialCount - 1));
      expect(notifier.state.player.friends.any((f) => f.uid == target.uid), isFalse);
    });
  });
}
