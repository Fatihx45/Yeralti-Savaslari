import 'package:flutter_test/flutter_test.dart';
import 'package:derin_kazi/core/localization/app_strings.dart';
import 'package:derin_kazi/features/mining/application/game_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Çoklu Dil (Localization / i18n) Testleri', () {
    late GameNotifier gameNotifier;

    setUp(() {
      gameNotifier = GameNotifier();
    });

    test('Varsayılan dil Türkçe olmalı ve AppStrings Türkçe metinleri vermeli', () {
      expect(gameNotifier.state.player.languageCode, equals('tr'));

      expect(AppStrings.tr('play_game', lang: 'tr'), contains('OYUNA BAŞLA'));
      expect(AppStrings.tr('team_mining', lang: 'tr'), contains('EKİP KAZISI'));
      expect(AppStrings.tr('dig_hit', lang: 'tr'), equals('KAZ / VUR'));
      expect(AppStrings.tr('fire', lang: 'tr'), equals('ATEŞ ET'));
      expect(AppStrings.tr('bag', lang: 'tr'), equals('ÇANTA'));
      expect(AppStrings.tr('shop', lang: 'tr'), equals('MAĞAZA'));
    });

    test('İngilizce seçildiğinde AppStrings İngilizce metinleri vermeli', () {
      expect(AppStrings.tr('play_game', lang: 'en'), contains('PLAY GAME'));
      expect(AppStrings.tr('team_mining', lang: 'en'), contains('TEAM MINING'));
      expect(AppStrings.tr('dig_hit', lang: 'en'), equals('DIG / HIT'));
      expect(AppStrings.tr('fire', lang: 'en'), equals('FIRE'));
      expect(AppStrings.tr('bag', lang: 'en'), equals('BAG'));
      expect(AppStrings.tr('shop', lang: 'en'), equals('SHOP'));
      expect(AppStrings.tr('stage_completed', lang: 'en'), equals('STAGE COMPLETED!'));
    });

    test('GameNotifier.setLanguage ve toggleLanguage dil state ini değiştirmeli', () {
      expect(gameNotifier.state.player.languageCode, equals('tr'));

      gameNotifier.toggleLanguage();
      expect(gameNotifier.state.player.languageCode, equals('en'));
      expect(gameNotifier.state.lastMessage, contains('English'));

      gameNotifier.toggleLanguage();
      expect(gameNotifier.state.player.languageCode, equals('tr'));
      expect(gameNotifier.state.lastMessage, contains('Türkçe'));

      gameNotifier.setLanguage('en');
      expect(gameNotifier.state.player.languageCode, equals('en'));
    });
  });
}
