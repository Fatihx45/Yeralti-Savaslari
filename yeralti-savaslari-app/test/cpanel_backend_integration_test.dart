import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:derin_kazi/core/network/cpanel_api_service.dart';
import 'package:derin_kazi/features/multiplayer/application/cpanel_multiplayer_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('cPanel PHP + MySQL Multiplayer Backend Entegrasyon Testleri', () {
    test('loginOrRegister geçerli JSON yanıtını doğru modellemeli', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('auth.php')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Giriş başarılı.',
              'data': {
                'id': 1,
                'player_tag': '#5839',
                'username': 'Madenci Usta',
                'trophies': 240,
              }
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final api = CPanelApiService(client: mockClient, baseUrl: 'http://localhost/api');
      final res = await api.loginOrRegister(username: 'Madenci Usta', playerTag: '#5839');

      expect(res.success, isTrue);
      expect(res.data?['player_tag'], equals('#5839'));
      expect(res.data?['username'], equals('Madenci Usta'));
    });

    test('createRoom 6 haneli oda kodu üretmeli ve odayı kurmalı', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('rooms.php')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Oda oluşturuldu.',
              'data': {
                'room_id': 42,
                'room_code': '749201',
                'stage_seed': 98765,
                'mode': 'coop',
              }
            }),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final api = CPanelApiService(client: mockClient, baseUrl: 'http://localhost/api');
      final notifier = CPanelMultiplayerNotifier(api: api);

      final success = await notifier.createOnlineRoom(
        playerId: 1,
        roomName: 'Kızıl Vadi Kazısı',
        mode: 'coop',
      );

      expect(success, isTrue);
      expect(notifier.state.currentRoomId, equals(42));
      expect(notifier.state.currentRoomCode, equals('749201'));
      expect(notifier.state.isHost, isTrue);

      notifier.leaveRoom();
      expect(notifier.state.currentRoomId, isNull);
    });

    test('pushGameEvent canlı maç olayını API ye başarıyla iletmeli', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('game_sync.php')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Olay kaydedildi.',
              'data': {'event_id': 105}
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final api = CPanelApiService(client: mockClient, baseUrl: 'http://localhost/api');
      final res = await api.pushGameEvent(
        roomId: 42,
        playerId: 1,
        eventType: 'tile_broken',
        payload: {'tile_id': 15, 'x': 2, 'y': 4},
      );

      expect(res.success, isTrue);
      expect(res.data?['event_id'], equals(105));
    });
  });
}
