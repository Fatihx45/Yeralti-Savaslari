import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/features/ai_team/application/ai_team_engine.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multiplayer Lobi & ID ile Arkadaş Çağırma Testleri', () {
    late AiTeamNotifier aiTeamNotifier;
    late GameNotifier gameNotifier;

    setUp(() {
      aiTeamNotifier = AiTeamNotifier();
      gameNotifier = GameNotifier();
    });

    test('Lobiye ID ile arkadaş davet edildiğinde madenci listesine eklenmeli', () {
      expect(aiTeamNotifier.state.activeMiners.length, equals(3)); // 4 kişilik takımda 3 bot

      aiTeamNotifier.inviteFriendToTeam('KayaKıran', '👷‍♂️', '#1042');

      expect(aiTeamNotifier.state.activeMiners.length, equals(3));
      final invited = aiTeamNotifier.state.activeMiners.first;
      expect(invited.name, contains('KayaKıran'));
      expect(invited.name, contains('#1042'));
      expect(invited.avatarEmoji, equals('👷‍♂️'));
    });

    test('Yeni arkadaş eklendiğinde lobi kapasitesi ve madenci listesi güncellenmeli', () {
      aiTeamNotifier.setTeamSize(2);
      expect(aiTeamNotifier.state.activeMiners.length, equals(1));

      aiTeamNotifier.inviteFriendToTeam('ElmasKralı', '👑', '#7741');
      final invited = aiTeamNotifier.state.activeMiners.first;
      expect(invited.name, contains('ElmasKralı'));
      expect(invited.name, contains('#7741'));
    });

    test('GameNotifier arkadaşlar listesinde ID (#TAG) ile arama yapılabilmeli', () {
      final friends = gameNotifier.state.player.friends;
      final found = friends.where((f) => f.playerTag == '#1042').firstOrNull;

      expect(found, isNotNull);
      expect(found!.name, equals('KayaKıran'));
    });
  });
}
