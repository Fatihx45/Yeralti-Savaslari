import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derin_kazi/core/audio/audio_service.dart';
import 'package:derin_kazi/features/settings/application/settings_notifier.dart';
import 'package:derin_kazi/features/friends/application/friends_notifier.dart';
import 'package:derin_kazi/features/quests/application/quest_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Modüler StateNotifier Testleri (Settings, Friends, Quests)', () {
    late ProviderContainer container;

    setUp(() {
      AudioService.isTestMode = true;
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('SettingsNotifier bağımsız olarak ses, titreşim ve dil ayarlarını yönetmeli', () {
      final settingsNotifier = container.read(settingsNotifierProvider.notifier);

      expect(container.read(settingsNotifierProvider).languageCode, equals('tr'));

      settingsNotifier.toggleLanguage();
      expect(container.read(settingsNotifierProvider).languageCode, equals('en'));

      settingsNotifier.activateAllSettings();
      expect(container.read(settingsNotifierProvider).musicVolume, equals(1.0));
      expect(container.read(settingsNotifierProvider).sfxVolume, equals(1.0));
      expect(container.read(settingsNotifierProvider).vibrationEnabled, isTrue);
    });

    test('FriendsNotifier arkadaş listesini ve istekleri yönetmeli', () {
      final friendsNotifier = container.read(friendsNotifierProvider.notifier);
      final friendsState = container.read(friendsNotifierProvider);

      expect(friendsState.friends, isNotEmpty);
      friendsNotifier.setSearchQuery('Kaya');
      expect(container.read(friendsNotifierProvider).searchQuery, equals('Kaya'));
    });

    test('QuestNotifier haftalık görevleri ve tamamlanan görev sayısını izlemeli', () {
      final questState = container.read(questNotifierProvider);

      expect(questState.weeklyQuests.length, equals(12));
      expect(questState.completedQuestsCount, greaterThanOrEqualTo(0));
    });
  });
}
