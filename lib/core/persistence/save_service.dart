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

  static Future<void> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playerKey);
    } catch (_) {}
  }
}
