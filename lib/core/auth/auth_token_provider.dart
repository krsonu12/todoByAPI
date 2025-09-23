import 'package:flutter_riverpod/flutter_riverpod.dart';

final authTokenProvider = StateProvider<String?>((ref) => null);

final logoutCallbackProvider = Provider<void Function()>((ref) {
  return () {
    // Clear token on logout by default
    ref.read(authTokenProvider.notifier).state = null;
  };
});
