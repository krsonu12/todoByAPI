import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../todo_module/data/todo_model.dart';
import '../../../todo_module/presentations/todo_controller/todo_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(child: Text('No todos'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(todoControllerProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: todos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final TodoModel t = todos[index];
                return ListTile(
                  title: Text(t.title),
                  leading: Checkbox(
                    value: t.completed,
                    onChanged: (val) {
                      ref
                          .read(todoControllerProvider.notifier)
                          .updateTodo(
                            t.id ?? index,
                            t.copyWith(completed: val ?? false),
                          );
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (t.id != null) {
                        ref
                            .read(todoControllerProvider.notifier)
                            .deleteTodo(t.id!);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          final title = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('New Todo'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
          if (title != null && title.isNotEmpty) {
            final todo = TodoModel(userId: 1, title: title, completed: false);
            await ref.read(todoControllerProvider.notifier).addTodo(todo);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
