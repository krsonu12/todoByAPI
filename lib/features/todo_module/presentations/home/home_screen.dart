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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You\'re all caught up!',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap + to add your first todo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
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
                return Dismissible(
                  key: ValueKey<int>(itemId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete todo?'),
                            content: Text(
                              'Are you sure you want to delete "${t.title}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    ref
                        .read(todoControllerProvider.notifier)
                        .deleteTodo(itemId);
                  },
                  child: TodoTile(id: itemId, initialTitle: t.title),
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
          final title = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            builder: (context) => TodoEditSheet(),
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
  const TodoTile({super.key, required this.id, this.initialTitle});

  final int id;
  final String? initialTitle;

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
          onTap: () async {
            final updatedTitle = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              builder: (context) => TodoEditSheet(initialTitle: todo.title),
            );
            if (updatedTitle != null &&
                updatedTitle.isNotEmpty &&
                updatedTitle != todo.title) {
              ref
                  .read(todoControllerProvider.notifier)
                  .updateTodo(id, todo.copyWith(title: updatedTitle));
            }
          },
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

class TodoEditSheet extends StatefulWidget {
  const TodoEditSheet({super.key, this.initialTitle});
  final String? initialTitle;

  @override
  State<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends State<TodoEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    widget.initialTitle == null ? 'New Todo' : 'Edit Todo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (val) {
                  final v = val.trim();
                  if (v.isNotEmpty) Navigator.pop(context, v);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final v = _controller.text.trim();
                  if (v.isNotEmpty) Navigator.pop(context, v);
                },
                child: Text(widget.initialTitle == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
