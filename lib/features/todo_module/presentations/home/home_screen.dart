import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'),actions: [
        IconButton(onPressed: () {
          ref.read(authControllerProvider.notifier).logout();
        }, icon: const Icon(Icons.logout)),
      ],),
      body: const Center(child: Text('Welcome!')),
    );
  }
}


