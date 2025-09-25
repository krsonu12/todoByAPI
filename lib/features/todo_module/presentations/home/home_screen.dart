import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../todo_module/data/todo_model.dart';
import '../../../todo_module/presentations/todo_controller/todo_controller.dart';
import '../../data/local_db/task_extras.dart';
import '../../data/local_db/task_extras_dao.dart';
import '../../domain/users_repository.dart';
import '../shared/animated_widgets.dart';
import '../shared/design_system.dart';
import '../shared/responsive_layout.dart';
import 'task_edit_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoControllerProvider);
    return Scaffold(
      backgroundColor: TodoDesignSystem.neutralGray50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Tasks',
          style: TodoDesignSystem.headingMedium.copyWith(
            color: TodoDesignSystem.neutralGray900,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: TodoDesignSystem.spacing16),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(authControllerProvider.notifier).logout();
              },
              icon: Container(
                padding: const EdgeInsets.all(TodoDesignSystem.spacing8),
                decoration: BoxDecoration(
                  color: TodoDesignSystem.neutralGray100,
                  borderRadius: BorderRadius.circular(
                    TodoDesignSystem.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: TodoDesignSystem.neutralGray600,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return _EmptyState();
          }
          return ResponsiveContainer(
            maxWidth: 800,
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(todoControllerProvider.notifier).refresh(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (sn) {
                  if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
                    ref.read(todoControllerProvider.notifier).loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: TodoDesignSystem.spacing8,
                    bottom: 96,
                  ),
                  itemCount: todos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == todos.length) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: TodoDesignSystem.spacing24,
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    final TodoModel t = todos[index];
                    final int itemId = t.id ?? index;
                    return AnimatedSlideItem(
                      index: index,
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: TodoDesignSystem.spacing12,
                        ),
                        child: Dismissible(
                          key: ValueKey<int>(itemId),
                          direction: DismissDirection.endToStart,
                          background: _DismissBackground(),
                          confirmDismiss: (_) => _showDeleteDialog(context, t),
                          onDismissed: (_) {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(todoControllerProvider.notifier)
                                .deleteTodo(itemId);
                          },
                          child: TodoTile(id: itemId, initialTitle: t.title),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        loading: () => _LoadingState(),
        error: (e, _) => _ErrorState(error: e.toString()),
      ),
      floatingActionButton: AnimatedMorphingFAB(
        onPressed: () => _showAddTaskSheet(context, ref),
        icon: Icons.add_rounded,
      ),
    );
  }

  Future<void> _showAddTaskSheet(BuildContext context, WidgetRef ref) async {
    final users = await ref.read(usersRepositoryProvider).getUsers();
    final result = await ResponsiveBottomSheet.show<TaskFormResult>(
      context: context,
      child: TaskEditSheet(prefetchedUsers: users),
    );
    if (result != null && result.title.isNotEmpty) {
      final tempId = DateTime.now().millisecondsSinceEpoch * -1;
      final todo = TodoModel(
        id: tempId,
        userId: 1,
        title: result.title,
        completed: false,
      );
      await ref
          .read(taskExtrasDaoProvider)
          .upsert(
            TaskExtras(
              taskId: tempId,
              description: result.description,
              dueDate: result.dueDate,
              priority: result.priority,
              status: result.status,
              assignedUserId: result.assignedUserId,
              assignedUserName: result.assignedUserName,
            ),
          );
      await ref.read(todoControllerProvider.notifier).addTodo(todo);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: TodoDesignSystem.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                TodoDesignSystem.radiusMedium,
              ),
            ),
            content: Text(
              'Task created: ${result.title}',
              style: TodoDesignSystem.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context, TodoModel todo) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TodoDesignSystem.radiusLarge),
        ),
        title: Text('Delete Task?', style: TodoDesignSystem.headingSmall),
        content: Text(
          'Are you sure you want to delete "${todo.title}"? This action cannot be undone.',
          style: TodoDesignSystem.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TodoDesignSystem.labelLarge.copyWith(
                color: TodoDesignSystem.neutralGray600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TodoDesignSystem.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: TodoDesignSystem.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
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
        return AnimatedTaskCard(
          onTap: () => _editTask(context, ref, todo),
          child: Consumer(
            builder: (context, ref, child) {
              ref.watch(todoControllerProvider);

              return FutureBuilder(
                future: ref.read(taskExtrasDaoProvider).findByTaskId(id),
                builder: (context, snap) {
                  final extras = snap.data;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: TodoDesignSystem.animationMedium,
                              style: TodoDesignSystem.bodyLarge.copyWith(
                                color: TodoDesignSystem.neutralGray900,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w600,
                              ),
                              child: Text(
                                todo.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (extras?.description.isNotEmpty == true) ...[
                              const SizedBox(height: TodoDesignSystem.spacing4),
                              Text(
                                extras!.description,
                                style: TodoDesignSystem.bodySmall.copyWith(
                                  color: TodoDesignSystem.neutralGray600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (extras != null) ...[
                              const SizedBox(height: TodoDesignSystem.spacing8),
                              Wrap(
                                spacing: TodoDesignSystem.spacing8,
                                runSpacing: TodoDesignSystem.spacing4,
                                children: [
                                  if (extras.dueDate != null)
                                    _ModernChip(
                                      icon: Icons.schedule_rounded,
                                      label: _fmtDate(extras.dueDate!),
                                      color: _getDueDateColor(extras.dueDate!),
                                    ),
                                  AnimatedPriorityChip(
                                    priority: extras.priority.name,
                                    label: _labelPriority(extras.priority),
                                  ),
                                  _ModernChip(
                                    icon: _getStatusIcon(extras.status),
                                    label: _labelStatus(extras.status),
                                    color: TodoDesignSystem.getStatusColor(
                                      extras.status.name,
                                    ),
                                  ),
                                  if (extras.assignedUserName != null)
                                    _ModernChip(
                                      icon: Icons.person_rounded,
                                      label: extras.assignedUserName!,
                                      color: TodoDesignSystem.secondaryPurple,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          left: TodoDesignSystem.spacing8,
                        ),
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(todoControllerProvider.notifier)
                                .deleteTodo(id);
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: TodoDesignSystem.neutralGray400,
                            size: 20,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => AnimatedSkeleton(
        width: double.infinity,
        height: 80,
        borderRadius: BorderRadius.circular(TodoDesignSystem.radiusMedium),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(TodoDesignSystem.spacing16),
        decoration: BoxDecoration(
          color: TodoDesignSystem.errorRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TodoDesignSystem.radiusMedium),
        ),
        child: Text(
          'Error loading task: $e',
          style: TodoDesignSystem.bodySmall.copyWith(
            color: TodoDesignSystem.errorRed,
          ),
        ),
      ),
    );
  }

  Future<void> _editTask(
    BuildContext context,
    WidgetRef ref,
    TodoModel todo,
  ) async {
    HapticFeedback.lightImpact();
    final users = await ref.read(usersRepositoryProvider).getUsers();
    final extras = await ref.read(taskExtrasDaoProvider).findByTaskId(id);
    final assignedUser = extras?.assignedUserId != null
        ? users.firstWhere(
            (u) => u.id == extras!.assignedUserId,
            orElse: () => AppUser(
              id: extras!.assignedUserId!,
              name: extras.assignedUserName ?? 'Unknown User',
            ),
          )
        : null;

    final result = await ResponsiveBottomSheet.show<TaskFormResult>(
      context: context,
      child: TaskEditSheet(
        initial: TaskFormResult(
          title: todo.title,
          description: extras?.description ?? '',
          dueDate: extras?.dueDate,
          priority: extras?.priority ?? TaskPriority.medium,
          status: extras?.status ?? TaskStatus.todo,
          assignedUserId: assignedUser?.id,
          assignedUserName: assignedUser?.name,
        ),
        prefetchedUsers: users,
      ),
    );
    if (result != null) {
      await ref
          .read(taskExtrasDaoProvider)
          .upsert(
            TaskExtras(
              taskId: id,
              description: result.description,
              dueDate: result.dueDate,
              priority: result.priority,
              status: result.status,
              assignedUserId: result.assignedUserId,
              assignedUserName: result.assignedUserName,
            ),
          );
      ref
          .read(todoControllerProvider.notifier)
          .updateTodo(
            id,
            todo.copyWith(
              title: result.title.isNotEmpty ? result.title : todo.title,
            ),
          );
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    if (difference < 0) return TodoDesignSystem.errorRed;
    if (difference == 0) return TodoDesignSystem.warningOrange;
    if (difference <= 3) return TodoDesignSystem.warningOrange;
    return TodoDesignSystem.neutralGray500;
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.hourglass_empty_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }
}

class _ModernChip extends StatelessWidget {
  const _ModernChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TodoDesignSystem.spacing8,
        vertical: TodoDesignSystem.spacing2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TodoDesignSystem.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: TodoDesignSystem.spacing4),
          Text(
            label,
            style: TodoDesignSystem.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _labelPriority(TaskPriority p) => {
  TaskPriority.high: 'High',
  TaskPriority.medium: 'Medium',
  TaskPriority.low: 'Low',
}[p]!;
String _labelStatus(TaskStatus s) => {
  TaskStatus.todo: 'To-Do',
  TaskStatus.inProgress: 'In Progress',
  TaskStatus.done: 'Done',
}[s]!;

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TodoDesignSystem.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TodoDesignSystem.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 60,
                color: TodoDesignSystem.primaryBlue,
              ),
            ),
            const SizedBox(height: TodoDesignSystem.spacing24),
            Text(
              'All caught up!',
              style: TodoDesignSystem.headingMedium.copyWith(
                color: TodoDesignSystem.neutralGray900,
              ),
            ),
            const SizedBox(height: TodoDesignSystem.spacing8),
            Text(
              'You have no tasks at the moment.\nTap the + button to create your first task.',
              textAlign: TextAlign.center,
              style: TodoDesignSystem.bodyMedium.copyWith(
                color: TodoDesignSystem.neutralGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TodoDesignSystem.spacing16),
      child: Column(
        children: List.generate(
          6,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: TodoDesignSystem.spacing12),
            padding: const EdgeInsets.all(TodoDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                TodoDesignSystem.radiusMedium,
              ),
              boxShadow: TodoDesignSystem.shadowSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedSkeleton(
                      width: 20,
                      height: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(width: TodoDesignSystem.spacing12),
                    Expanded(
                      child: AnimatedSkeleton(
                        width: double.infinity,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TodoDesignSystem.spacing8),
                AnimatedSkeleton(
                  width: double.infinity,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: TodoDesignSystem.spacing4),
                AnimatedSkeleton(
                  width: 200,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: TodoDesignSystem.spacing8),
                Row(
                  children: [
                    AnimatedSkeleton(
                      width: 60,
                      height: 20,
                      borderRadius: BorderRadius.circular(
                        TodoDesignSystem.radiusSmall,
                      ),
                    ),
                    const SizedBox(width: TodoDesignSystem.spacing8),
                    AnimatedSkeleton(
                      width: 80,
                      height: 20,
                      borderRadius: BorderRadius.circular(
                        TodoDesignSystem.radiusSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TodoDesignSystem.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TodoDesignSystem.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: TodoDesignSystem.errorRed,
              ),
            ),
            const SizedBox(height: TodoDesignSystem.spacing24),
            Text(
              'Something went wrong',
              style: TodoDesignSystem.headingMedium.copyWith(
                color: TodoDesignSystem.neutralGray900,
              ),
            ),
            const SizedBox(height: TodoDesignSystem.spacing8),
            Text(
              'Unable to load your tasks. Please try again.',
              textAlign: TextAlign.center,
              style: TodoDesignSystem.bodyMedium.copyWith(
                color: TodoDesignSystem.neutralGray600,
              ),
            ),
            const SizedBox(height: TodoDesignSystem.spacing16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: TodoDesignSystem.spacing20),
      margin: const EdgeInsets.only(bottom: TodoDesignSystem.spacing12),
      decoration: BoxDecoration(
        color: TodoDesignSystem.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TodoDesignSystem.radiusMedium),
        border: Border.all(
          color: TodoDesignSystem.errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: TodoDesignSystem.errorRed,
            size: 28,
          ),
          const SizedBox(height: TodoDesignSystem.spacing4),
          Text(
            'Delete',
            style: TodoDesignSystem.labelSmall.copyWith(
              color: TodoDesignSystem.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
