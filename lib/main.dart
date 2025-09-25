import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth_module/auth/auth_token_provider.dart';
import 'features/auth_module/auth/token_storage.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.when(
      data: (_) {
        ref.listen(tokenStorageProvider, (previous, next) async {
          if (next.hasValue) {
            final storage = next.value!;
            final token = storage.readToken();
            if (token != null && token.isNotEmpty) {
              ref.read(authTokenProvider.notifier).state = token;
            }
          }
        });
        final router = ref.watch(routerProvider);
        return MaterialApp.router(title: 'Todo App', routerConfig: router);
      },
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
