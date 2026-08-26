import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromData) {
    return ApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: fromData != null && json['data'] != null ? fromData(json['data']) : json['data'] as T?,
    );
  }
}

class CPanelApiService {
  final http.Client _client;
  final String baseUrl;

  CPanelApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.cpanelBaseUrl;

  // 1. Oyuncu Giriş & Kayıt
  Future<ApiResponse<Map<String, dynamic>>> loginOrRegister({
    required String username,
    String? playerTag,
  }) async {
    return _post('auth.php?action=login_or_register', {
      'username': username,
      'player_tag': ?playerTag,
    });
  }

  // 2. #TAG ile Arkadaş Ara
  Future<ApiResponse<List<dynamic>>> searchPlayersByTag(String tag) async {
    return _get('friends.php?action=search_tag&tag=${Uri.encodeComponent(tag)}');
  }

  // 3. 6 Haneli Kod ile Oda Oluştur
  Future<ApiResponse<Map<String, dynamic>>> createRoom({
    required int playerId,
    required String roomName,
    required String mode,
    int maxPlayers = 4,
    int stageNumber = 1,
  }) async {
    return _post('rooms.php?action=create_room', {
      'player_id': playerId,
      'room_name': roomName,
      'mode': mode,
      'max_players': maxPlayers,
      'stage_number': stageNumber,
    });
  }

  // 4. 6 Haneli Kod ile Odaya Katıl
  Future<ApiResponse<Map<String, dynamic>>> joinRoom({
    required int playerId,
    required String roomCode,
  }) async {
    return _post('rooms.php?action=join_room', {
      'player_id': playerId,
      'room_code': roomCode,
    });
  }

  // 5. Oda Detayı & Madencileri Getir
  Future<ApiResponse<Map<String, dynamic>>> getRoomDetails(int roomId) async {
    return _get('rooms.php?action=get_room_details&room_id=$roomId');
  }

  // 6. Canlı Maç Olayı Gönder (Kutu Kırma, Ateş Etme)
  Future<ApiResponse<Map<String, dynamic>>> pushGameEvent({
    required int roomId,
    required int playerId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) async {
    return _post('game_sync.php?action=push_event', {
      'room_id': roomId,
      'player_id': playerId,
      'event_type': eventType,
      'payload': payload,
    });
  }

  // 7. Yeni Olayları Çek (Polling)
  Future<ApiResponse<List<dynamic>>> fetchGameEvents({
    required int roomId,
    required int lastEventId,
  }) async {
    return _get('game_sync.php?action=fetch_events&room_id=$roomId&last_event_id=$lastEventId');
  }

  // --- YARDIMCI HTTP METOTLARI ---
  Future<ApiResponse<T>> _get<T>(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client.get(uri).timeout(AppConfig.apiTimeout);
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (d) => d as T);
    } catch (e) {
      return ApiResponse(success: false, message: 'Bağlantı hatası: $e', data: null);
    }
  }

  Future<ApiResponse<T>> _post<T>(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode(body),
          )
          .timeout(AppConfig.apiTimeout);

      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (d) => d as T);
    } catch (e) {
      return ApiResponse(success: false, message: 'Bağlantı hatası: $e', data: null);
    }
  }
}
