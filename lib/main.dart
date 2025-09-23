import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_token_provider.dart';
import 'core/auth/token_storage.dart';
import 'features/auth/presentation/signin_screen.dart';
import 'features/todo_screens/home/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.when(
      data: (_) => MaterialApp(title: 'Todo App', home: _initialHome(ref)),
      loading: () => const MaterialApp(
        title: 'Todo App',
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const MaterialApp(
        title: 'Todo App',
        home: Scaffold(body: Center(child: Text('Storage init failed'))),
      ),
    );
  }
}

Widget _initialHome(WidgetRef ref) {
  final token = ref.read(tokenStorageProvider).readToken();
  if (token != null && token.isNotEmpty) {
    ref.read(authTokenProvider.notifier).state = token;
    return const HomeScreen();
  }
  return const SigninScreen();
}
