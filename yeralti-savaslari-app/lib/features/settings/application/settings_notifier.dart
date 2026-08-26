import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_service.dart';
import '../../mining/application/game_notifier.dart';

class SettingsState {
  final double musicVolume;
  final double sfxVolume;
  final bool vibrationEnabled;
  final bool notificationsEnergyFull;
  final bool notificationsDailyQuest;
  final bool notificationsInvites;
  final String languageCode; // 'tr', 'en'

  const SettingsState({
    this.musicVolume = 0.8,
    this.sfxVolume = 1.0,
    this.vibrationEnabled = true,
    this.notificationsEnergyFull = true,
    this.notificationsDailyQuest = true,
    this.notificationsInvites = true,
    this.languageCode = 'tr',
  });

  SettingsState copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    bool? notificationsEnergyFull,
    bool? notificationsDailyQuest,
    bool? notificationsInvites,
    String? languageCode,
  }) {
    return SettingsState(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnergyFull: notificationsEnergyFull ?? this.notificationsEnergyFull,
      notificationsDailyQuest: notificationsDailyQuest ?? this.notificationsDailyQuest,
      notificationsInvites: notificationsInvites ?? this.notificationsInvites,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const SettingsState()) {
    _initFromGameState();
  }

  void _initFromGameState() {
    final player = _ref.read(gameNotifierProvider).player;
    state = SettingsState(
      musicVolume: player.musicVolume,
      sfxVolume: player.sfxVolume,
      vibrationEnabled: player.vibrationEnabled,
      notificationsEnergyFull: player.notificationsEnergyFull,
      notificationsDailyQuest: player.notificationsDailyQuest,
      notificationsInvites: player.notificationsInvites,
      languageCode: player.languageCode,
    );
  }

  void updateSettings({
    double? musicVolume,
    double? sfxVolume,
    bool? vibrationEnabled,
    bool? notificationsEnergyFull,
    bool? notificationsDailyQuest,
    bool? notificationsInvites,
    String? languageCode,
  }) {
    state = state.copyWith(
      musicVolume: musicVolume,
      sfxVolume: sfxVolume,
      vibrationEnabled: vibrationEnabled,
      notificationsEnergyFull: notificationsEnergyFull,
      notificationsDailyQuest: notificationsDailyQuest,
      notificationsInvites: notificationsInvites,
      languageCode: languageCode,
    );

    // AudioService ve GameNotifier ile senkronize et
    if (musicVolume != null || sfxVolume != null) {
      AudioService().updateSettings(
        enabled: true,
        sfxVol: state.sfxVolume,
        musicVol: state.musicVolume,
      );
    }

    _ref.read(gameNotifierProvider.notifier).updateSettings(
      musicVolume: state.musicVolume,
      sfxVolume: state.sfxVolume,
      vibrationEnabled: state.vibrationEnabled,
      notificationsEnergyFull: state.notificationsEnergyFull,
      notificationsDailyQuest: state.notificationsDailyQuest,
      notificationsInvites: state.notificationsInvites,
      languageCode: state.languageCode,
    );
  }

  void activateAllSettings() {
    updateSettings(
      musicVolume: 1.0,
      sfxVolume: 1.0,
      vibrationEnabled: true,
      notificationsEnergyFull: true,
      notificationsDailyQuest: true,
      notificationsInvites: true,
    );
  }

  void setLanguage(String langCode) {
    updateSettings(languageCode: langCode);
  }

  void toggleLanguage() {
    final next = state.languageCode == 'en' ? 'tr' : 'en';
    setLanguage(next);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
