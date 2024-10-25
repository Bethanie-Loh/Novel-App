import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoggedInUser {
  final String loggedInUserId;
  final String loggedInUserName;

  LoggedInUser({
    required this.loggedInUserId,
    required this.loggedInUserName,
  });

  LoggedInUser copyWith({
    String? loggedInUserId,
    String? loggedInUserName,
  }) {
    return LoggedInUser(
      loggedInUserId: loggedInUserId ?? this.loggedInUserId,
      loggedInUserName: loggedInUserName ?? this.loggedInUserName,
    );
  }
}

class LoggedInUserNotifier extends StateNotifier<LoggedInUser> {
  LoggedInUserNotifier()
      : super(LoggedInUser(
          loggedInUserId: '',
          loggedInUserName: '',
        ));

  void updateLoggedInUser(String userId, String userName) {
    state = state.copyWith(
      loggedInUserId: userId,
      loggedInUserName: userName,
    );
  }

  void logout() {
    state = state.copyWith(
      loggedInUserId: '',
      loggedInUserName: '',
    );
  }
}

final loggedInUserProvider =
    StateNotifierProvider<LoggedInUserNotifier, LoggedInUser>((ref) {
  return LoggedInUserNotifier();
});
