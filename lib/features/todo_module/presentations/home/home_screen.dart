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
                final int itemId = t.id ?? index;
                return TodoTile(id: itemId);
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

class TodoTile extends ConsumerWidget {
  const TodoTile({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItem = ref.watch(
      todoControllerProvider.select((state) {
        return state.whenData((todos) {
          for (final t in todos) {
            if ((t.id ?? -1) == id) return t;
          }
          return null;
        });
      }),
    );

    return asyncItem.when(
      data: (todo) {
        if (todo == null) return const SizedBox.shrink();
        return ListTile(
          key: ValueKey<int>(id),
          title: Text(todo.title),
          leading: Checkbox(
            value: todo.completed,
            onChanged: (val) {
              ref
                  .read(todoControllerProvider.notifier)
                  .updateTodo(id, todo.copyWith(completed: val ?? false));
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              ref.read(todoControllerProvider.notifier).deleteTodo(id);
            },
          ),
        );
      },
      loading: () => const ListTile(title: Text('...')),
      error: (e, _) => ListTile(title: Text('Error: $e')),
    );
  }
}
