import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/cpanel_api_service.dart';
import '../../../../core/config/app_config.dart';

class CPanelMultiplayerState {
  final bool isConnected;
  final bool isLoading;
  final String? errorMessage;
  final int? currentRoomId;
  final String? currentRoomCode;
  final Map<String, dynamic>? roomDetails;
  final List<dynamic> roomPlayers;
  final int lastEventId;
  final bool isHost;

  const CPanelMultiplayerState({
    this.isConnected = false,
    this.isLoading = false,
    this.errorMessage,
    this.currentRoomId,
    this.currentRoomCode,
    this.roomDetails,
    this.roomPlayers = const [],
    this.lastEventId = 0,
    this.isHost = false,
  });

  CPanelMultiplayerState copyWith({
    bool? isConnected,
    bool? isLoading,
    String? errorMessage,
    int? currentRoomId,
    String? currentRoomCode,
    Map<String, dynamic>? roomDetails,
    List<dynamic>? roomPlayers,
    int? lastEventId,
    bool? isHost,
  }) {
    return CPanelMultiplayerState(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      currentRoomCode: currentRoomCode ?? this.currentRoomCode,
      roomDetails: roomDetails ?? this.roomDetails,
      roomPlayers: roomPlayers ?? this.roomPlayers,
      lastEventId: lastEventId ?? this.lastEventId,
      isHost: isHost ?? this.isHost,
    );
  }
}

class CPanelMultiplayerNotifier extends StateNotifier<CPanelMultiplayerState> {
  final CPanelApiService _api;
  Timer? _pollingTimer;

  CPanelMultiplayerNotifier({CPanelApiService? api})
      : _api = api ?? CPanelApiService(),
        super(const CPanelMultiplayerState());

  // 1. 6 Haneli Yeni Oda Oluştur
  Future<bool> createOnlineRoom({
    required int playerId,
    required String roomName,
    required String mode,
    int maxPlayers = 4,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _api.createRoom(
      playerId: playerId,
      roomName: roomName,
      mode: mode,
      maxPlayers: maxPlayers,
    );

    if (res.success && res.data != null) {
      final roomId = res.data!['room_id'] as int;
      final roomCode = res.data!['room_code'].toString();

      state = state.copyWith(
        isLoading: false,
        isConnected: true,
        currentRoomId: roomId,
        currentRoomCode: roomCode,
        isHost: true,
      );

      _startLobbyPolling(roomId);
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: res.message);
      return false;
    }
  }

  // 2. 6 Haneli Kod ile Odaya Katıl
  Future<bool> joinOnlineRoom({
    required int playerId,
    required String roomCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _api.joinRoom(
      playerId: playerId,
      roomCode: roomCode,
    );

    if (res.success && res.data != null) {
      final roomId = (res.data!['id'] ?? res.data!['room_id']) as int;

      state = state.copyWith(
        isLoading: false,
        isConnected: true,
        currentRoomId: roomId,
        currentRoomCode: roomCode,
        isHost: false,
      );

      _startLobbyPolling(roomId);
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: res.message);
      return false;
    }
  }

  // 3. Lobi Durumunu Periyodik Çek
  void _startLobbyPolling(int roomId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(AppConfig.lobbyPollingInterval, (_) async {
      final res = await _api.getRoomDetails(roomId);
      if (res.success && res.data != null) {
        state = state.copyWith(
          roomDetails: res.data,
          roomPlayers: (res.data!['players'] as List<dynamic>?) ?? [],
        );
      }
    });
  }

  // 4. Canlı Kutu Kırma Olayı Gönder
  Future<void> sendTileBrokenEvent({
    required int playerId,
    required int tileId,
    required int x,
    required int y,
  }) async {
    if (state.currentRoomId == null) return;

    await _api.pushGameEvent(
      roomId: state.currentRoomId!,
      playerId: playerId,
      eventType: 'tile_broken',
      payload: {'tile_id': tileId, 'x': x, 'y': y},
    );
  }

  // 5. Odadan Ayrıl
  void leaveRoom() {
    _pollingTimer?.cancel();
    state = const CPanelMultiplayerState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final cpanelMultiplayerNotifierProvider =
    StateNotifierProvider<CPanelMultiplayerNotifier, CPanelMultiplayerState>((ref) {
  return CPanelMultiplayerNotifier();
});
