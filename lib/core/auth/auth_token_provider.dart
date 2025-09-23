import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage.dart';

final authTokenProvider = StateProvider<String?>((ref) => null);

final logoutCallbackProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(authTokenProvider.notifier).state = null;
    final storage = await ref.read(tokenStorageProvider.future);
    await storage.clearToken();
  };
});
