import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/friend_model.dart';
import '../../mining/application/game_notifier.dart';

class FriendsState {
  final List<FriendModel> friends;
  final List<String> friendRequests;
  final String? searchQuery;

  const FriendsState({
    this.friends = const [],
    this.friendRequests = const [],
    this.searchQuery,
  });

  FriendsState copyWith({
    List<FriendModel>? friends,
    List<String>? friendRequests,
    String? searchQuery,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  final Ref _ref;

  FriendsNotifier(this._ref) : super(const FriendsState()) {
    _initFromGameState();
  }

  void _initFromGameState() {
    final player = _ref.read(gameNotifierProvider).player;
    state = FriendsState(
      friends: player.friends,
      friendRequests: player.friendRequests,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void sendGift(String friendUid) {
    _ref.read(gameNotifierProvider.notifier).sendFriendGift(friendUid);
    _initFromGameState();
  }

  void claimGift(String friendUid) {
    _ref.read(gameNotifierProvider.notifier).claimFriendGift(friendUid);
    _initFromGameState();
  }

  void acceptRequest(String requestName) {
    _ref.read(gameNotifierProvider.notifier).acceptFriendRequest(requestName);
    _initFromGameState();
  }

  void rejectRequest(String requestName) {
    _ref.read(gameNotifierProvider.notifier).rejectFriendRequest(requestName);
    _initFromGameState();
  }
}

final friendsNotifierProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ref);
});
