import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/mining/domain/models/player_state_model.dart';

class SaveService {
  static const String _playerKey = 'derin_kazi_player_save_v1';

  static Future<void> savePlayer(PlayerStateModel player) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(player.toJson());
      await prefs.setString(_playerKey, jsonStr);
    } catch (_) {}
  }

  static Future<PlayerStateModel?> loadPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_playerKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return PlayerStateModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  static const String _questsKey = 'derin_kazi_quests_save_v1';
  static const String _questResetKey = 'derin_kazi_quest_reset_v1';

  static Future<void> saveQuests(List<dynamic> questsJson, int lastResetTimestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_questsKey, jsonEncode(questsJson));
      await prefs.setInt(_questResetKey, lastResetTimestamp);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questsStr = prefs.getString(_questsKey);
      final lastReset = prefs.getInt(_questResetKey);
      if (questsStr != null) {
        return {
          'quests': jsonDecode(questsStr) as List<dynamic>,
          'lastReset': lastReset ?? DateTime.now().millisecondsSinceEpoch,
        };
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playerKey);
      await prefs.remove(_questsKey);
      await prefs.remove(_questResetKey);
    } catch (_) {}
  }
}
