import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_token_provider.dart';
import '../../features/auth/presentation/signin_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/todo_screens/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final String? token = ref.watch(authTokenProvider);

  return GoRouter(
    initialLocation: token == null ? '/signin' : '/home',
    routes: <GoRoute>[
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (BuildContext context, GoRouterState state) =>
            const SigninScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) =>
            const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthed = ref.read(authTokenProvider) != null;
      final bool goingAuth =
          state.matchedLocation == '/signin' ||
          state.matchedLocation == '/signup';

      if (!isAuthed && !goingAuth) return '/signin';
      if (isAuthed && goingAuth) return '/home';
      return null;
    },
  );
});
