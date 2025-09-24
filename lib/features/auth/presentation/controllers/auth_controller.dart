import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_token_provider.dart';
import '../../../../core/auth/token_storage.dart';
import '../../domain/providers/auth_providers.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController({required this.ref}) : super(const AsyncData(null));

  final Ref ref;

  Future<void> register({
    String? username,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(authServiceProvider)
          .register(username: username, email: email, password: password);
      ref.read(authTokenProvider.notifier).state = result.token;
      final storage = await ref.read(tokenStorageProvider.future);
      await storage.writeToken(result.token);
      state = const AsyncData(null);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(authServiceProvider)
          .login(email: email, password: password);
      ref.read(authTokenProvider.notifier).state = result.token;
      final storage = await ref.read(tokenStorageProvider.future);
      await storage.writeToken(result.token);
      state = const AsyncData(null);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).logout();
      state = const AsyncData(null);
      final storage = await ref.read(tokenStorageProvider.future);
      await storage.clearToken();
      ref.read(authTokenProvider.notifier).state = null;
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }
}



final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref: ref);
    });
