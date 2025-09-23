import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_token_provider.dart';
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
      state = const AsyncData(null);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref: ref);
    });
